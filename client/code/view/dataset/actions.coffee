class Cu.View.DatasetActions extends Backbone.View
  className: 'dataset-actions'
  tagName: 'ul'

  events:
    'click .hide-dataset': 'hideDataset'
    'click .rename-dataset': 'renameDataset'
    'click .dataset-settings': 'datasetSettings'
    'click .git-ssh': ->
      Cu.Helpers.showOrAddSSH @model, 'dataset'

  render: ->
    @$el.html """
      <li><a class="rename-dataset"><img src="/image/icon-rename.png" width="16" height="16" /> Rename dataset</a></li>
      <li><a class="dataset-settings"><img src="/image/icon-settings.png" width="16" height="16" /> Edit dataset settings</a></li>
      <li><a class="git-ssh"><img src="/image/icon-terminal.png" width="16" height="16" /> Git clone or SSH in</a></li>
      <li><a class="hide-dataset"><img src="/image/icon-cross.png" width="16" height="16" /> Hide dataset</a></li>"""
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

  datasetSettings: ->
    # :TODO: this is a bit of a hack
    $('a.dataset.tile').trigger('click')
