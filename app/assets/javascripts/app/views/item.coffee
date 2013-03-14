
class App.ItemView extends Backbone.View
  events:
    'click .btn-star':"toggleStar"
    'click .btn-share':"toggleShare"
    'click .btn-keep-unread':"keepUnread"
    'dblclick .item-content-inner img': "expandImage"
    'click .item-expander':"expandCommentedItem"
    'click .item-collapser': "collapseCommentedItem"
    'click .item.collapsed .item-head': "expandItem"
    'click .btn-tweet': "tweetItem"
    'click .btn-facebook': "facebookItem"

  initialize: =>
    this.model.on('item:render', this.render)
    this.model.on('item:tweeted', this.afterTweeted)
    this.model.on('item:facebooked', this.afterFacebooked)

  afterFacebooked: =>
    this.$el.find(".btn-facebook").addClass('btn-on')

  afterTweeted: =>
    this.$el.find(".btn-tweet").addClass('btn-on')

  tweetItem: =>
    @model.postToTwitter()

  facebookItem: =>
    @model.postToFacebook()

  expandImage: (evt) =>
    $(evt.target).toggleClass("expanded")
    @expandItem() if App.stream == App.commented

  expandCommentedItem: () =>
    this.$el.find(".item-content").addClass("expanded")
    this.$el.find(".item-expander").addClass("hide")
    this.$el.find(".item-collapser").removeClass("hide")
  collapseCommentedItem: () =>
    this.$el.find(".item-content").removeClass("expanded")
    this.$el.find(".item-expander").removeClass("hide")
    this.$el.find(".item-collapser").addClass("hide")
    $(document).scrollTop(this.$el.offset().top - 100)

  expandItem: (evt) =>
    if evt.target.tagName == "DIV"
      this.$el.find(".item").toggleClass('expanded')

  focused: false
  template: HandlebarsTemplates['items/item']
  $content: null

  render: =>
    App.focusedItemView = this if (App.focusedItem == this.model)
    ctx = this.model.toJSON()
    ctx.anonymous = App.user.anonymous()
    ctx.is_group = App.stream instanceof App.Group
    ctx.is_subscription = App.stream instanceof App.Subscription
    sub = App.subscriptions.get ctx.subscription_id
    if sub?
      ctx.subscription_name = sub.label()
      ctx.subscription_path = sub.path()
      if sub.get("item_view") == "collapsed"
        ctx.collapsed = true
    person = App.people.get ctx.from_id
    if person?
      ctx.is_shared_to_me = true
      ctx.person_name = person.get("name")
      ctx.person_path = person.path()

    html = this.template ctx
    if this.$content?
      this.decorate()
    else
      this.$el.addClass('item-container')
      this.$el.attr('data-id', this.model.id)
      this.$el.html html
      this.$content = this.$el.find('.item-content-inner').first()
      this.initializeCommentView()

#      TODO: do this when item becomes visible or something?
      window.setTimeout((=>
        $outer = this.$el.find(".item-content").first().innerHeight()
        $inner = this.$el.find(".item-content-inner").first().innerHeight()
        if $inner > $outer
          this.$el.find(".item-expander").removeClass("hide")
      ),1000)

  decorate: =>
    classes = ""
    sub = App.subscriptions.get this.model.get('subscription_id')
    if sub?.get("item_view") == "collapsed"
      classes += "collapsed "
    if this.model.get('starred')
      classes += "starred "
    if this.model.get('shared')
      classes += "shared "
    if this.model.get('unread')
      classes += "unread "
    if this.model.get('from_id')
      classes += "shared-to-me "
    if this.model.keep
      classes += "keep "
    if App.focusedItem?
      if App.focusedItem.id == this.model.id
        classes += "focused "
    if this.$el.find('div.item').first().hasClass("expanded")
      classes += "expanded "

    this.$el.find('div.item').attr('class', 'item well ' + classes)
    if this.model.get('starred')
      this.$el.find('.btn-star').addClass('btn-on')
    else
      this.$el.find('.btn-star').removeClass('btn-on')
    if this.model.get('shared')
      this.$el.find('.btn-share').addClass('btn-on')
    else
      this.$el.find('.btn-share').removeClass('btn-on')

    if this.model.keep
      this.$el.find('.btn-keep-unread').addClass('btn-on')
    else
      this.$el.find('.btn-keep-unread').removeClass('btn-on')

  initializeCommentView: =>
    this.commentView = new App.CommentsView
      el: this.$el.find('.item-comments-container')
      collection: this.model.comments
    this.commentView.render()

  toggleStar: =>
    val = !this.model.get('starred')
    this.model.set('starred', val)
    this.model.trigger("item:change", this.model.id)
    this.render()

  toggleShare: =>
    val = !this.model.get('shared')
    this.model.set('shared', val)
    this.model.trigger("item:change", this.model.id)
    this.render()

  markRead: =>
    this.model.markRead()
    this.render()

  keepUnread: =>
    if this.model.keep
      this.model.keep = false
    else
      this.model.set('unread', true)
      this.model.keep = true
    this.model.trigger("item:change", this.model.id)
    this.render()


  checkScroll: =>
    if this.$el?
      st = this.$el.offset().top
      sp = App.$doc.scrollTop()
      st = st - sp

      if st < 190 and st > 0
        previousFocusedItem = null
        if App.focusedItem?
          previousFocusedItem = App.focusedItem
        App.focusedItem = this.model
        if previousFocusedItem?
          unless previousFocusedItem == App.focusedItem
            previousFocusedItem.trigger('item:render')
        this.render()
      if st < 6560 and st > 0
        if _.last(App.itemRenderers) == this
          if App.streamItems.length > 0
            App.viewMore()
          else
            App.loadMore()

      if st < 90 && st != 0
        unless this.model.keep
          if this.model.get('unread') || this.model.get('has_new_comments')
            this.markRead()


