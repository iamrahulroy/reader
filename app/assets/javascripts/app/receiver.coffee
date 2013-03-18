
class App.Receiver
  startPrivatePubSub: () =>
    $.get("/pps", @.insertPPS)

  insertPPS: (data, status, xhr) ->
    $("body").append(data)

  addComment: (comment_json) =>
    items = @.findItems(comment_json)
    comment = new App.Comment(comment_json)
    _(items).each (item) ->
      item.set("has_new_comments", true)
      item.comments.add(comment)
    App.items.checkForNewComments()

  removeComment: (id) =>
    comment = @.findComment(id)
    items = @.findItems(comment)
    _(items).each (item) ->
      item.comments.remove(comment)

  updateComment: (comment_json) =>
    @.removeComment(comment_json)
    @.addComment(comment_json)
    App.items.checkForNewComments()

  findItems: (comment_json) =>
    items = App.items.filter (item) ->
      (item.get('parent_id') == comment_json.item_id || item.get('id') == comment_json.item_id)
    items

  findSub: (sub_json) =>
    sub = App.subscriptions.get(sub_json.id)

  findComment: (id) =>
    App.comments.get(id)

  addSubscription: (sub_json) =>
    if App.subscriptions?
      sub = @.findSub(sub_json)
      if sub
        console.log "updating sub: #{sub.get("name")}"
        sub.set sub_json
#        sub.render()
      else
        sub = new App.Subscription(sub_json)
        App.subscriptions.add(sub)
    else
      console.log "delay addSubscription"
      _.delay(@addSubscription, 50, sub_json)


$(document).ready ->
  App.receiver = new App.Receiver()
  App.receiver.startPrivatePubSub()