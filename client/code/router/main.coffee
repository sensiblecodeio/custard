window.MainRouter = class MainRouter extends Backbone.Router
  routes:
    "": "main"


  main: ->
    new HomeHeaderView()
    #new HomeContentView()

