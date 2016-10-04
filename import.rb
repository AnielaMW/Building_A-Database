# Use this file to import data from the CSV and populate your database

require "pg"
require "csv"

psql building-database < schema.sql

def db_connection
  begin
    connection = PG.connect(dbname: "building-database")
    yield(connection)
  ensure
    connection.close
  end
end
