App.updateTooltips = ->
  $('[data-placement]').each (index, el) ->
    $el = $(el)
    $el.tooltip
      placement: $el.data('placement')
      title: $el.attr('title')

App.hideTooltips = ->
  $('[data-placement]').each (index, el) ->
    $el = $(el)
    $el.tooltip('hide')
  #   title:     "Add new group/feed"
window.setInterval App.hideTooltips, 9000
