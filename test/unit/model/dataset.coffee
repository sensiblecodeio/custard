sinon = require 'sinon'
should = require 'should'
helper = require '../helper'

helper.evalConcatenatedFile 'client/code/app.coffee'
#helper.evalConcatenatedFile 'client/code/model/dataset.coffee'

describe 'Model: Dataset', ->

describe 'Collection: DatasetList', ->
