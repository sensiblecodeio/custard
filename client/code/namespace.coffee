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
            modalWindow.modal()
            modalWindow.on 'hidden', ->
              modalWindow.remove()
            modalWindow.on 'shown', ->
              clip = new ZeroClipboard $('.zeroclipboard')[0], { moviePath: "/vendor/js/ZeroClipboard.swf" }
              clip.on "complete", -> $(@).html '<i class="icon-ok space"></i> Copied!'

            $(document).on 'click', '#add-ssh-key', ->
              key = modalWindow.find('textarea').val()

              $.ajax
                url: "/api/#{window.user.effective.shortName}/sshkeys",
                type: "POST",
                data: {key: key}
              
              modalWindow.html $(JST['modal-ssh'] box: box).html()
              clip = new ZeroClipboard $('.zeroclipboard')[0], { moviePath: "/vendor/js/ZeroClipboard.swf" }
              clip.on "complete", -> $(@).html '<i class="icon-ok space"></i> Copied!'
          else
            modalWindow = $(JST['modal-ssh'] box: box)
            modalWindow.modal()
            modalWindow.on 'hidden', ->
              modalWindow.remove()
            modalWindow.on 'shown', ->
              clip = new ZeroClipboard $('.zeroclipboard')[0], { moviePath: "/vendor/js/ZeroClipboard.swf" }
              clip.on "complete", -> $(@).html '<i class="icon-ok space"></i> Copied!'
