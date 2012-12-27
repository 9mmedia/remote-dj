module Services	
  module Utils
	# Performs a nested lookup on the given hash using the given list of keys
	# E.g.: nested_lookup(my_hash, "foo", "bar", blah") will return either
	# the value of my_hash["foo"]["bar"]["blah"] or nil
	# if the full nested path cannot be traversed
	def nested_lookup(hash, *keys)
	  result = nil
	  count = keys.count
	  keys.each_with_index do |key, i|
	    break if !hash.kind_of?(Hash)
	          
	    if (i < (count - 1))
	      hash = hash[key]
	    else
	      result = hash[key]
	    end
	  end

	  result  
	end
  end
end