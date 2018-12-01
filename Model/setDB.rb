#ejecutar con bundle exec (ponerlo en readme). No subir al repo la DB, solamente este archivo de configuracion
#al ejecutar este archivo crea la base, la tabla y se guarda en el mismo directorio que este archivo 
Bundler.require(:repository)
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

