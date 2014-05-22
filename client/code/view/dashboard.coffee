class Cu.View.Dashboard extends Backbone.View
  className: 'dashboard row-fluid'

  initialize: (options) ->
    @options = options || {}

  events:
    'click th.sortable': 'sortTable'
    'click #show-only-errors': 'toggleErrors'

  render: ->
    @$el.html """
              <label id="show-only-errors"><input type="checkbox"> Show only failing datasets</label>
              """

    # Make sure we have the latest list of contexts
    # the current user can access.
    users = Cu.CollectionManager.get Cu.Collection.User
    users.fetch
      success: =>
        users.forEach @appendUserDatasets
    @

  toggleErrors: (e) ->
    $nonErrorRows= @$el.find('tbody tr').not('.error')
    $input = $(e.currentTarget).children 'input'
    if $input.is ':checked'
      $('section', @$el).each ->
        $allRows = $(this).find 'tbody tr'
        $nonErrorRows = $(this).find('tbody tr').not '.error'
        if $nonErrorRows.length == $allRows.length
          $(this).addClass 'empty'
        else
          $nonErrorRows.hide()
    else
      $('section', @$el).removeClass('empty').find('tr:hidden').show()

  appendUserDatasets: (user) =>
    # Gets all datasets owned by the given `user`
    # and appends them as a list to @$el.
    # `user` should be a backbone user model.

    $section = $ """<section data-shortName="#{user.get 'shortName'}">"""
    $section.append """
                    <div class="dashboard-subheader">
                      <a href="/switch/#{user.get 'shortName'}" data-nonpushstate>
                        <h1>
                          <img src="#{user.get('logoUrl') or user.get('avatarUrl')}" alt="#{user.get 'shortName'}" />
                          #{user.get 'displayName' or user.get 'shortName'}
                          <small>Switch into data hub &raquo;</small>
                        </h1>
                      </a>
                    </div>
                    """

    arrows = '<i class="icon-chevron-up"></i><i class="icon-chevron-down"></i>'
    $section.append $ """
                      <table class="table table-hover">
                        <thead>
                          <tr>
                            <th class="icon"></th>
                            <th class="name sortable">Name #{arrows}</th>
                            <th class="status sortable">Status #{arrows}</th>
                            <th class="updated sortable">Last run #{arrows}</th>
                            <th class="creator sortable">Created by #{arrows}</th>
                            <th class="created sortable">Created #{arrows}</th>
                            <th class="hide"></th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr class="loading">
                            <td colspan="7"><img src="/image/loader-input-search.gif" width="16" height="16" /> Loading datasets&hellip;</td>
                          </tr>
                        </tbody>
                      </table>
                      """
    @$el.append $section

    # Get the user's datasets, manually, from the custard API,
    # then feed the raw list of objects into Cu.Collection.Datasets
    # to create a nice collection we can handle as usual.
    $.ajax
      url: "/api/#{user.get 'shortName'}/datasets"
      dataType: 'json'
      success: (datasets) =>
        if datasets.length
          collection = new Cu.Collection.Datasets datasets
          collection.forEach (dataset) ->
            if dataset.get('state') isnt 'deleted'
              view = new Cu.View.DatasetRow
                model: dataset
                clickable: true
              $('tr.loading', $section).remove()
              $('tbody', $section).append view.render().el
        else
          $('tr.loading', $section).remove()
      error: () =>
        $('tbody', $section).html """
                                  <tr class="ajax-error">
                                    <td colspan="7"><img src="/image/exclamation-red.png" width="16" height="16" /> Could not load datasets</td>
                                  </tr>
                                  """

  sortTable: (e) ->
    # work out which header to sort on
    $th = $(e.currentTarget)
    columnNumber = $th.prevAll().length
    $ths = $("thead>tr>th:nth-child(#{columnNumber+1})", @$el)
    if $th.is '.sorted-asc'
      sortOrder = 'desc'
      $ths.removeClass('sorted-asc').addClass 'sorted-desc'
    else
      sortOrder = 'asc'
      $ths.removeClass('sorted-desc').addClass 'sorted-asc'

    # remove sort classes for the other headers
    $ths.siblings().removeClass 'sorted-asc sorted-desc'

    # sort the table bodies
    $('tbody>tr', @$el).tsort "td:eq(#{columnNumber})",
      order: sortOrder
      attr: 'data-sortable-value'
