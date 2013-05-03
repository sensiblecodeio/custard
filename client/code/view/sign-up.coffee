# :todo: really should extract this information from the API.
planConvert =
  explorer: 'medium'
  datascientist: 'large'

# Translate from user-visible plan to
# the shortname used for the plan on the subscribe page.
# Only returns a non-null string for paid plans.
truePlan = (plan) ->
  planConvert[plan]

# Return the user-visible name of the plan, but only when that
# is a paid plan.
cashPlan = (plan) ->
  plan if plan of planConvert

class Cu.View.SignUp extends Backbone.View
  className: 'sign-up'
  events:
    'click #go': 'go'
    'keyup #displayName': 'keyupDisplayName'
    'keyup #shortName': 'keyupShortName'
    'blur #shortName': 'keyupDisplayName'

  render: ->
    @el.innerHTML = JST['sign-up']
      plan: cashPlan @options.plan

  go: (e) ->
    e.preventDefault()
    $('#go', @$el).addClass('loading').html('Creating Account&hellip;')

    @cleanUpForm()

    model = new Cu.Model.User
    model.on 'invalid', @displayErrors, @

    subscribingTo = cashPlan @options.plan
    model.save
      shortName: $('#shortName').val()
      email: $('#email').val()
      displayName: $('#displayName').val()
      inviteCode: $('#inviteCode').val()
      subscribingTo: subscribingTo
      acceptedTerms: if $('#acceptedTerms').is(':checked') then 1 else 0
    ,
      success: (model, response, options) =>
        console.log model, response, options
        plan = truePlan @options.plan
        if plan?
          # Note: not logged in, but going to use in the /subscribe page
          window.user = effective: model.toJSON()
          app.navigate "/subscribe/#{plan}", trigger: true
        else
          $('form').hide()
          $('#thanks').show()
      error: (model, response, options) =>
        $('#go', @$el).removeClass('loading').html('Go!')

        console.warn model, response, options
        if response.responseText
          # Probably an xhr object.
          xhr = response
          jsonResponse = JSON.parse xhr.responseText
          $div = $("""<div class="alert alert-error" id="hghg"><strong>#{jsonResponse.error or "Something went wrong"}<strong></div>""")
          #TODO: don't prepend, as we end up with multiple alerts
          @$el.prepend $div
          if jsonResponse.code == 'username-duplicate'
            # :todo: Add password reset link.
            $div.append(""" Is that you? If we had a password reset link, we'd give it to you now.""")
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
