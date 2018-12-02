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

	def getItem(anId)
		db = getConnection
		item = []
		db.transaction do |db_in_transaction|
	   		db_in_transaction.prepare("SELECT * FROM items WHERE id = '#{anId}';") do |stmt|
		    	item = stmt.execute
	 		end
		end
		item
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

	def modifyItem(anId, update_data)

		db = getConnection
		
		db.transaction do |db_in_transaction|

		   	db_in_transaction.prepare("UPDATE items SET  #{(update_data.collect do |key, value|
		   		
			   		"#{key} = '#{value}' "

			   		end).join(',')}  

		   		WHERE id = '#{anId}';") do |stmt|

			    stmt.execute

		 	end
		
		end	

	end	

	def userShoppingCart(aUsername)
		db = getConnection
		shoppingCart = []
		db.transaction do |db_in_transaction|
	   		db_in_transaction.prepare("SELECT created, id FROM shopping_carts WHERE username = '#{aUsername}';") do |stmt|
		    	shoppingCart = stmt.execute
	 		end
		end
		shoppingCart
	end

	def createShoppingCart(aUsername)
		db = getConnection
		data = {}
		data[':username'] = aUsername
		db.transaction do |db_in_transaction|

		   	db_in_transaction.prepare("INSERT INTO shopping_carts(username, created) VALUES( :username, CURRENT_DATE);") do |stmt|

			    stmt.execute(data)

		 	end
		
		end	

		userShoppingCart aUsername

	end

	def itemsShoppingCart(aUsername)
		db = getConnection
		items = []
		db.transaction do |db_in_transaction|
	   		db_in_transaction.prepare("SELECT i.description, i.price, sci.cant FROM shopping_carts sc 
	   												  INNER JOIN shopping_cart_has_item sci ON sc.id = sci.shopping_cart
	   												  INNER JOIN items i ON i.id = sci.item	
	   									WHERE username = '#{aUsername}';") do |stmt|
		    	items = stmt.execute
	 		end
		end
		items
	end

	def checkStock (anId, aCant)
		db = getConnection
		result = 0
		db.transaction do |db_in_transaction|
		   	db_in_transaction.prepare("SELECT stock FROM items WHERE id = '#{anId}';") do |stmt|
			    result = stmt.execute
		 	end
		end	
		if result[0][0] >= aCant
			true
		else
			false
		end
	end

	def addItemToShoppingCart(update_data) #falta restarle la cantidad al stock
		db = getConnection
		
		db.transaction do |db_in_transaction|

			db_in_transaction.prepare("UPDATE items 
		  							SET  stock = stock - '#{update_data[':cantidad']}'
			   						WHERE  id = '#{update_data[':id']}';") do |stmt|
				   						stmt.execute
		 	end		
		end	

		item = []
		db.transaction do |db_in_transaction|
	   		db_in_transaction.prepare("SELECT * FROM shopping_cart_has_item
	   									WHERE shopping_cart = '#{update_data[':shoppingCart']}' AND item = '#{update_data[':id']}';") do |stmt|
		    	item = stmt.execute
	 		end
		end
		if item.empty?
			db.transaction do |db_in_transaction|

		   	db_in_transaction.prepare("INSERT INTO shopping_cart_has_item(shopping_cart, item, cant) VALUES(:shoppingCart, :id, :cantidad);") do |stmt|

			    stmt.execute(update_data)

		 	end
		
		end	

		else
			db.transaction do |db_in_transaction|

			   	db_in_transaction.prepare("UPDATE shopping_cart_has_item 
			   								SET  cant = cant + #{update_data[':cantidad']}
			   								WHERE  shopping_cart = '#{update_data[':shoppingCart']}' AND item = '#{update_data[':id']}';") do |stmt|

				    							stmt.execute

										 	end		
			end	


		end
	
	end


	def itemInShoppingCart(aUsername, anItem)
		db = getConnection
		item = []
		db.transaction do |db_in_transaction|
	   		db_in_transaction.prepare("SELECT sci.item FROM shopping_cart_has_item sci
	   									INNER JOIN shopping_carts sc on sci.shopping_cart = sc.id
	   									WHERE sc.username = '#{aUsername}' AND sci.item = '#{anItem}';") do |stmt|
		    	item = stmt.execute
	 		end
		end
		if item.empty?
			false
		else
			true
		end	
	end	

	def deleteItem(aShoppingCartId, anItemId)
		db = getConnection
		numOfItems = 0
		db.transaction do |db_in_transaction|
	   		db_in_transaction.prepare("SELECT cant FROM shopping_cart_has_item 
	   									WHERE shopping_cart = '#{aShoppingCartId}' AND item = '#{anItemId}';") do |stmt|
		    	numOfItems = stmt.execute
	 		end
		end
		if numOfItems[0][0] == 1
			db.transaction do |db_in_transaction|
	   		db_in_transaction.prepare("DELETE FROM shopping_cart_has_item 
	   									WHERE shopping_cart = '#{aShoppingCartId}' AND item = '#{anItemId}';") do |stmt|
		    	stmt.execute
	 		end
		end
		else
			db.transaction do |db_in_transaction|

			   	db_in_transaction.prepare("UPDATE shopping_cart_has_item 
			   								SET  cant = cant - 1
			   								WHERE  shopping_cart = '#{aShoppingCartId}' AND item = '#{anItemId}';") do |stmt|

				    							stmt.execute

										 	end		
			end	

		end
	end	

end