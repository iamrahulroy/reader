class App.User extends Backbone.Model
  initialize: ->

  url: =>
    "/users/#{this.id}.json"

  anonymous: =>
    this.get('anonymous')
