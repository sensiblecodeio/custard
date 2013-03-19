class Cu.View.DatasetActions extends Backbone.View
  className: 'dataset-actions'
  tagName: 'ul'

  events:
    'click .hide-dataset': 'hideDataset'
    'click .rename-dataset': 'renameDataset'
    'click .dataset-settings': 'datasetSettings'
    'click .git-ssh': 'showOrAddSSH'

  render: ->
    @$el.html """
      <li><a class="rename-dataset"><img src="/image/icon-rename.png" width="16" height="16" /> Rename dataset</a></li>
      <li><a class="dataset-settings"><img src="/image/icon-settings.png" width="16" height="16" /> Edit dataset settings</a></li>
      <li><a class="git-ssh"><img src="/image/icon-terminal.png" width="16" height="16" /> Git clone or SSH in</a></li>
      <li><a class="hide-dataset"><img src="/image/icon-cross.png" width="16" height="16" /> Hide dataset</a></li>"""
    
    # we have to manually bind the modal submit click handler,
    # because backbone events (above) are bound to ul.dataset-actions,
    # and our modal is a child of the body.
    $(document).on 'click', '#add-ssh-key', @addSSHKey
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

  showOrAddSSH: =>
    if window.user.effective?.sshKeys?.length > 0
      @showSSH()
    else
      @addSSH()

  addSSH: =>
    @modalWindow = $(JST['modal-add-ssh']())
    @modalWindow.modal().on 'hidden', =>
      @modalWindow.remove()

  showSSH: =>
    @modalWindow = $(JST['modal-ssh'] box: @model.get('box'))
    @modalWindow.modal().on 'hidden', =>
      @modalWindow.remove()
  
  addSSHKey: =>
    key = @modalWindow.find('textarea').val()

    $.ajax
      url: "/api/#{window.user.effective.shortName}/sshkeys",
      type: "POST",
      data: {key: key}

    window.user.effective.sshKeys.push key
    
    @modalWindow.html $(JST['modal-ssh'] box: @model.get('box')).html()

  datasetSettings: ->
    # :TODO: this is a bit of a hack
    $('a.dataset.tile').trigger('click')
