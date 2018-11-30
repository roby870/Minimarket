Bundler.require(:repository)

class Repository

	def self.obtainInstance
		@@instance ||= self.new
	end


	def getConnection
		Amalgalite::Database.new("Model/Minimarket.db") #retorna la base o la crea si no existe	
	end

	def getItems
		db = getConnection
		items = []
		db.transaction do |db_in_transaction|
	   		db_in_transaction.prepare("SELECT id, sku, description FROM items;") do |stmt|
		    	items = stmt.execute
	 		end
		end
		items
	end	

	def addItem(data)
		db = getConnection

		db.transaction do |db_in_transaction|

		   	db_in_transaction.prepare("INSERT INTO items(sku, description, stock, price) VALUES( :sku, :description, :stock, :price );") do |stmt|

			    stmt.execute(data)

		 	end
		
		end	

	end

	def checkSku(aSku)
		db = getConnection
		result = []
		db.transaction do |db_in_transaction|

		   	db_in_transaction.prepare("SELECT sku FROM items WHERE sku = '#{aSku}';") do |stmt|

			    result = stmt.execute

		 	end
		
		end	

		result.empty?
	
	end	

end