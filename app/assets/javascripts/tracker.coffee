class Tracker
  initialize: ->

  track: (key, props) =>
    return
    if App.environment == "production"
      if App.user.id != 3 && App.user.id != 2
        mixpanel.track(key, props)

window.tracker = new Tracker()
