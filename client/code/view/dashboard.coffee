class Cu.View.Dashboard extends Backbone.View
  className: 'dashboard row-fluid'

  events:
    'click th.sortable': 'sortTable'

  render: ->
    # Make sure we have the latest list of contexts
    # the current user can access.
    users = Cu.CollectionManager.get Cu.Collection.User
    users.fetch
      success: =>
        users.forEach @appendUserDatasets
    @

  appendUserDatasets: (user) =>
    # Gets all datasets owned by the given `user`
    # and appends them as a list to @$el.
    # `user` should be a backbone user model.

    $header = $ """
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
    $table = $ """
                <table class="table">
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
                  </tbody>
                </table>
                """

    # Get the user's datasets, manually, from the custard API,
    # then feed the raw list of objects into Cu.Collection.Datasets
    # to create a nice collection we can handle as usual.
    $.ajax
      url: "/api/#{user.get 'shortName'}/datasets"
      dataType: 'json'
      success: (datasets) =>
        collection = new Cu.Collection.Datasets datasets
        console.log 'collection', user.get('shortName'), collection
        collection.forEach (dataset) ->
          if dataset.get('state') isnt 'deleted'
            view = new Cu.View.DatasetRow
              model: dataset
              clickable: false
            $('tbody', $table).append view.render().el
        @$el.append $header
        @$el.append $table

  sortTable: (e) ->
    $th = $(e.currentTarget)
    columnNumber = $th.prevAll().length
    if $th.is '.sorted-asc'
      sortOrder = 'desc'
      $th.removeClass('sorted-asc').addClass 'sorted-desc'
    else
      sortOrder = 'asc'
      $th.removeClass('sorted-desc').addClass 'sorted-asc'

    $th.siblings().removeClass 'sorted-asc sorted-desc'

    $('tbody>tr', @$el).tsort 'td:eq(' + columnNumber + ')'
      order: sortOrder
      attr: 'data-sortable-value'
