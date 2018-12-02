module ValidationErrors

class RequiredFieldError < ArgumentError
	
end

class ExistingSkuError < StandardError
	
end

class CantLessThanOneError < ArgumentError
	
end

class StockError < ArgumentError
	
end

end