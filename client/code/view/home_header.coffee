# TODO: Refactor into one view, base class/mixin if really necessary
class Cu.View.HomeHeader extends Backbone.View
  el: '#header'

  initialize: ->
    @render()

  render: ->
    @$el.empty()
    @$el.load '/tpl/home_header', =>
      u = window.user.effective
      if u?.displayName?
        @$el.find('li.user > a').html """
        #{u.displayName} <span class="caret"></span>
           <img src="#{u.avatarUrl}" width="40" height="40" alt="#{u.displayName}" />
        """
      topAndTailDropdowns()

