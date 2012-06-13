class Sql
  def self.select(columns, options)
    column_names = columns.join ','
    table_name = options[:from]

    "select (#{column_names}) from #{table_name}"
  end

  def self.dslify object
    virtualizer = VirtualKeywords::Virtualizer.new :for_instances => [object]

    virtualizer.virtual_if do |condition, then_do, else_do|
      # In this DSL, all "if"s are postfix and have no else clause.
      "#{then_do.call} where #{condition.call}"
    end

    virtualizer.virtual_or do |first, second|
      "#{first.call} or #{second.call}"
    end
  end
end

class MicroSqlUser
  # First version, just using built-in syntatic sugar: optional parentheses
  # and braces around hashes.
  def simple_select
    # Limitation: the parser can't handle the new hash syntax
    # (so here we use the old one)
    Sql::select [:name, :post_ids], :from => :users
  end

  # Ok, now mix in some VirtualKeywords!
  # Use postfix "if" to stand in for "where" clauses. It should look
  # gramatically similar to SQL, just with "if" instead of "where".
  #
  # Calling virtual_if should turn this method into:
  #
  # name_is_rahul = 'name="rahul"' 
  # VirtualKeywords::REWRITTEN_KEYWORDS.call_if(
  #     self,
  #     lambda { Sql::select [:name, :post_ids], :from=> :users },
  #     lambda { name_is_rahul },
  #     lambda {}
  # )
  def select_with_where
    # Limitation: 'name="rahul"' is in quotes (we can't actually get
    # AST nodes because virtual_keywords hides them.)
    
    # Using the string literal directly is valid Ruby, but produces
    # an annoying warning.
    name_is_rahul = 'name="rahul"' 
    Sql::select [:name, :post_ids], :from => :users if name_is_rahul
  end

  # Should turn into:
  # def select_with_or
  #   name_is_rahul = "name=\"rahul\""
  #   is_full_name = "name=\"Rahul Rajagopalan\""
  #   VirtualKeywords::REWRITTEN_KEYWORDS.call_if(
  #      self,
  #      lambda do
  #        VirtualKeywords::REWRITTEN_KEYWORDS.call_or(
  #            self,
  #            lambda { name_is_rahul },
  #            lambda { is_full_name }
  #        )
  #      end,
  #      lambda { Sql.select([:name, :post_ids], :from => :users) },
  #      lambda { }
  #  )
  # end
  def select_with_or
    name_is_rahul = 'name="rahul"' 
    is_full_name = 'name="Rahul Rajagopalan"'
    Sql::select [:name, :post_ids], :from => :users if
        name_is_rahul or is_full_name
  end

  # Should turn into:
  # def select_complex
  #   name_is_rahul = "name=\"rahul\""
  #   right_id = "id=5"
  #   is_full_name = "name=\"Rahul Rajagopalan\""
  #   VirtualKeywords::REWRITTEN_KEYWORDS.call_if(
  #       self,
  #       lambda do
  #         VirtualKeywords::REWRITTEN_KEYWORDS.call_or(
  #             self,
  #             lambda do
  #               VirtualKeywords::REWRITTEN_KEYWORDS.call_and(
  #                   self,
  #                   lambda { name_is_rahul },
  #                   lambda { right_id }
  #               )
  #             end,
  #             lambda { is_full_name }
  #         )
  #       end,
  #       lambda { Sql.select([:name, :post_ids], :from => :users) },
  #       lambda { }
  #   )
  # end
  def select_complex
    name_is_rahul = 'name="rahul"' 
    right_id = 'id=5'
    is_full_name = 'name="Rahul Rajagopalan"'
    Sql::select [:name, :post_ids], :from => :users if
        name_is_rahul and right_id or is_full_name
  end
end
