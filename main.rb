#modularizar en distintos archivos la parte del modelo, o sea las consultas y la conexion a la base
#las validaciones hacerlas con params. No asumir que se recibe json, la decodificacion la hace sinatra
#con validar se refieren a chequear que estan todos los parametros, no a si son del tipo de dato correspondiente 
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

	item = Repository.obtainInstance.getItem(params['id'])




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
		error = {Error: "La API solamente crea un nuevo item si recibe todos los parametros: sku, descripcion, stock y precio"}
		body "#{JSON.pretty_generate(error)}\n"
		status 422
	rescue ValidationErrors::ExistingSkuError
		error = {Error: "El sku del item enviado ya existe"}
		body "#{JSON.pretty_generate(error)}\n"
		status 409

end

error 500 do #manejando los errores de esta forma evito que al cliente le llegue la pila del error en caso de un error del servidor
	status 500 
end 