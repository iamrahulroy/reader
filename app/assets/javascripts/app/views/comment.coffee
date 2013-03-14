class App.CommentView extends Backbone.View
  template: HandlebarsTemplates['comments/comment']
  initialize: ->
  render: ->
    ctx = this.model.toJSON()
    ctx.following = _(App.people.pluck("id")).include(this.model.get("user_id"))
    html = this.template ctx
    this.$el.append html