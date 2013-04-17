class Cu.View.DatasetTools extends Backbone.View
  className: 'dropdown-menu pull-right'
  tagName: 'div'
  id: 'dataset-tools'

  initialize: ->
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
    @

  addToolArchetype: (toolModel) =>
    # This is called once per tool archetype. Each time
    # it adds either 0 or 1 menu items. The added item is either a tool instance
    # (if there is an instance of the archetype toolModel) or the tool
    # archetype (if there are no instances of the archetype and the archetype
    # is one of the basic archetypes).
    # Secret Fun Fact: If you end up in the situation where you have more than
    # one instance of a particular archetype, then you'll get more than one menu
    # item; in violation of what I just said. That's okay, because that can't happen.
    # The setTimeout thing is because we can't work out Backbone (Relational) model loading:
    # without the setTimeout, instance.get('tool') is undefined.
    setTimeout =>
      if toolModel.isBasic()
        v = new Cu.View.ArchetypeMenuItem { archetype: toolModel, dataset: @model }
        $('.archetypes', @$el).append v.render().el
    , 0

  addToolInstance: (instance) =>
    id = "instance-#{instance.get 'box'}"
    l = $("##{id}", @$el)
    if l.length > 0
      # Already added as a menu item; don't add again.
      return
    if not instance.get 'tool'
      # Tool relation not loaded yet, so we don't know what to display.
      return
    v = new Cu.View.ToolMenuItem model: instance
    if instance instanceof Cu.Model.Dataset
      # So that the tool that imported is at the top.
      $('.tools', @$el).prepend v.render().el
    else
      $('.tools', @$el).append v.render().el
