class Cu.View.DatasetTools extends Backbone.View
  id: 'dataset-tools'
  events:
    'click .tool': 'toolClick' 

  initialize: ->
    if @options.view?
      @selectedTool = @options.view
    else
      @selectedTool = @model
    window.selectedTool = @selectedTool

    @toolInstances = @model.get('views').visible()
    app.tools().on 'add', @addToolArchetype, @
    @model.on 'update:tool', @addToolInstance, @
    @model.get('views').on 'update:tool', @addToolInstance, @

  render: ->
    @$el.html """<ul class="tools"></ul>
      <ul class="archetypes"></ul>
      <ul class="more">
        <li><a class="new-view">More tools&hellip;</a></li>
      </ul>"""
    @addToolInstance @model
    views = @model.get('views').visible()
    views.each (view) =>
      @addToolInstance view
    app.tools().each (archetype) =>
      @addToolArchetype archetype
    @

  toolClick: (e) ->
    $('.tool.active').removeClass("active")
    $(e.currentTarget).addClass("active")
    e.preventDefault()

  addToolArchetype: (toolModel) ->
    # The setTimeout thing is because we can't work out Backbone (Relational) model loading:
    # without the setTimeout, instance.get('tool') is undefined.
    setTimeout =>
      if toolModel.isBasic()
        item = $("[data-toolname=#{toolModel.get 'name'}]", @$el)
        if item.length > 0
          return
        v = new Cu.View.ArchetypeMenuItem { archetype: toolModel, dataset: @model }
        $('.archetypes', @$el).append v.render().el
    , 0

  addToolInstance: (instance) ->
    id = "instance-#{instance.get 'box'}"
    l = $("##{id}", @$el)
    if not instance.isVisible()
      # Don't show "hidden" tool instances
      return
    if l.length > 0
      # Already added as a menu item; don't add again.
      return
    if not instance.get 'tool'
      # Tool relation not loaded yet, so we don't know what to display.
      return
    v = new Cu.View.ToolMenuItem model: instance
    el = v.render().el
    $('a', el).addClass('active') if instance is @selectedTool
    $('.tools', @$el).append el
