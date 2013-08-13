class Cu.View.Terms extends Backbone.View
  className: "terms"

  render: ->
    @el.innerHTML = JST['terms']()
    @

class Cu.View.TermsEnterpriseAgreement extends Backbone.View
  className: "terms"

  render: ->
    @el.innerHTML = JST['terms-enterprise-agreement']()
    @

class Cu.View.TermsAlert extends Backbone.View
  className: "alert alert-warning permanent"

  events:
    "click #acceptTerms": "acceptTerms"

  render: ->
    @el.innerHTML = '''<p class="container"><strong>Our Terms &amp; Conditions have changed.</strong> <a href="/terms/">Read them here</a> then accept the changes. <a id="acceptTerms" class="btn btn-warning btn-small pull-right"><i class="icon-ok icon-white space"></i> I accept</a></p>
    '''
    @

  acceptTerms: ->
    user = new Cu.Model.User window.user.real
    user.save 'acceptedTerms', window.latestTerms,
      type: 'put' # force backbone to issue a PUT, even though it thinks this is a new model
      success: (model, response, options) =>
        window.user.real.acceptedTerms = window.latestTerms
        @$el.slideUp 250, =>
          @$el.remove()
