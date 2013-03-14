class App.Subscriptions extends Backbone.Collection
  initialize: () ->
    this.fetch
      success: _.bind(this.readyHandler, this)

    window.setInterval(->
      App.subscriptions.each (sub) -> sub.fetch()
    , 1000*60*5)

  readyHandler: () ->
    App.startRouter()
    App.groups.each (group) =>
      group.updateCounts()


  model: App.Subscription
  url: '/subscriptions.json'
  ready: false

  destroySubscription: (key) ->
    sub = this.where({id:parseInt(key)})
    if sub.length > 0
      sub = sub[0]
      sub.confirmDestroy()

  comparator: (item) ->
    item.get('weight')
