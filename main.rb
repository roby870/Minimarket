#modularizar en distintos archivos la parte del modelo, o sea las consultas y la conexion a la base
#las validaciones hacerlas con params. No asumir que se recibe json, la decodificacion la hace sinatra
#con validar se refieren a chequear que estan todos los parametros, no a si son del tipo de dato correspondiente 
Bundler.require 

set :show_exceptions, :after_handler

db = Amalgalite::Database.new("Minimarket.db") #retorna la base o la crea si no existe

before do 
	content_type "application/json"
end



get  '/items.json' do 

	items = []
	db.transaction do |db_in_transaction|
	   	db_in_transaction.prepare("SELECT id, sku, description FROM items;") do |stmt|
		    items = stmt.execute
	 	end
	end
	#como el metodo de Amalgalite devuelve un arreglo de arreglos, necesitamos armar hashes con la clave de cada valor
	#antes de pasar el resultado de la consulta al formato JSON
	itemList = []
	items.each do |row|
		item={id: row[0], sku: row[1], description: row[2]}
		itemList.push(item)
	end
	body "#{JSON.pretty_generate(itemList)}\n"  
	status 200 

end

post  '/items.json' do 
	data = JSON.parse request.body.read 
										
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
	status 201
	rescue JSON::ParserError
		body "La API solamente acepta datos en formato JSON\n"
		status 415
	rescue
		status 422
end

error 500 do #manejando los errores de esta forma evito que al cliente le llegue la pila del error en caso de un error del servidor
	status 500 
end 