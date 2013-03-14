Handlebars.registerHelper('filter', () ->
  App.filter
)

Handlebars.registerHelper('list_item_class', (label) ->
  if (label)
    'indent'
)

Handlebars.registerHelper('urlencode', (val) ->
  escape(val)
)

Handlebars.registerHelper('focused_item', () ->
  if App.focusedItem?
    if App.focusedItem.id == this.id
      'focused'
)

App.truncate = (subject, length, trail='') ->
  return unless subject
  if (subject.length > (length + trail.length))
    subject.substr(0, length) + trail
  else
    subject

App.filterOnUnread = ->
  App.filter = 'unread'
  App.renderFeedList()

App.filterOnStarred = ->
  App.filter = 'starred'
  App.renderFeedList()

App.filterOnShared = ->
  App.filter = 'shared'
  App.renderFeedList()

App.filterOnAll = ->
  App.filter = 'all'
  App.renderFeedList()
