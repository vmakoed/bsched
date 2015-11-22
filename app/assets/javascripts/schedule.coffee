# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  remove_empty_columns("#table-lessons")
  $('#table-lessons').stickyTableHeaders({ scrollableArea: $('#schedule-table')[0] })
  setup_type_button type for type in get_lesson_types()
  setup_checkbox_actions()
  scroll_to_current_week()

setup_checkbox_actions = ->
  $('input.all-info-checkbox:checkbox').change ->
    for info_checkbox in $(this).parents('.panel-body').find('input.info-checkbox:checkbox')
      $(info_checkbox).prop('checked', this.checked)
    reindex_lessons()

  $('input.info-checkbox:checkbox').change ->
    handle_all_info_checkbox($(this))
    reindex_lessons()

handle_all_info_checkbox = (checkbox) ->
  is_list_checked = is_list_all_checked($(checkbox))
  $(checkbox).parents('.panel-body').find('input.all-info-checkbox:checkbox').prop('checked', is_list_checked)

is_list_all_checked = (checkbox) ->
  is_checked = true
  for element in $(checkbox).parents('.panel-body').find('input.info-checkbox:checkbox')
    if $(element).prop('checked') == false
      is_checked = false
      break
  is_checked

reindex_lessons = ->
  enable_all_lessons()
  disable_unchecked_lessons()

enable_all_lessons = ->
  alter_lessons($(checkbox).val(), true) for checkbox in $('input.info-checkbox:checkbox')
  toggle_lessons_type_on($(checkbox).val()) for checkbox in $("input.lesson-type-checkbox:checkbox")

disable_unchecked_lessons = ->
  for info_checkbox in $('input.info-checkbox:checkbox')
    alter_lessons($(info_checkbox).val(), false) if ($(info_checkbox).prop('checked') == false)

  for lesson_type_checkbox in $("input.lesson-type-checkbox:checkbox")
    toggle_lessons_type_off($(lesson_type_checkbox).val()) if ($(lesson_type_checkbox).prop('checked') == false)

alter_lessons = (info, is_to_enable) ->
  lessons = collect_lessons_with_info(info)
  if (is_to_enable)
    $(lesson).removeClass("lesson-container-hidden") for lesson in lessons
  else
    $(lesson).addClass("lesson-container-hidden") for lesson in lessons

collect_lessons_with_info = (info) ->
  $(".lesson-container:contains(#{info})")

scroll_to_current_week = ->
  $('html, body').animate {
    scrollTop: $(".tr-current-week").offset().top
  }, 1000

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
  for table_header, index in $("#{table} th")
    column_cells = $(table_header).parents('table').find("tr td:nth-child(#{index + 1})")
    if is_column_empty(table, column_cells)
      $(table_header).hide()
      $(column_cells).hide()

is_column_empty = (table, column_cells) ->
  count_empty_cells(column_cells) == ($("#{table} tr").length - get_number_of_service_headers())

count_empty_cells = (cells) ->
  remove = 0
  for cell in cells
    remove++ if ($(cell).html() == '')
  remove

toggle_lessons_type = (type) ->
  if $("##{type}s-button").prop("enabled") == true
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
  $(lesson_container).addClass("lesson-container-hidden") for lesson_container in $(".lesson-container-#{type}")

show_lessons = (type) ->
  $(lesson_container).removeClass("lesson-container-hidden") for lesson_container in $(".lesson-container-#{type}")

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