class Cu.View.ContextSearchLink extends Backbone.View
  tagName: 'li'
  className: 'context context-search-result'
  
  # :TODO: Use this function to highlight the search query in the context displayNames/shortNames
  _highlightSubstring: (string, substring, open='<b>', close='</b>') ->
    # eg: _highlightSubstring('ScraperWiki', 'wi') -returns-> 'Scraper<b>Wi</b>ki'
    index = string.toLowerCase().indexOf substring.toLowerCase()
    if index > -1
      len = substring.length
      return string.substr(0, index) + open + string.substr(index, len) + close + string.substr(index + len)
    else
      return string

  render: ->
    @$el.html JST.contextsearchlink @options
    @