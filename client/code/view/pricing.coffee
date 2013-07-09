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
    humanPlan = $(e.target).attr('data-plan')
    truePlan = app.truePlan humanPlan
    if window.user.effective?.accountLevel is 'free'
      window.app.navigate "/subscribe/#{truePlan}", {trigger: true}
    else
      # show modal!!
      html = JST['modal-upgrade'] {plan: humanPlan}
      modalWindow = $("""<div class="modal hide fade text-center" style="width: 300px; margin-left: -150px;">#{html}</div>""")
      modalWindow.modal()
      modalWindow.on 'hidden', -> modalWindow.remove()
      modalWindow.on 'click', '.btn-primary', (e) ->
        $(e.target).addClass('loading').html('Upgrading&hellip;')
        $.ajax
          type: 'PUT',
          url: "/api/#{req.user.real.shortName}/subscription/change/#{truePlan}/"
          success: (data) ->
            window.location.reload()
          error: (jqXHR, textStatus, errorThrown) ->
            modalWindow.find('.modal-body').html('Sorry, an error occurred. <a href="/contact/">Contact us for help</a>.')
            modalWindow.find('.btn-primary').removeClass('btn-primary').addClass('btn-danger')
      modalWindow.on 'click', '.btn-danger', (e) ->
        modalWindow.hide()
