class Cu.View.HomeContent extends Backbone.View
  events:
    'click #tools .metro-tile': 'clickTool'

  el: '#content'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tpl/home_content', =>
      @addTools()
    
  addTools: ->
    @collection.each @addTool

  addTool: (tool) =>
    @$el.find('#tools').append """
      <div class="metro-tile #{tool.get 'name'}">
          <h3>#{tool.get 'displayName'}</h3>
      </div>
    """

  clickTool: (event) ->
    # TODO: refactor into Tool view
    name = ($(event.target).first().attr 'class').split(' ')[1]
    window.app.navigate "tool/#{name}", {trigger: true}


