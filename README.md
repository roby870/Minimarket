Luego de clonar el repositorio se debe ejecutar en una terminal, en el directorio del proyecto clonado:

bundle install 

para instalar todas las gemas que necesita el proyecto. Luego, en el subdirectorio Model, ejecutar el script setDB mediante el siguiente comando:

bundle exec ruby setDB.rb

Se trata de un script que crea la base de datos sobre la que corre la API. El archivo que contiene la base de datos se guarda en el mismo directorio donde se ubica el script de configuracion ejecutado. 

En el directorio raiz del proyecto clonado ejecutar para que corra la API:

bundle exec ruby main.rb 

Se la detiene mediante ctrl + c
