class Cu.View.DeletedDataset extends Backbone.View
  className: "deleted-dataset"

  events:
    'click #recover': 'recover'

  render: ->
    console.log @model
    @el.innerHTML = """
                    <h2>That dataset has been deleted.</h2>
                    <a class="btn btn-large" id="recover">Click here to recover the dataset</a>
                    """
    @

  recover: =>
    @$el.find('#recover').addClass('loading').html('Recoving dataset&hellip;')
    @model.recover()
    setTimeout ->
      window.location.reload()
    , 1500

