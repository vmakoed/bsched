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