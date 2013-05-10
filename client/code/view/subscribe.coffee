class Cu.View.Subscribe extends Backbone.View
  className: 'subscribe'

  render: ->
    $('#footer').remove()
    @el.innerHTML = JST['subscribe'] @options
    $.getScript "/vendor/js/recurly.js", =>
      splitDisplayName = window.user.effective.displayName.split ' '
      Recurly.config
        subdomain: window.recurlyDomain
        currency: 'USD'
        country: 'GB'
        VATPercent: '20'
      Recurly.buildSubscriptionForm
        target: '#recurly-subscribe'
        accountCode: window.user.effective.recurlyAccount
        planCode: @options.plan
        distinguishContactFromBillingInfo: true
        collectCompany: true
        enableCoupons: false
        enableAddOns: false
        acceptedCards: ['mastercard', 'visa']
        account:
          firstName: splitDisplayName[0]
          lastName: splitDisplayName[splitDisplayName.length - 1]
          email: window.user.effective.email[0]
        billingInfo:
          firstName: splitDisplayName[0]
          lastName: splitDisplayName[splitDisplayName.length - 1]
        signature: @options.signature
        beforeInject: @beforeInject
        successHandler: @onSuccessfulTransaction

  onSuccessfulTransaction: (token) ->
    shortName = window.user.effective.shortName
    $.ajax
      type: 'POST'
      url: "/api/#{shortName}/subscription/verify"
      data:
        recurly_token: token
      success: (result) =>
        window.location = '/'
      error: (err) =>
        alert err

   beforeInject: ->
     # TODO: move to eco
     $('form').prepend('<h2 class="introduction">Almost there! Just enter your payment details.</h2>')
     $('.footer', $('form')).prepend('<a href="/pricing/" class="back">&larr; Go back to pricing plans</a>')
     $('.country select', $('form')).val('US').trigger('change')
