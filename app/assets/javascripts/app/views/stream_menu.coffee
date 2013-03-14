
class App.StreamMenuView extends Backbone.View
  initialize: ->

  events:
    'click .view-items-collapsed': "toggleCollapsedView"
    'click .group-menu-group': "moveToGroup"
    'click .favorite': "toggleFavorite"

  template: HandlebarsTemplates['stream_menu']
  render: =>
    ctx = {}
    ctx.subscription = (App.subscriptions.include(App.stream))
    ctx.stream = App.stream?
    ctx.favorite = App.stream.get("favorite")
    ctx.anonymous = App.user.anonymous()

    groups = App.groups.map (g) ->
      name: g.get("name") || "Top Level"
      key: g.get("key")
      current: (g.id == App.stream.get("group_id"))

    ctx.groups = groups

    if App.stream?
      ctx.id = App.stream.get('id')
    html = this.template ctx
    this.$el.html html

  toggleFavorite: (evt) =>
    App.stream.set("favorite", !App.stream.get("favorite"))
    App.stream.save()
    if App.stream.get("favorite")
      $(evt.currentTarget).find("i").removeClass("icon-heart-empty")
      $(evt.currentTarget).find("i").addClass("icon-heart")
    else
      $(evt.currentTarget).find("i").removeClass("icon-heart")
      $(evt.currentTarget).find("i").addClass("icon-heart-empty")

  moveToGroup: (evt) =>
    key = $(evt.target).data("group-key")
    group = App.groups.find (group) ->
      (group.get('key') == key)

    App.stream.set("group_id", group.id)
    App.stream.save()
    @render()
    $sub = App.stream.renderer.$el
    $grp = group.listView.$el.find(".group-list-drop-target")
    console.log $grp
    console.log $sub
    $sub.prependTo($grp)
#    debugger
#    TODO: get the subscription to re-parent to the selected group


  toggleCollapsedView: =>
    v = App.stream.get("item_view")
    if v == "collapsed"
      v = ""
    else
      v = "collapsed"
    App.stream.set("item_view", v)
    App.stream.save()
    App.stream.view()
