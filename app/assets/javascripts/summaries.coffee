$(document).on "click", ".summary-favorite-icon", (evt) ->
  id = $(evt.target).closest("[data-subscription-id]").data("subscription-id")
  sub = App.subscriptions.get(id)
  if sub
    sub.set("favorite", !sub.get("favorite"))
    sub.save()
    $(evt.target).closest("i").removeClass("icon-heart")
    $(evt.target).closest("i").removeClass("icon-heart-empty")
    $(evt.target).closest("i").addClass("icon-heart") if sub.get("favorite")
    $(evt.target).closest("i").addClass("icon-heart-empty") unless sub.get("favorite")

$(document).on "click", ".summary-starred-icon", (evt) ->
  id = $(evt.target).closest("[data-item-id]").data("item-id")
  $icon = $(evt.target)
  $.post("/items/#{id}/toggle-star").success (item) =>
    $icon.removeClass("icon-star")
    $icon.removeClass("icon-star-empty")
    if item.starred
      $icon.addClass("icon-star")
    else
      $icon.addClass("icon-star-empty")



