# Backbone seems to reverse route order

ScraperwikiViews = [
  {route: '.*', name: 'fourOhFour'},
  {route: '$', name: 'homeAnonymous'},
  {route: 'datasets?/?$', name: 'homeLoggedIn'},
  {route: 'dashboard/?$', name: 'dashboard'},
  {route: '(?:docs|help)/?', name: 'help'},
  {route: '(?:docs|help)/([^/]+)/?', name: 'help'},
  {route: 'pricing/?', name: 'pricing'},
  {route: 'pricing/([^/]+)/?', name: 'pricing'},
  {route: 'chooser/?', name: 'toolChooser'},
  {route: 'tools/people-pack/?', name: 'peoplePack'},
  {route: 'dataset/([^/]+)/?', name: 'dataset'},
  {route: 'dataset/([^/]+)/settings/?', name: 'datasetSettings'},
  {route: 'dataset/([^/]+)/chooser/?', name: 'datasetToolChooser'},
  {route: 'dataset/([^/]+)/view/([^/]+)/?', name: 'view'},
  {route: 'create-profile/?', name: 'createProfile'},
  {route: 'set-password/?', name: 'resetPassword'},
  {route: 'set-password/([^/]+)/?', name: 'setPassword'},
  {route: 'signup/([^/]+)/?', name: 'signUp'},
  {route: 'subscribe/([^/]+)/?', name: 'subscribe'},
  {route: 'thankyou/?', name: 'thankyou'},
  {route: 'terms/?', name: 'terms'},
  {route: 'terms/enterprise-agreement/?', name: 'termsEnterpriseAgreement'},
]

if exports?
  exports.ScraperwikiViews = ScraperwikiViews
else
  window.ScraperwikiViews = ScraperwikiViews