# Backbone seems to reverse route order

ScraperwikiViews = [
  {name: 'fourOhFour', route: RegExp('.*')},
  {name: 'homeAnonymous', route: RegExp('^/?$')},
  {name: 'homeLoggedIn', route: RegExp('^datasets?/?$')},
  {name: 'dashboard', route: RegExp('^dashboard/?$')},
  {name: 'help', route: RegExp('(?:docs|help)/?')},
  {name: 'help', route: RegExp('(?:docs|help)/([^/]+)/?')},
  {name: 'pricing', route: RegExp('pricing/?')},
  {name: 'pricing', route: RegExp('pricing/([^/]+)/?')},
  {name: 'toolChooser', route: RegExp('chooser/?')},
  {name: 'peoplePack', route: RegExp('tools/people-pack/?')},
  {name: 'dataset', route: RegExp('dataset/([^/]+)/?')},
  {name: 'datasetSettings', route: RegExp('dataset/([^/]+)/settings/?')},
  {name: 'datasetToolChooser', route: RegExp('dataset/([^/]+)/chooser/?')},
  {name: 'view', route: RegExp('dataset/([^/]+)/view/([^/]+)/?')},
  {name: 'createProfile', route: RegExp('create-profile/?')},
  {name: 'resetPassword', route: RegExp('set-password/?')},
  {name: 'setPassword', route: RegExp('set-password/([^/]+)/?')},
  {name: 'signUp', route: RegExp('signup/([^/]+)/?')},
  {name: 'subscribe', route: RegExp('subscribe/([^/]+)/?')},
  {name: 'thankyou', route: RegExp('thankyou/?')},
  {name: 'terms', route: RegExp('terms/?')},
  {name: 'termsEnterpriseAgreement', route: RegExp('terms/enterprise-agreement/?')},
]

if exports?
  exports.ScraperwikiViews = ScraperwikiViews
else
  window.ScraperwikiViews = ScraperwikiViews