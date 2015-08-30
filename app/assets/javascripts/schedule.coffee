# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#table-lessons th').each (index, element) =>
    remove = 0
    tds = $(element).parents('table').find('tr td:nth-child(' + (index + 1) + ')')
    tds.each (index, element) =>
      if ($(element).html() == '')
        remove++
    if (remove == ($('#table-lessons tr').length - 5))
        $(element).hide()
        tds.hide()

  $('#table-lessons').stickyTableHeaders()

  $('#lectures-button').attr("enabled", "true")
  $('#seminars-button').attr("enabled", "true")
  $('#labs-button').attr("enabled", "true")

  $('#lectures-button').click ->
    toggle_lessons_type("lecture")

  $('#seminars-button').click ->
    toggle_lessons_type("seminar")

  $('#labs-button').click ->
    toggle_lessons_type("lab")

toggle_lessons_type = (type) ->
  button_id_selector = "#" + "#{type}s-button"
  lesson_container_selector = "." + "lesson-container-#{type}"
  if $(button_id_selector).attr("enabled") == "true"
    hide_lessons(lesson_container_selector)
    disable_type_button(button_id_selector, type)
  else
    show_lessons(lesson_container_selector)
    enable_type_button(button_id_selector, type)

hide_lessons = (lesson_container_selector) ->
  $("#table-lessons").addClass("fixed-table")
  $(lesson_container_selector).each (index, element) =>
    $(element).addClass("lesson-container-hidden")

show_lessons = (lesson_container_selector) ->
  $(lesson_container_selector).each (index, element) =>
    $(element).removeClass("lesson-container-hidden")

disable_type_button = (button_id_selector, type) ->
  $(button_id_selector).attr("enabled", "false")
  $(button_id_selector).removeClass("type-button")
  $(button_id_selector).removeClass("#{type}s-button")
  $(button_id_selector).addClass("btn-default")


enable_type_button = (button_id_selector, type) ->
  $(button_id_selector).attr("enabled", "true")
  $(button_id_selector).removeClass("btn-default")
  $(button_id_selector).addClass("type-button")
  $(button_id_selector).addClass("#{type}s-button")
