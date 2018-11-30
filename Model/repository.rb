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


end