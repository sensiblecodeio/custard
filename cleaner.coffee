DatabaseCleaner = require "database-cleaner"
databaseCleaner = new DatabaseCleaner "mongodb"
connect = require("mongodb").connect
connect "mongodb://localhost/cu-test", (err, db) ->
  databaseCleaner.clean db, ->
    console.log "done"
    db.close()
