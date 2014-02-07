#!/usr/bin/env coffee

mongoose = require 'mongoose'
async = require 'async'
mongoose.connect process.env.CU_DB

{Dataset} = require 'model/dataset'

CLI = false

main = (TheDataset) ->
  TheDataset.findToBeDeleted (err, datasets)->
    async.each datasets, (dataset, cb) ->
      dataset.cleanCrontab (err) ->
        console.warn(dataset.box, err) if err?
        cb()
    , (err) ->
      console.warn(err) if err?
      process.exit() if CLI?

if require.main == module
  CLI = true
  process.env.NODE_ENV = 'cron'
  main(Dataset)

exports.main = main
