class Cu.View.SignUp extends Backbone.View
  className: 'sign-up'
  events:
    'click #go': 'go'
    'keyup #displayName': 'keyupDisplayName'
    'keyup #shortName': 'keyupShortName'
    'blur #shortName': 'keyupDisplayName'

  initialize: (options) ->
    @options = options || {}

  render: ->
    @el.innerHTML = JST['sign-up']()

  go: (e) ->
    e.preventDefault()
    $('#go', @$el).addClass('loading').html('Creating Account&hellip;')

    @cleanUpForm()

    model = new Cu.Model.User
    model.on 'invalid', @displayErrors, @

    subscribingTo = app.cashPlan @options.plan
    model.save
      shortName: $('#shortName').val()
      email: $('#email').val()
      displayName: $('#displayName').val()
      subscribingTo: subscribingTo
      acceptedTerms: if $('#acceptedTerms').is(':checked') then window.latestTerms else 0
      emailMarketing: $('#emailMarketing').is(':checked')
    ,
      success: (model, response, options) =>
        plan = app.truePlan @options.plan
        if plan?
          # Note: not logged in, but going to use in the /subscribe page
          window.user = effective: model.toJSON()
          app.navigate "/subscribe/#{plan}", trigger: true
        else
          app.navigate "/thankyou", trigger: true
      error: (model, response, options) =>
        $('#go', @$el).removeClass('loading').html('Go!')

        if response.responseText
          # Probably an xhr object.
          xhr = response
          jsonResponse = JSON.parse xhr.responseText
          $div = $("""<div class="alert alert-error" id="hghg"><strong>#{jsonResponse.error or "Something went wrong"}<strong></div>""")
          #TODO: don't prepend, as we end up with multiple alerts
          @$el.prepend $div
          if jsonResponse.code == 'username-duplicate'
            # :todo: Add password reset link.
            $div.append(""" Is that you? We have emailed you a password reset link.""")
          else
            # Don't really know what the error is, so say something technical and geeky.
            $div.append("""<code>#{JSON.stringify jsonResponse}</code>""")

  displayErrors: (model_, errors) ->
    $('#go', @$el).removeClass('loading').html('<i class="icon-ok space"></i> Create Account')
    for key of errors
      $("##{key}").parents('.controls').append("""<span class="help-inline">#{errors[key]}</span>""").parents('.control-group').addClass('error')

  cleanUpForm: ->
    $('.control-group.error', @$el).removeClass('error').find('.help-inline').remove()

  keyupShortName: (e) ->
    if $(e.target).val() == ''
      $(e.target).removeClass('edited')
    else
      $(e.target).addClass('edited')

  keyupDisplayName: ->
    # "is" is a reserved word in coffeescript, so we use
    # long form method notation for the .is() jQuery function!!
    if not $('#shortName')['is']('.edited')
      username = $('#displayName').val()
      username = username.toLowerCase().replace(/[^a-zA-Z0-9-.]/g, '')
      $('#shortName').val(username)
