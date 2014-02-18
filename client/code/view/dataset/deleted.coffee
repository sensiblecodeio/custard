class Cu.View.DeletedDataset extends Backbone.View
  className: "deleted-dataset"

  events:
    'click #recover': 'recover'

  render: ->
    console.log @model
    @el.innerHTML = """
                    <h2>That dataset has been deleted.</h2>
                    <a class="btn btn-large" id="recover">Contact us for recovery</a>
                    """
    @

  recover: =>
    window.Intercom('show')

