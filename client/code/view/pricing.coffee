class Cu.View.Pricing extends Backbone.View
  className: 'pricing'

  initialize: (options) ->
    @options = options || {}

  events:
    'click .upgrade': 'upgradeClick'
    'click .downgrade': 'downgradeClick'
    'click .downgrade-now': 'downgradeNowClick'

  render: ->
    options =
      upgrade: @options.upgrade
      free: 'signup'
      large: 'signup'
      enterprise: 'signup'
    plan = window.user?.effective?.accountLevel or ''
    if plan == 'free' or plan == 'free-trial'
      options.free = 'current'
      options.medium = 'upgrade'
      options.large = 'upgrade'
      options.enterprise = 'upgrade'
    else if plan.match /medium/i
      options.free = 'downgrade'
      options.medium = 'current'
      options.large = 'upgrade'
      options.enterprise = 'upgrade'
    else if plan.match /journalist/i
      options.free = 'downgrade'
      options.medium = 'downgrade'
      options.large = 'upgrade'
      options.enterprise = 'upgrade'
    else if plan.match /^large/i
      options.free = 'downgrade'
      options.medium = 'downgrade-now'
      options.large = 'current'
      options.enterprise = 'upgrade'
    else if plan.match /xlarge/i
      options.free = 'downgrade'
      options.medium = 'downgrade-now'
      options.large = 'downgrade-now'
      options.enterprise = 'current'
    else if plan.match(/dataservices/i) or plan.match(/grandfather/i)
      options.free = 'downgrade'
      options.medium = 'downgrade'
      options.large = 'downgrade'
      options.enterprise = 'upgrade'
    @$el.html JST['pricing'] options
    @

  upgradeClick: (e) ->
    e.preventDefault()
    humanPlan = $(e.target).attr('data-plan')
    truePlan = app.truePlan humanPlan
    if window.user.effective?.accountLevel in ['free', 'free-trial']
      # upgrade modal won't work: they need to enter payment details
      window.app.navigate "/subscribe/#{truePlan}", {trigger: true}
    else
      @_modal 'upgrade', truePlan, humanPlan

  downgradeNowClick: (e) ->
    e.preventDefault()
    humanPlan = $(e.target).attr('data-plan')
    truePlan = app.truePlan humanPlan
    @_modal 'downgrade', truePlan, humanPlan

  _modal: (type, truePlan, humanPlan) ->
    # type should be either "upgrade" or "downgrade"
    html = JST["modal-#{type}"] {plan: humanPlan}
    modalWindow = $("""<div class="modal hide fade text-center" style="width: 300px; margin-left: -150px;">#{html}</div>""")
    modalWindow.modal()
    modalWindow.on 'hidden', -> modalWindow.remove()
    modalWindow.on 'click', '.btn-primary', (e) ->
      if type == 'upgrade'
        $(e.target).addClass('loading').html('Upgrading&hellip;')
      else
        $(e.target).addClass('loading').html('Downgrading&hellip;')
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
