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

			    insert_data = {}
			    raise if (insert_data[':sku']    = data['sku']).nil?  #validar el sku seria comprobar que no existe uno igual almacenado
			    raise if (insert_data[':description'] = data['description']).nil? 
			    raise if (insert_data[':stock']  = data['stock']).nil? 
			    raise if (insert_data[':price']    = data['price']).nil? 
			    stmt.execute( insert_data )

		 	end
		
		end	
		
	end

end