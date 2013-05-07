class Cu.View.Terms extends Backbone.View
  className: "terms"

  render: ->
    @el.innerHTML = JST['terms']()
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
    @$el.slideUp 250, ->
      @$el.remove()

