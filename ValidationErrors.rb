module ValidationErrors

class RequiredFieldError < ArgumentError
	
end

class ExistingSkuError < StandardError
	
end


end