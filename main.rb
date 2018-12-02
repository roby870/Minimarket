Bundler.require(:app)
require_relative 'model/repository'
require_relative 'ValidationErrors.rb'

set :show_exceptions, :after_handler

before do 
	content_type "application/json"
end


get  '/items.json' do 

	items = Repository.obtainInstance.getItems
	#como el modelo devuelve un arreglo de arreglos, necesitamos armar hashes con la clave de cada valor
	#antes de pasar el resultado de la consulta al formato JSON
	itemList = []
	items.each do |row|
		item={id: row[0], sku: row[1], description: row[2]}
		itemList.push(item)
	end
	body "#{JSON.pretty_generate(itemList)}\n"  
	status 200 

end


get '/items/:id.json' do

	result = Repository.obtainInstance.getItem(params['id'])
	if result.empty?
		status 404
	else
		row = result[0]
		item={id: row[0], sku: row[1], description: row[2], stock: row[3], price: row[4]}
		body "#{JSON.pretty_generate(item)}\n"  
		status 200
	end

end	


post  '/items.json' do 
	
	data = JSON.parse request.body.read

	#validaciones y preparacion de los datos para pasarselos al modelo
	insert_data = {}
	raise ValidationErrors::RequiredFieldError if (insert_data[':sku']    = data['sku']).nil?  
	raise ValidationErrors::ExistingSkuError unless Repository.obtainInstance.checkSku(insert_data[':sku']) #comprobamos que no tenemos almacenado un sku igual 
	raise ValidationErrors::RequiredFieldError if (insert_data[':description'] = data['description']).nil? 
	raise ValidationErrors::RequiredFieldError if (insert_data[':stock']  = data['stock']).nil? 
	raise ValidationErrors::RequiredFieldError if (insert_data[':price']    = data['price']).nil?  			
	
	Repository.obtainInstance.addItem(insert_data)
	status 201

	rescue JSON::ParserError
		error = {Error: "La API solamente acepta datos en formato JSON"}
		body "#{JSON.pretty_generate(error)}\n"
		status 415
	rescue ValidationErrors::RequiredFieldError
		error = {Error: "La API solamente crea un nuevo item si recibe todos los parametros: sku, description, stock y price (enviar en ingles el nombre del campo y el contenido en cualquier idioma)"}
		body "#{JSON.pretty_generate(error)}\n"
		status 422
	rescue ValidationErrors::ExistingSkuError
		error = {Error: "El sku del item enviado ya existe"}
		body "#{JSON.pretty_generate(error)}\n"
		status 409

end


put '/items/:id.json' do 

	id = params['id'] 
	result = Repository.obtainInstance.getItem(id)
	if result.empty?
		status 404
	else
		data = JSON.parse request.body.read
		update_data = {}
		
		update_data[:sku] = data['sku'] unless data['sku'].nil?
		raise ValidationErrors::ExistingSkuError unless Repository.obtainInstance.checkSku(update_data[:sku]) #no puede haber en la base atributos sku en null asi que en el caso de que update_data[:sku] sea nil no va a encontrar ningun item con sku seteado en null 
		update_data[:description] = data['description'] unless data['description'].nil?
		update_data[:stock] = data['stock']  unless data['stock'].nil?
		update_data[:price] = data['price']  unless data['price'].nil?
		raise ValidationErrors::RequiredFieldError if update_data.empty?

		Repository.obtainInstance.modifyItem(id, update_data)
		status 200
	end
	rescue JSON::ParserError
		error = {Error: "La API solamente acepta datos en formato JSON"}
		body "#{JSON.pretty_generate(error)}\n"
		status 415
	rescue ValidationErrors::RequiredFieldError
		error = {Error: "Se necesita al menos un parametro en el cuerpo de la peticion (sku, description, stock o price) para poder modificar un item (enviar en ingles el nombre del campo y el contenido en cualquier idioma)"}
		body "#{JSON.pretty_generate(error)}\n"
		status 422
	rescue ValidationErrors::ExistingSkuError
		error = {Error: "El sku enviado ya se encuentra registrado"}
		body "#{JSON.pretty_generate(error)}\n"
		status 409
