$(document)
  .on 'input', '#search-field', (event) ->
    console.log('search field input')
    # make AJAX request after delay passes
    # on result hide .playlist and set html for .search-results
  
  .on 'click', '.search-result', (event) ->
    console.log('search result selected')
    # show a drop down message that song was queued (TweetBot style)
