# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

answersInit = (e) ->

	console.log "answerInit" 

	$('#checkAllBox').on 'click', handleCheckAllBox



handleCheckAllBox = (e) -> 
	console.log 'clicked'

	if e.target.checked 

		console.log "Check all"

		$('#answerTableBody input[type="checkbox"]').prop 'checked', true
	else 
		console.log "Uncheck all" 
		$('#answerTableBody input[type="checkbox"]').attr 'checked', false


$(document).on("ready", answersInit )
$(document).on("page:load", answersInit )