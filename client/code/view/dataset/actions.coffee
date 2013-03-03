class Cu.View.DatasetActions extends Backbone.View
  className: 'dataset-actions'
  tagName: 'ul'

  events:
    'click .hide-dataset': 'hideDataset'
    'click .rename-dataset': 'renameDataset'

  render: ->
    @$el.html """
      <li><a class="hide-dataset"><i class="space icon-remove"></i> Hide dataset</a></li>
      <li><a class="rename-dataset"><i class="space icon-pencil"></i> Rename dataset</a></li>
      <li><a class="transfer-dataset"><i class="space icon-user"></i> Transfer ownership</a></li>
      <li><a class="ssh-git"><i class="space icon-arrow-down"></i> Git clone or SSH in</a></li>"""
    @

  hideDataset: ->
    @model.save {state: 'deleted'},
      success: (model, response, options) =>
        window.app.navigate "/", {trigger: true}
      error: (model, xhr, options) =>
        alert('Sorry, the dataset could not be hidden')
        console.warn 'Dataset could not be hidden!', model, xhr, options

  renameDataset: ->
    $('#subnav-path .editable').trigger('click')