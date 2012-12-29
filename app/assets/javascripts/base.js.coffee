# Hide address bar in iOS Safari (http://24ways.org/2011/raising-the-bar-on-mobile/)
if !window.location.hash and window.addEventListener
  window.addEventListener "load", ->
    setTimeout( ->
      window.scrollTo 0, 0
    , 0)

$(document)
  .on 'click', '.search-result', (event) ->
    element = $(this).addClass('label-queuing')
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
        element.removeClass('label-queuing').addClass('label-queued')
        message = $('.js-song-queued').addClass('show')
        setTimeout( ->
          message.removeClass('show')
        , 1500)