end


get '/cart/:username.json' do

	shoppingCart = Repository.obtainInstance.userShoppingCart(params['username'])
	if shoppingCart.empty?
		shoppingCart = Repository.obtainInstance.createShoppingCart(params['username'])
		newCart={Carrito: "Creado exitosamente", Fecha_de_creacion: shoppingCart[0][0].to_s, Usuario: params['username']}
		body "#{JSON.pretty_generate(newCart)}\n"
		status 201
	else
		items = Repository.obtainInstance.itemsShoppingCart(params['username'])
		cart = []
		cart.push({Fecha_de_creacion: shoppingCart[0][0].to_s})
		items.each do |row|
			item={item: row[0], cantidad: row[2]}
			cart.push(item)
		end
		price_accumulated = items.inject(0) { |mem, row| mem + (row[1] * row [2]) }
		cart.push({total: price_accumulated})
		body "#{JSON.pretty_generate(cart)}\n"
		status 200
	end

end


put '/cart/:username.json' do
 
	data = JSON.parse request.body.read

	raise ValidationErrors::RequiredFieldError if data['id'].nil?
	raise ValidationErrors::RequiredFieldError if data['cantidad'].nil?
	raise ValidationErrors::CantLessThanOneError if data['cantidad'] < 1
	raise ValidationErrors::StockError unless Repository.obtainInstance.checkStock(data['id'], data['cantidad'])

	update_data = {}
	update_data[':id'] = data['id']
	update_data[':cantidad'] = data['cantidad'].to_i #por si mandan un float
	shoppingCart = Repository.obtainInstance.userShoppingCart(params['username'])
	shoppingCart = Repository.obtainInstance.createShoppingCart(params['username']) if shoppingCart.empty?
	update_data[':shoppingCart'] = shoppingCart[0][1]
	Repository.obtainInstance.addItemToShoppingCart(update_data)
	status 200

	rescue JSON::ParserError
		error = {Error: "La API solamente acepta datos en formato JSON"}
		body "#{JSON.pretty_generate(error)}\n"
		status 415
	rescue ValidationErrors::RequiredFieldError
		error = {Error: "Se necesitan id y cantidad del item en el cuerpo de la peticion para poder agregar uno o mas items al carrito"}
		body "#{JSON.pretty_generate(error)}\n"
		status 422
	rescue ValidationErrors::CantLessThanOneError	
		error = {Error: "La cantidad de items a agregar debe ser al menos 1"}
		body "#{JSON.pretty_generate(error)}\n"
		status 422
	rescue ValidationErrors::StockError
		error = {Error: "No se dispone del stock suficiente para satisfacer el pedido"}
		body "#{JSON.pretty_generate(error)}\n"
		status 422
end

delete '/cart/:username/:item_id.json' do
	shoppingCart = Repository.obtainInstance.userShoppingCart(params['username'])
	if shoppingCart.empty?
		Repository.obtainInstance.createShoppingCart(params['username']) 
		status 201
	else
		raise ValidationErrors::ItemNotInCartError unless Repository.obtainInstance.itemInShoppingCart(params['username'], params['item_id'])
		shoppingCartId = shoppingCart[0][1]
		Repository.obtainInstance.deleteItem(shoppingCartId, params['item_id'])	
		status 200
	end
	rescue ValidationErrors::ItemNotInCartError
		error = {Error: "El item que intenta borrar no se encuentra en el carrito"}
		body "#{JSON.pretty_generate(error)}\n"
		status 422

end

error 500 do #manejando los errores de esta forma evito que al cliente le llegue la pila del error en caso de un error del servidor
	status 500 
end 