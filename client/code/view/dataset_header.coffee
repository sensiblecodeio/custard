class Cu.View.DatasetHeader extends Backbone.View
  el: '#header'
  events:
    'click h1 a': 'logoClicked'
    'click h2 a': 'nameClicked'
    'blur h2 input': 'editableNameBlurred'
    'keypress h2 input': 'enterOnEditableName'

  initialize: ->
    @render()

  render: ->
    @$el.load '/tpl/tool_header', =>
      u = window.user
      @$el.find('h2 a').text @model.name()
      @$el.find('h1').append '<i class="icon-chevron-left"></i>'
      @$el.find('li.user > a').html """
      #{u.displayName} <span class="caret"></span>
         <img src="#{u.avatarUrl}" width="40" height="40" alt="#{u.displayName}" />
      """
      topAndTailDropdowns()
      # Morally: Find all tools that want to add menu items and
      # install a menu item for each one.  Right now: just add
      # the CSV download tool.
      $li = $('<li><a href="#">Download CSV</a></li>')
      $('a', $li).on 'click', (e) =>
        e.preventDefault()
        @model.exec("cd; ./#{@model.get('name')}/download", {dataType: 'json'}).success (data) =>
          $.each data, (i, csv) =>
            @model.publishToken (token) =>
              url = "#{@model.base_url}/#{@model.get 'box'}/#{token}/http/#{csv}"
              $("""<iframe src="#{url}">""").hide().appendTo('body')
      @$el.find('nav .export li:eq(0)').after($li)

   # Rename spike
   logoClicked: (event) ->
     event.preventDefault()
     window.app.navigate "/", {trigger: true}
   
   nameClicked: (event_) ->
     @$el.find('h2 a').hide()
     @$el.find('h2 input').val @model.name()
     @$el.find('h2 input').show 0, ->
       @focus()
       @select()

   editableNameBlurred: ->
     label = @$el.find('h2 a')
     if not label.is(':visible')
       label.show()
       @newName = (@$el.find('h2 input').hide()).val()
       @$el.find('h2 a').text @newName
       @model.save displayName: @newName,
         success: =>
         error: (e) =>
           @$el.find('h2 a').text @model.name()
           console.log e


   enterOnEditableName: (event) ->
     @editableNameBlurred() if event.keyCode is 13
