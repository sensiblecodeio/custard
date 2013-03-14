class Cu.View.PeoplePack extends Backbone.View
  className: "toolpack"

  render: ->
    @el.innerHTML = JST['people-pack']()
    @