class App.SubscriptionCountUpdate
  constructor: ->
    minutes = 60*1000
    update = _.throttle @updateSubscriptionCountsFromServer, 60*1000
    Visibility.every 5 * minutes, 60 * minutes, => update
  
  updateSubscriptionCountsFromServer: ->
    App.subscriptions.each (sub) -> sub.fetch()
