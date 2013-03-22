class App.SubscriptionCountUpdate
  constructor: ->
    minutes = 60*1000
    Visibility.every 5 * minutes, 60 * minutes, => @updateSubscriptionCountsFromServer()
  
  updateSubscriptionCountsFromServer: ->
    App.subscriptions.each (sub) -> sub.fetch()
