searchTimer = 0
jqXHR = null

$(document)
  .on 'input', '#q', (event) ->
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

  .on 'keydown', '#q', (event) ->
    if event.keyCode is 27
      $(this).val('').trigger('input')

  .on 'click', '.search-result', (event) ->
    element = $(this)
    $.ajax
      url: '/queue'
      type: 'POST'
      data:
        album: element.data('album')
        'artists[]': element.data('artist')
        title: element.data('title')
        url: element.data('url')
      error: (xhr) ->
        console.log('error queueing song')
      success: (data) ->
        element.addClass('label-queued')
        message = $('.js-song-queued').addClass('show')
        setTimeout( ->
          message.removeClass('show')
        , 1000)
