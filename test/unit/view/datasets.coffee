fs = require 'fs'

$ = jQuery = require 'jquery'
sinon = require 'sinon'
should = require 'should'
eco = require 'eco'

helper = require '../helper'

helper.evalConcatenatedFile 'client/code/app.coffee'
describe 'View: Datasets', ->
  before (done) ->
    srcPath = 'client/template/dataset.eco'
    source = fs.readFileSync(srcPath)
    global.JST ?= {}
    global.JST['dataset'] = eco.compile source.toString()

    global.window.app = {navigate: ->}
    $('body').html '<div id="content"></div>'
    views = new Backbone.Collection
    models = [
      new Backbone.Model {_id: 1, name: 'test', displayName: 'Test', boxName: 'sdfsd', views: views}
      new Backbone.Model {_id: 2, name: 'test2', displayName: 'Test 2', boxName: 'sasdas', views: views}
      new Backbone.Model {_id: 3, name: 'test3', displayName: 'Test 3', boxName: 'sasisdfdas', views: views}
    ]

    datasets = new Backbone.Collection models
    @view = new Cu.View.DatasetList collection: datasets
    @view.render()
    done()

   it 'renders the datasets', ->
     @view.$el.find('h3')[0].innerHTML.should.equal 'Test'
     @view.$el.find('h3')[1].innerHTML.should.equal 'Test 2'
     @view.$el.find('h3')[2].innerHTML.should.equal 'Test 3'
