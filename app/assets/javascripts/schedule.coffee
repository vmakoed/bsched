# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  remove_empty_columns("#table-lessons")
  $('#table-lessons').stickyTableHeaders()
  setup_type_button type for type in get_lesson_types()

get_lesson_types = ->
  ["lecture", "seminar", "lab"]

get_number_of_service_headers = ->
  number_of_weeks = 4
  number_of_weeks + 1

setup_type_button = (type) ->
  $("##{type}s-button").attr("enabled", "true")
  $("##{type}s-button").click ->
    toggle_lessons_type "#{type}"

remove_empty_columns = (table) ->
  $("#{table} th").each (index, element) =>
    column_cells = $(element).parents('table').find("tr td:nth-child(#{index + 1})")
    if is_column_empty(table, column_cells)
      $(element).hide()
      column_cells.hide()

is_column_empty = (table, column_cells) ->
  count_empty_cells(column_cells) == ($("#{table} tr").length - get_number_of_service_headers())

count_empty_cells = (cells) ->
  remove = 0
  cells.each (index, element) =>
    remove++ if ($(element).html() == '')
  remove

toggle_lessons_type = (type) ->
  if $("##{type}s-button").attr("enabled") == "true"
    toggle_lessons_type_off(type)
  else
    toggle_lessons_type_on(type)

toggle_lessons_type_on = (type) ->
  show_lessons(type)
  enable_type_button(type)

toggle_lessons_type_off = (type) ->
  hide_lessons(type)
  disable_type_button(type)

hide_lessons = (type) ->
  $("#table-lessons").addClass("fixed-table")
  $(".lesson-container-#{type}").each (index, element) =>
    $(element).addClass("lesson-container-hidden")

show_lessons = (type) ->
  $(".lesson-container-#{type}").each (index, element) =>
    $(element).removeClass("lesson-container-hidden")

disable_type_button = (type) ->
  $("##{type}s-button").attr("enabled", "false")
  $("##{type}s-button").removeClass("type-button")
  $("##{type}s-button").removeClass("#{type}s-button")
  $("##{type}s-button").addClass("btn-default")


enable_type_button = (type) ->
  $("##{type}s-button").attr("enabled", "true")
  $("##{type}s-button").removeClass("btn-default")
  $("##{type}s-button").addClass("type-button")
  $("##{type}s-button").addClass("#{type}s-button")
