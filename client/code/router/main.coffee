class Cu.Router.Main extends Backbone.Router
  tools: ->
    Cu.CollectionManager.get Cu.Collection.Tools

  datasets: ->
    Cu.CollectionManager.get Cu.Collection.Datasets

  initialize: ->
    @appView = new Cu.AppView '#content'
    @subnavView = new Cu.AppView '#subnav'
    @overlayView = new Cu.AppView '#overlay'
    @navView ?= new Cu.View.Nav()
    @errorView ?= new Cu.View.ErrorAlert el: '#error-alert'
    @on 'route', @errorView.hide
    @on 'route', @trackPageView
    @on 'route', @checkDaysLeft

    # TODO: this isn't a great place for this constant
    window.latestTerms = 1

    if window.user?.real
      if isNaN(window.user.real.acceptedTerms) or window.user.real.acceptedTerms < window.latestTerms
        @termsAlertView = new Cu.View.TermsAlert
        $("#header").after @termsAlertView.render().el

    # Backbone seems to reverse route order
    # TODO: revert to standard routes?
    for view in ScraperwikiViews
      @route RegExp(view.route), view.name

  trackPageView: (e) ->
    path = Backbone.history.getFragment()

  checkDaysLeft: (route) ->
    # Here we enforce the policy that expired free-trial users
    # cannot use their datahub. A selected number of URLs are
    # blocked here if the user has an expired free-trial. These
    # URLs are identified by the names of routes (the 2nd
    # argument to @route, see many calls above).

    user = window.user.effective
    # If we're not logged in, none of this applies.
    if not user
      return
    # Early exit if not on free-trial...
    if user.accountLevel != 'free-trial'
      return
    # or if we have some days left.
    if user.daysLeft > 0
      return

    blocked = route in [
      'homeLoggedIn'
      'dashboard'
      'toolChooser'
      'dataset'
      'datasetSettings'
      'datasetToolChooser'
      'view'
    ]
    if blocked
      # Navigate to the pricing page.
      # app.navigate doesn't work, but setting location.href does.
      # app.navigate "/pricing/expired", trigger: true
      window.location.href = "/pricing/expired"

  homeAnonymous: ->
    contentView = new Cu.View.Home
    @appView.showView contentView
    @subnavView.hideView()

  homeLoggedIn: ->
    $('#content').empty()
    app.tools().fetch().done =>
      contentView = new Cu.View.DatasetList
      subnavView = new Cu.View.DataHubNav
      @appView.showView contentView
      @subnavView.showView subnavView

  dashboard: ->
    contentView = new Cu.View.Dashboard
    window.document.title = 'Your dashboard | QuickCode'
    @appView.showView contentView
    @subnavView.hideView()

  pricing: (upgrade) ->
    subnavView = new Cu.View.Subnav PageTitles.pricing
    contentView = new Cu.View.Pricing upgrade: upgrade
    @appView.showView contentView
    @subnavView.showView subnavView

  signUp: (plan) ->
    contentView = new Cu.View.SignUp {plan: plan}
    subnavView = new Cu.View.SignUpNav {plan: plan}
    @appView.showView contentView
    @subnavView.showView subnavView

  thankyou: ->
    contentView = new Cu.View.Thankyou
    @appView.showView contentView
    @subnavView.hideView()

  toolChooser: ->
    chooserView = new Cu.View.ToolList {type: 'importers'}
    @overlayView.showView chooserView

  datasetToolChooser: (box) ->
    model = Cu.Model.Dataset.findOrCreate box: box
    model.fetch
      success: =>
        chooserView = new Cu.View.ToolList
          type: 'nonimporters'
          dataset: model
        @overlayView.showView chooserView

  subscribe: (truePlan) ->
    # TODO: make this a backbone model
    # TODO: handle unknown plan in sign api?
    shortName = window.user.effective.shortName
    humanPlan = window.app.humanPlan truePlan
    capitalisedPlan = humanPlan.toUpperCase()[0] + humanPlan.toLowerCase()[1..]
    $.ajax
      type: 'GET'
      url: "/api/#{shortName}/subscription/#{truePlan}/sign"
      success: (signature) =>
        contentView = new Cu.View.Subscribe {plan: truePlan, signature: signature}
        subnavView = new Cu.View.SignUpNav {plan: capitalisedPlan}
        @appView.showView contentView
        @subnavView.showView subnavView

  _ifDatasetIsNotDeleted: (model, callback) ->
    if model.get('state') == 'deleted'
      contentView = new Cu.View.DeletedDataset { model: model }
      @appView.showView contentView
      @subnavView.hideView()
    else
      callback()


  dataset: (box) ->
    model = Cu.Model.Dataset.findOrCreate box: box, merge: true
    toolsDone = app.tools().fetch()
    modelDone = model.fetch()

    modelDone.fail (jqXHR, textStatus, errorThrown) =>
      # 404? Reload the page directly from the server, so it can either render
      # a nice 404 page, or automatically switch the user into the right context.
      if jqXHR.status == 404
        window.aboutToClose = true
        window.location.reload()

    $.when.apply( null, [modelDone, toolsDone] ).done =>
      @_ifDatasetIsNotDeleted model, =>
        views = model.get 'views'
        unless @subnavView.currentView instanceof Cu.View.Toolbar
          subnavView = new Cu.View.Toolbar {model: model}
          @subnavView.showView subnavView
          window.selectedTool = model

        setTimeout =>
          views.findByToolName 'datatables-view-tool', (dataTablesView) =>
            if dataTablesView?
              window.selectedTool = dataTablesView
              subnavView = new Cu.View.Toolbar {model: model, view: dataTablesView}
              @subnavView.showView subnavView
              contentView = new Cu.View.PluginContent {model: dataTablesView}
              @appView.showView contentView
              contentView.showContent()
            else
              app.navigate "/dataset/#{model.id}/settings", trigger: true
        , 0

  datasetSettings: (box) ->
    mod = Cu.Model.Dataset.findOrCreate box: box
    mod.fetch
      success: (model) =>
        @_ifDatasetIsNotDeleted model, =>
          window.selectedTool = model
          unless @subnavView.currentView instanceof Cu.View.Toolbar
            subnavView = new Cu.View.Toolbar model: model
            @subnavView.showView subnavView
          contentView = new Cu.View.AppContent model: model
          @appView.showView contentView
          contentView.showContent()
      error: (_model, jqXHR) ->
        # 404? Reload the page directly from the server, so it can either render
        # a nice 404 page, or automatically switch the user into the right context.
        if jqXHR.status == 404
          window.aboutToClose = true
          window.location.reload()

  view: (datasetID, viewID) ->
    dataset = Cu.Model.Dataset.findOrCreate
      user: window.user.effective.shortName
      box: datasetID

    dataset.fetch
      success: (dataset, resp, options) =>
        @_ifDatasetIsNotDeleted dataset, =>
          v = dataset.get('views').findById(viewID)
          if not v?
            Backbone.trigger 'error', null, {responseText: "View not found"}
            return
          window.selectedTool = v
          contentView = new Cu.View.PluginContent model: v
          @appView.showView contentView
          contentView.showContent()
          unless @subnavView.currentView instanceof Cu.View.Toolbar
            subnavView = new Cu.View.Toolbar model: dataset, view: v
            @subnavView.showView subnavView
      error: (_model, jqXHR) ->
        # 404? Reload the page directly from the server, so it can either render
        # a nice 404 page, or automatically switch the user into the right context.
        if jqXHR.status == 404
          window.aboutToClose = true
          window.location.reload()

  peoplePack: ->
    subnavView = new Cu.View.ToolShopNav {name: 'People Pack', url: '/tools/people-pack'}
    contentView = new Cu.View.PeoplePack()
    @appView.showView contentView
    @subnavView.showView subnavView

  createProfile: ->
    if window.user.real.isStaff
      subnavView = new Cu.View.Subnav PageTitles['create-profile']
      contentView = new Cu.View.CreateProfile()
    else
      subnavView = new Cu.View.Subnav PageTitles['404']
      contentView = new Cu.View.FourOhFour()
    @appView.showView contentView
    @subnavView.showView subnavView

  resetPassword: ->
    subnavView = new Cu.View.Subnav PageTitles['reset-password']
    contentView = new Cu.View.ResetPassword()
    @appView.showView contentView
    @subnavView.showView subnavView

  setPassword: (token) ->
    $.ajax
      url: "/api/token/#{token}"
      dataType: 'json'
      success: (tokenInfo) =>
        if tokenInfo.shortName?
          @shortName = tokenInfo.shortName
        else
          Backbone.trigger 'error', null, {responseText: "no shortName!"}
      complete: =>
        subnavView = new Cu.View.Subnav PageTitles['set-password']
        contentView = new Cu.View.SetPassword {shortName: @shortName}
        @appView.showView contentView
        @subnavView.showView subnavView

  fourOhFour: ->
    subnavView = new Cu.View.Subnav PageTitles['404']
    contentView = new Cu.View.FourOhFour()
    @appView.showView contentView
    @subnavView.showView subnavView

  help: (section) ->
    section ?= 'home'
    subnavView = new Cu.View.HelpNav PageTitles["help-#{section}"]
    contentView = new Cu.View.Help {template: "help-#{section}"}
    @appView.showView contentView
    @subnavView.showView subnavView

  terms: ->
    subnavView = new Cu.View.Subnav PageTitles['terms']
    contentView = new Cu.View.Terms()
    @appView.showView contentView
    @subnavView.showView subnavView

  termsEnterpriseAgreement: ->
    subnavView = new Cu.View.Subnav PageTitles['terms-enterprise-agreement']
    contentView = new Cu.View.TermsEnterpriseAgreement()
    @appView.showView contentView
    @subnavView.showView subnavView

