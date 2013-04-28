$(document).on 'ajax:success', 'form#sign_in_form', (e, data, status, xhr) ->
  if(data.success)
    tracker.track("Successful Login");
    window.location.href = data.continue_to
  else
    tracker.track("Failed Login");
    $('#user-login-box').html(data.errors.join('<br />'))

$(document).on 'click', '#register-submit-link-btn', (evt) ->
  $('#user_register_box').html('')

$(document).on 'ajax:success', 'form#register_form', (e, data, status, xhr) ->
  if(data.success)
    tracker.track("Successful Registration");
    App.user = new App.User(data)
    $(".modal").modal('hide')
    window.location.href = '/settings/feeds'
    window.location.reload()
  else
    tracker.track("Failed Registration");
    errors = []
    errors.push("Email " + data.errors.email[0]) if data.errors.email?
    errors.push("Password " + data.errors.password[0]) if data.errors.password?
    errors.push("Name " + data.errors.name[0]) if data.errors.name?
    errors.push("You must agree to the terms of use") if data.errors.terms?
    $('#user_register_box').html(errors.join('<br />'))

$(document).on 'click', '#password-submit-link-btn', (evt) ->
  $('#user_password_box').html('')
  $('#password_form').submit()
  return false

$(document).on 'ajax:success', 'form#password_form', (e, data, status, xhr) ->
  if(data.success)
    $(".modal").modal('hide')
    window.location.href = '/'
    window.location.reload()
  else
    errors = []
    errors.push("Email " + data.errors.email[0]) if data.errors.email?
    errors.push("Password " + data.errors.password[0]) if data.errors.password?
    errors.push("Name " + data.errors.name[0]) if data.errors.name?
    $('#user_password_box').html(errors.join('<br />'))

$(document).on 'click', '.btn-close, #login-close-link-btn, #register-close-link-btn', (evt) ->
  $(".modal").modal("hide")

$(document).on 'click', '#login-link', (evt) ->
  $("#login-modal").modal('show')
  return false

$(document).on 'click', '#register-link', (evt) ->
  $("#login-modal").modal('hide')
  $("#register-modal").modal('show')
  return false

$(document).on 'click', '#new-password-link', (evt) ->
  $("#login-modal").modal('hide')
  $("#password-modal").modal('show')
  return false
