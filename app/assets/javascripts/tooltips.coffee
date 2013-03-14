App.updateTooltips = ->
  $("#nav-unread-link").tooltip
    placement: "right"
    title: "Unread items"

  $("#nav-all-link").tooltip
    placement: "right"
    title:     "All items"

  $("#nav-starred-link").tooltip
    placement: "right"
    title: "Starred items"

  $("#nav-shared-link").tooltip
    placement: "right"
    title: "Shared items"

  $("#nav-comments-link").tooltip
    placement: "right"
    title: "Discussions"


  $("#nav-note-link").tooltip
    placement: "right"
    title:     "Share something!"

  $("#nav-settings-link").tooltip
    placement: "right"
    title:     "Settings"

  $("#nav-add-link").tooltip
    placement: "right"
    title:     "Add new group/feed"