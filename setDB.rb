#ejecutar con bundle exec (ponerlo en readme). No subir al repo la DB, solamente este archivo de configuracion
require 'Amalgalite'

db = Amalgalite::Database.new("Minimarket.db")

db.execute <<-SQL
  CREATE TABLE items (
    id      INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    sku    VARCHAR(128),
    description VARCHAR(32),
    stock  INTEGER(128),
    price  FLOAT(128)
  );
  SQL

#al ejecutar este archivo crea la base, la tabla y se guarda en el mismo directorio que este archivo 
#la primera vez que lo ejecute me abrio el servidor webrick con una app sinatra, porque Bundle require incluia Sinatra, para que eso no pase
#se debe requerir solamente la gema de la base pero ejecutar con bundle require

