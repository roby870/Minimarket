Bundler.require(:repository)
db = Amalgalite::Database.new("Minimarket.db")

db.execute <<-SQL
  CREATE TABLE items (
    id      INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    sku    VARCHAR(128),
    description VARCHAR(256),
    stock  INTEGER(128),
    price  FLOAT(128)
  );
  SQL

  db.execute <<-SQL
  CREATE TABLE shopping_carts (
    id      INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
   	username VARCHAR(128),
  	created DATE
  );
  SQL

  db.execute <<-SQL
  CREATE TABLE shopping_cart_has_item (
    shopping_cart INTEGER(128),
   	item INTEGER(128),
   	cant INTEGER(128)
  );
  SQL