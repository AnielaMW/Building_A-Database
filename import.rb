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
    db_zoning = conn.exec("SELECT name FROM zoning_types;").to_a
    zoning_array = db_zoning.map { |zone_hash| zone_hash["name"] }
    unless zoning_array.include?(zoning_type)
      conn.exec_params("INSERT INTO zoning_types (name) VALUES ($1);", [zoning_type])
    end
    conn.exec("SELECT id FROM zoning_types WHERE zoning_types.name = '#{zoning_type}';").to_a[0]["id"].to_i
  end
end

def constructing(construction_type)
  db_connection do |conn|
    # I wanted this to work, but it did not and I don't know why. Maybe ask an EE later this week.
      # unless conn.exec_params("SELECT name FROM construction_types WHERE name = $1", [construction_type])
      #   conn.exec_params("INSERT INTO construction_types (name) VALUES ($1);", [construction_type])
      # end
    db_construct = conn.exec("SELECT name FROM construction_types;").to_a
    construct_array = db_construct.map { |construct_hash| construct_hash["name"] }
    unless construct_array.include?(construction_type)
      conn.exec_params("INSERT INTO construction_types (name) VALUES ($1);", [construction_type])
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
