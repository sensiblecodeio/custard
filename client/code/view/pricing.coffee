class Cu.View.Pricing extends Backbone.View
  className: 'pricing'

  events:
    'click .upgrade': 'upgradeClick'

  render: ->
    @el.innerHTML = JST['pricing'] upgrade: @options.upgrade
    if @options.upgrade and window.user.effective?.accountLevel
      @$el.find(".account-#{window.user.effective.accountLevel}").prev().addClass('glowing')
    @

  upgradeClick: (e) ->
    e.preventDefault()
    if window.user.effective?.accountLevel is 'free'
      truePlan = app.truePlan $(e.target).attr('data-plan')
      window.app.navigate "/subscribe/#{truePlan}", {trigger: true}
