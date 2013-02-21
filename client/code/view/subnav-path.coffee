class Cu.View.Subnav extends Backbone.View

class Cu.View.DataHubNav extends Backbone.View
  events:
    'click .context-switch li': 'liClick'
    'click .new-dataset': 'showChooser'

  render: ->
    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group context-switch">
          <a class="btn btn-link dropdown-toggle" data-toggle="dropdown">
            <img src="#{window.user.effective.avatarUrl}" width="32" height="32" />#{window.user.effective.displayName}&rsquo;s data hub<span class="caret"></span>
          </a>
          <ul class="dropdown-menu">
            <li class="search"><input type="search" placeholder="Switch profile&hellip;"></li>
            <li><a href="#">Another action</a></li>
          </ul>
        </h1>
      </div>
      <div class="btn-toolbar" id="subnav-options">
        <div class="btn-group">
          <a class="btn new-dataset"><i class="icon-plus"></i> New Dataset</a>
        </div>
        <div class="btn-group">
          <input type="text" class="input-medium search-query">
        </div>
      </div>""")
    @

  liClick: (e) ->
    # stops the dropdown menu disappearing when you click inside it
    e.stopPropagation()

  showChooser: ->
    # :TODO: We shouldn't be fetching tools in here.
    if window.tools.length == 0
      window.tools.fetch
        success: ->
          t = new Cu.View.ToolList {collection: window.tools}
          $('body').append t.render().el
        error: (x,y,z) ->
          console.warn 'ERRROR', x, y, z
    else
      t = new Cu.View.ToolList {collection: window.tools}
      $('body').append t.render().el


class Cu.View.DatasetNav extends Backbone.View
  render: ->
    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link">
            <img src="#{window.user.effective.avatarUrl}" width="32" height="32" />#{window.user.effective.displayName}&rsquo;s data hub</span>
          </a>
        </h1>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <div class="btn-group editable">
          <a class="btn btn-link">[dataset.displayName]</a>
        </div>
      </div>""")
    @

class Cu.View.DatasetSettingsNav extends Backbone.View
  render: ->
    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link">
            <img src="#{window.user.effective.avatarUrl}" width="32" height="32" />#{window.user.effective.displayName}&rsquo;s data hub</span>
          </a>
        </h1>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <div class="btn-group">
          <a class="btn btn-link">[dataset.displayName]</a>
        </div>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <div class="btn-group">
          <a class="btn btn-link">Settings</a>
        </div>
      </div>""")
    @

class Cu.View.ViewNav extends Backbone.View
  render: ->
    @$el.html("""
      <div class="btn-toolbar" id="subnav-path">
        <h1 class="btn-group">
          <a class="btn btn-link">
            <img src="#{window.user.effective.avatarUrl}" width="32" height="32" />#{window.user.effective.displayName}&rsquo;s data hub</span>
          </a>
        </h1>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <div class="btn-group">
          <a class="btn btn-link">[dataset.displayName]</a>
        </div>
        <div class="btn-group">
          <span class="slash">/</span>
        </div>
        <div class="btn-group editable">
          <a class="btn btn-link">[view.displayName]</a>
        </div>
      </div>""")
    @