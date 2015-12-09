# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  remove_empty_columns_in_html()
  remove_empty_columns_in_pdf()
  setup_filters_button()
  setup_resize_actions()
  setup_checkbox_actions()
  hide_filters_if_sm()
  show_filters_if_larger_than_sm()
  apply_sticky_table_headers()
  scroll_to_current_week()


setup_resize_actions = ->
  $(window).resize ->
    apply_sticky_table_headers()

remove_empty_columns_in_html = ->
  remove_empty_columns($('#table-lessons'), get_number_of_service_headers('html'))

remove_empty_columns_in_pdf = ->
  for table in $('.table-lessons-pdf')
    remove_empty_columns($(table), get_number_of_service_headers('pdf'))

apply_sticky_table_headers = ->
  $('#table-lessons').stickyTableHeaders({ scrollableArea: $('#schedule-table')[0] })

is_screen_small = ->
  $(window).width() < get_sm_width()

hide_filters_if_sm = ->
  disable_filters_panel() if is_screen_small()

show_filters_if_larger_than_sm = ->
  pre_toggle_filters_button() unless is_screen_small()

disable_filters_panel = ->
  hide_filters_panel()
  dim_navbar_button($('#filters-button'))

enable_filters_panel = ->
  raise_navbar_button($('#filters-button'))
  show_filters_panel()

get_sm_width = ->
  992

setup_filters_button = ->
  $('#filters-button').click ->
    if $('#filters-button').hasClass('navbar-button-active')
      disable_filters_panel()
    else
      enable_filters_panel()
    $('#filters-button').blur()
    apply_sticky_table_headers()

pre_toggle_filters_button = ->
  $('#filters-button').addClass('active')
  $('#filters-button').attr('aria-pressed', true)
  raise_navbar_button($('#filters-button'))
  show_filters_panel()

dim_navbar_button = (button) ->
  $(button).removeClass('navbar-button-active')
  $(button).addClass('btn-link')
  $(button).removeClass('btn-default')

raise_navbar_button = (button) ->
  $(button).addClass('navbar-button-active')
  $(button).removeClass('btn-link')
  $(button).addClass('btn-default')

hide_filters_panel = ->
  $('#filters-sidebar-wrapper').removeClass('col-lg-2 col-md-3 col-sm-12 col-xs-12')
  $('#filters-sidebar-wrapper').addClass('col-lg-0 col-md-0 hidden-sm hidden-xs')
  $('#filters-sidebar-wrapper').hide()
  $('#schedule-table-wrapper').removeClass('col-lg-10 col-md-9 hidden-sm hidden-xs')
  $('#schedule-table-wrapper').addClass('col-lg-12 col-md-12 col-sm-12 col-xs-12')

show_filters_panel = ->
  $('#schedule-table-wrapper').removeClass('col-lg-12 col-md-12 col-sm-12 col-xs-12')
  $('#schedule-table-wrapper').addClass('col-lg-10 col-md-9 hidden-sm hidden-xs')
  $('#filters-sidebar-wrapper').removeClass('col-lg-0 col-md-0 hidden-sm hidden-xs')
  $('#filters-sidebar-wrapper').addClass('col-lg-2 col-md-3 col-sm-12 col-xs-12')
  $('#filters-sidebar-wrapper').show()

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
  alter_lessons_with_info($(checkbox).val(), true) for checkbox in $('input.info-checkbox:checkbox')
  show_lessons_of_type($(checkbox).val()) for checkbox in $('input.lesson-type-checkbox:checkbox')

disable_unchecked_lessons = ->
  for info_checkbox in $('input.info-checkbox:checkbox')
    alter_lessons_with_info($(info_checkbox).val(), false) if ($(info_checkbox).prop('checked') == false)

  for lesson_type_checkbox in $("input.lesson-type-checkbox:checkbox")
    hide_lessons_of_type($(lesson_type_checkbox).val()) if ($(lesson_type_checkbox).prop('checked') == false)

alter_lessons_with_info = (info, is_to_enable) ->
  lessons = collect_lessons_with_info(info)
  if (is_to_enable)
    $(lesson).removeClass('lesson-container-hidden') for lesson in lessons
  else
    $(lesson).addClass('lesson-container-hidden') for lesson in lessons
    $(lesson).addClass('lesson-container-hidden') for lesson in lessons

collect_lessons_with_info = (info) ->
  $(".lesson-container:contains(#{info})")

scroll_to_current_week = ->
  $('#schedule-table').animate {
    scrollTop: $('.tr-current-week').offset().top - $('.navbar').height()
  }, 1000

get_lesson_types = ->
  ['lecture', 'seminar', 'lab']

get_number_of_service_headers = (format) ->
  number_of_time_boundaries_headers = 1
  if format == 'pdf'
    number_of_week_headers = 1
  else
    number_of_week_headers = 4
  number_of_week_headers + number_of_time_boundaries_headers

remove_empty_columns = (table, num_of_service_headers) ->
  for table_header, index in $(table).find('th')
    column_cells = $(table_header).parents('table').find("tr td:nth-child(#{index + 1})")
    if is_column_empty(table, column_cells, num_of_service_headers)
      $(table_header).hide()
      $(column_cells).hide()

count_empty_cells = (cells) ->
  remove = 0
  for cell in cells
    remove++ if ($(cell).html() == '')
  remove

is_column_empty = (table, column_cells, num_of_service_headers) ->
  count_empty_cells(column_cells) == ($(table).find('tr').length - num_of_service_headers)

setup_type_button = (type) ->
  $("##{type}s-button").attr('enabled', 'true')
  $("##{type}s-button").click ->
    toggle_lessons_type "#{type}"

toggle_lessons_type = (type) ->
  if $("##{type}s-button").prop('enabled') == true
    hide_lessons_of_type(type)
  else
    show_lessons_of_type(type)

hide_lessons_of_type = (type) ->
  $('#table-lessons').addClass('fixed-table')
  $(lesson_container).addClass('lesson-container-hidden') for lesson_container in $(".lesson-container-#{type}")

show_lessons_of_type = (type) ->
  $(lesson_container).removeClass("lesson-container-hidden") for lesson_container in $(".lesson-container-#{type}")