class Cu.View.Subnav extends Backbone.View

class Cu.View.DataHubNav extends Backbone.View
  render: ->
    @$el.html("""<div class="btn-toolbar" id="subnav-path"><h1>#{window.user.effective.displayName}&rsquo;s Data Hub</h1></div>""")
    @

class Cu.View.DatasetNav extends Backbone.View

class Cu.View.DatasetSettingsNav extends Backbone.View

class Cu.View.ViewNav extends Backbone.View