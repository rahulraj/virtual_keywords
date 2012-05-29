module VirtualKeywords
  # Deeply copy an array.
  #
  # Arguments:
  #   array: (Array[A]) the array to copy. A is any arbitrary type.
  #
  # Returns:
  #   (Array[A]) a deep copy of the original array.
  def self.deep_copy_array(array)
    Marshal.load(Marshal.dump(array))
  end
end
