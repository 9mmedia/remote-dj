searchTimer = 0
jqXHR = null

$(document)
  .on 'input', '#q', (event) ->
    console.log('search field input')

    searchResults = $('.js-search-results')
    searchQuery = $(this).val()

    if searchQuery is ''
      searchResults.empty()
    else
      clearTimeout(searchTimer)
      jqXHR.abort() if jqXHR

      searchTimer = setTimeout( ->

        jqXHR = $.ajax
          url: '/search'
          data:
            q: searchQuery
          error: (xhr) ->
            console.log('error searching')
          success: (data) ->
            searchResults.html(data)

      , 500)

  .on 'click', '.search-result', (event) ->
    message = $('.js-song-queued').addClass('show')
    $(this).addClass('queued')
    setTimeout( ->
      message.removeClass('show')
    , 1000)
