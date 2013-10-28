SubNav =
  'help-home':
    text: "Help"
  'help-corporate':
    text: 'Corporate FAQs'
  'help-whats-new':
    text: "What's new?"
  'help-developer':
    text: "Developer FAQs"
  'help-zig':
    text: "ZIG"
  'help-twitter-search':
    text: "Scrape Tweets and download as a spreadsheet"
  'help-upload-and-summarise':
    text: 'Upload and summarise a spreadsheet of data'
  'help-code-in-your-browser':
    text: 'Code a scraper in your browser'
  'help-make-your-own-tool':
    text: 'Make your own tool with HTML, JavaScript & Python'
  'help-scraperwiki-classic':
    text: 'One-stop ScraperWiki Classic user guide'
  'terms':
    text: 'Terms & Conditions'
  'terms-enterprise-agreement':
    text: 'ScraperWiki Enterprise Agreement'
  'pricing':
    text: 'Pricing'
  'sign-up':
    text: 'Sign up'
  'index':
    text: ''

if exports?
  exports.SubNav = SubNav
else
  window.SubNav = SubNav
