class App.Stream extends Backbone.Model
  constructor: () ->
    super

  count: () ->
    @get("#{App.filter}_count")

  clearStream: ->
    App.items?.reset()
    stream = $('#stream')
    stream.removeClass("commented-items")
    stream.empty()
    $(window).scrollTop(0)
    App.streamTitle.set('title', "")
    App.streamTitle.set('link', "")
    App.streamTitle.setCount(0)

  view: =>
    @clearStream()
    if @ == App.commented
      stream = $('#stream')
      stream.addClass("commented-items")
    @loadItems (items) =>
      App.items = new App.Items(items)
      App.stream = @
      App.viewStream(@.get('name'), @.get('site_url'))

  loadItems: (cb) =>
    App.itemLoaderXHR?.abort()
    url = @.items_url()
    if App.itemIdClickedFromSummary?
      url = url.replace "items.json", "item/#{App.itemIdClickedFromSummary}/items.json"
      App.itemIdClickedFromSummary = null
    App.itemLoaderXHR = $.post(url, {ids: @ids()})
      .done((data) ->
        cb(data))
      .always(()->
        App.itemLoaderXHR = null
        App.hideList()
      )

  ids: =>
    App.items?.pluck("id")

  items_url: =>
    @.get("items_url")

  count_url: =>
    "#{@.get("items_url")}?count=true"

  prev: () =>
    links = $(".#{@streamType}-link")
    link = $(".#{@streamType}-link[data-stream-id='" + @.get("id") + "']")
    index = links.index(link) - 1
    return if index < 0
    if links.length > index
      id = $(links[index]).attr("data-stream-id")
      n = @getStreamCollection().get(id)
      if n.count() > 0
        return n
      else
        nxt = n.prev()
        if nxt?
          return nxt
        else
          return @getStreamCollection().last()

  next: () =>
    links = $(".#{@streamType}-link")
    link = $(".#{@streamType}-link[data-stream-id='" + @.get("id") + "']")
    nextIndex = links.index(link) + 1

    if links.length > nextIndex
      nextID = $(links[nextIndex]).attr("data-stream-id")
      n = @getStreamCollection().get(nextID)
      if n.count() > 0
        return n
      else
        nxt = n.next()
        if nxt?
          return nxt
        else
          return @getStreamCollection().first()