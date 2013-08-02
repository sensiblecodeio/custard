#!/usr/bin/env coffee

mongoose = require 'mongoose'
_ = require 'underscore'
mongoose.connect process.env.CU_DB

{Dataset} = require 'model/dataset'

main = (TheDataset) ->
  TheDataset.findToBeDeleted (err, datasets)->
    _.each datasets, (dataset) ->
      dataset.cleanCrontab()

if require.main == module
  main(Dataset)
  process.exit()

exports.main = main
