$(document)
  .on 'input', '#search-field', (event) ->
    console.log('search field input')
  
  .on 'click', '.search-result', (event) ->
    console.log('search result selected')
