# Use this file to import data from the CSV and populate your database

require "pg"
require "csv"
require 'pry'

system "psql building-database < schema.sql"

def db_connection
  begin
    connection = PG.connect(dbname: "building-database")
    yield(connection)
  ensure
    connection.close
  end
end

def zoning(zoning_type)
  db_connection do |conn|
    db_zoning = conn.exec("SELECT name FROM zoning_types;")
    unless db_zoning.include?(zoning_type)
      conn.exec("INSERT INTO zoning_types (name) VALUES ($1);", [zoning_type])
    end
    conn.exec("SELECT id FROM zoning_types WHERE zoning_types.name = '#{zoning_type}';").to_a[0]["id"].to_i
  end
end

def constructing(construction_type)
  db_connection do |conn|
    db_construction = conn.exec("SELECT name FROM construction_types")
    unless db_construction.include?(construction_type)
      conn.exec("INSERT INTO construction_types (name) VALUES ($1);", [construction_type])
    end
    conn.exec("SELECT id FROM construction_types WHERE construction_types.name = '#{construction_type}';").to_a[0]["id"].to_i
  end
end

@data = CSV.foreach('data.csv', headers: true)

db_connection do |conn|
  @data.each do |record|
    @zoning = zoning(record[1].downcase)
    @constructing = constructing(record[2].downcase)
    conn.exec_params("INSERT INTO accounts (name, zoning_type_id, construction_type_id) VALUES ($1, $2, $3);", [record[0], @zoning, @constructing])
  end
end
