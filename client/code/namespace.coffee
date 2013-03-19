window.Cu =
  Model: {}
  Collection: {}
  View: {}
  Router: {}
  Helpers:
    # :TODO: this should be in its own file
    showOrAddSSH: (box) =>
      $.ajax
        url: "/api/#{window.user.effective.shortName}/sshkeys"
        success: (sshKeys) ->
          if sshKeys.length == 0
            modalWindow = $(JST['modal-add-ssh']())
            modalWindow.modal().on 'hidden', =>
              modalWindow.remove()
            $(document).on 'click', '#add-ssh-key', ->
              key = modalWindow.find('textarea').val()

              $.ajax
                url: "/api/#{window.user.effective.shortName}/sshkeys",
                type: "POST",
                data: {key: key}
              
              modalWindow.html $(JST['modal-ssh'] box: box).html()
          else
            modalWindow = $(JST['modal-ssh'] box: box)
            modalWindow.modal().on 'hidden', =>
              modalWindow.remove()
          
