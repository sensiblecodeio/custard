window.Cu =
  Model: {}
  Collection: {}
  View: {}
  Router: {}
  Helpers:
    showOrAddSSH: (box) =>
      if window.user.effective.sshKeys.length == 0
        modalWindow = $(JST['modal-add-ssh']())
        modalWindow.modal().on 'hidden', =>
          modalWindow.remove()
        $(document).on 'click', '#add-ssh-key', ->
          key = modalWindow.find('textarea').val()

          $.ajax
            url: "/api/#{window.user.effective.shortName}/sshkeys",
            type: "POST",
            data: {key: key}

          window.user.effective.sshKeys.push key
          
          modalWindow.html $(JST['modal-ssh'] box: box).html()
      else
        modalWindow = $(JST['modal-ssh'] box: box)
        modalWindow.modal().on 'hidden', =>
          modalWindow.remove()
      
