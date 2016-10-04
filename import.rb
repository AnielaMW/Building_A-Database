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
