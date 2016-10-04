# Use this file to import data from the CSV and populate your database

require "pg"
require "csv"

def db_connection
  begin
    connection = PG.connect(dbname: "building-database")
    yield(connection)
  ensure
    connection.close
  end
end

data = CSV.foreach('data.csv')

db_connection do |conn|
  data.each do |record|
    conn.exec_params("INSERT INTO accounts (name, zoning_type_id, construction_type_id) VALUES ($1, $2, $3);", [record[0], zoning(record[1].to_i), constructing(record[2].to_i)])
  end
end

def zoning(zoning_type)
  db_zoning = conn.exec("SELECT * FROM zoning_types;")
  unless db_zoning.include?(zoning_type)
    conn.exec("INSERT INTO zoning_types (name) VALUES ($1);", [zoning_type])
  end
  conn.exec("SELECT id FROM zoning_types WHERE zoning_types.name = '#{zoning_type}';")
end

def constructing(construction_type)
  db_construction = conn.exec("SELECT * FROM construction_types")
  unless db_construction.include?(construction_type)
    conn.exec("INSERT INTO construction_types (name) VALUES ($1);", [construction_type])
  end
  conn.exec("SELECT id FROM construction_types WHERE construction_types.name = '#{construction_type}';")
end
