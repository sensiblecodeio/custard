class Cu.View.Pricing extends Backbone.View
  className: 'pricing'

  events:
    'click .upgrade': 'upgradeClick'
    'click .downgrade': 'downgradeClick'

  render: ->
    options =
      upgrade: @options.upgrade
      free: 'signup'
      large: 'signup'
    plan = window.user?.effective?.accountLevel or ''
    if plan == 'free'
      options.free = 'current'
      options.large = 'upgrade'
    else if plan.match /medium/i
      options.free = 'downgrade'
      options.large = 'upgrade'
    else if plan.match /journalist/i
      options.free = 'downgrade'
      options.large = 'upgrade'
    else if plan.match /large/i
      options.free = 'downgrade'
      options.large = 'current'
    else if plan.match(/dataservices/i) or plan.match(/grandfather/i)
      options.free = 'downgrade'
      options.large = 'downgrade'
    @$el.html JST['pricing'] options
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
          url: "/api/#{window.user.real.shortName}/subscription/change/#{truePlan}/"
          success: (data) ->
            window.location.reload()
          error: (jqXHR, textStatus, errorThrown) ->
            modalWindow.find('.modal-body').html('Sorry, an error occurred.<br><a href="/contact/" data-nonpushstate>Contact us for help</a>.')
            modalWindow.find('.btn-primary')
              .removeClass('btn-primary loading')
              .addClass('btn-danger')
              .html('Aww shucks!')
      modalWindow.on 'click', '.btn-danger', (e) ->
        modalWindow.modal 'hide'

  downgradeClick: (e) ->
    e.preventDefault()
    $('#intercomButton').trigger('click')
