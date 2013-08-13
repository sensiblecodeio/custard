class Cu.View.ToolTile extends Backbone.View
  className: 'tool swcol'
  tagName: 'a'

  attributes: ->
    'data-nonpushstate': ''

  render: ->
    @$el.html JST['tool-tile'] @model.toJSON()
    @$el.addClass @model.get('name')
    @

  checkInstall: (e) ->
    @install(e) unless @active

  clicked: (e) ->
    e.stopPropagation()
    @checkInstall e

  showLoading: ->
    $inner = @$el.find('.tool-icon-inner')
    $inner.empty().css('background-image', 'none')
    @spinner = Spinners.create($inner, {
      radius: 7,
      height: 8,
      width: 2.5,
      dashes: 12,
      opacity: 1,
      padding: 3,
      rotation: 1000,
      color: '#fff'
    }).play()

class Cu.View.AppTile extends Cu.View.ToolTile
  events:
    'click' : 'clicked'

  install: (e) ->
    e.preventDefault()
    @active = true
    @showLoading()
    @createDataset()

  # TODO: DRY with RPC call
  createDataset: ->
    dataset = Cu.Model.Dataset.findOrCreate
      displayName: @model.get('manifest').displayName
      tool: @model
    app.datasets().add dataset
    dataset.new = true
    dataset.save {},
      wait: true
      success: =>
        _gaq.push ['_trackEvent', 'tools', 'install', @model.get 'name']
        _gaq.push ['_trackEvent', 'datasets', 'create']
        delete dataset.new
        window.app.navigate "/dataset/#{dataset.id}/settings", {trigger: true}
        $('#chooser').fadeOut 200, ->
          $(this).remove()
      error: (model, xhr, options) =>
        @active = false
        dataset.destroy()
        if xhr.status is 402
          @trigger 'install:failed'
          app.navigate '/pricing/upgrade', trigger: true
        else
          Backbone.trigger 'error', model, xhr, options

class Cu.View.PluginTile extends Cu.View.ToolTile
  events:
    'click' : 'clicked'

  install: (e) ->
    e.preventDefault()
    @active = true
    @showLoading()

    dataset = Cu.Model.Dataset.findOrCreate
      user: window.user.effective.shortName
      box: @options.dataset.id

    dataset.fetch
      success: (dataset, resp, options) =>
        dataset.installPlugin @model.get('name'), (err, view) =>
          if err == "already installed"
            view = @options.dataset.get('views').findWhere(tool: @model)
            $('#toolbar .tool.active').removeClass('active')
            $("#instance-#{view.id}").addClass('active')
            window.app.navigate "/dataset/#{dataset.id}/view/#{view.id}", {trigger: true}
          else
            Backbone.trigger('error', null, """{"responseText": "#{err}"}""") if err?
            v = new Cu.View.ToolMenuItem model: view
            el = v.render().el
            $('a', el).addClass('active')
            $('#toolbar .tool.active').removeClass("active")
            $('#toolbar .tools').append el
            _gaq.push ['_trackEvent', 'tools', 'install', @model.get 'name']
            _gaq.push ['_trackEvent', 'views', 'create']
            window.app.navigate "/dataset/#{dataset.id}/view/#{view.id}", trigger: true

          $('#chooser').fadeOut 200, ->
            $(this).remove()
      error: (model, xhr, options) ->
        @active = false
        @$el.removeClass 'loading'
        Backbone.trigger 'error', model, xhr, options
