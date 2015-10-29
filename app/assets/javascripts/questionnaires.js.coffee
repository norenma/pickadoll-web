#Awful global variable to keep check on the input things
window.stoppedInput = null

#method for adding a new question to a category
#adds the question to the database via the API then
#adds the required HTML in the category
window.addNewQuestionToCategory = addNewQuestionToCategory = (e) ->
	button = e.target
	# console.log "Add new question to category " + e.target.getAttribute('data-categoryid')
	cid = e.target.getAttribute('data-categoryid')
	$.post 'categories/' + cid + '/addNewQuestionToCategory',
		catid: cid,
		(data) ->
			tmpData = JSON.parse(data.quest)
			tmpData['questid'] = data.questid
			tmpData['response_options'] = data.response_options
			console.log tmpData
			loadNewQuestionTemplate(button, tmpData, cid)
#end of addNewQuestionToCategory

#Method for finding an elements form parent
window.findFormParent = findFormParent = (el) ->
	parent = null

	checkIfForm = (el) ->
		if $(el).is('form')
			console.log "found form"
			return $(el)
		else
			console.log "didnt find form"
			checkIfForm $(el).parent()

	form = checkIfForm $(el).parent()
	return form
#end of finding form

#Method for handling changes on input elements, some sort of auto-save function
window.handleChangeOnInput = handleChangeOnInput = (e) ->
	handleStop = (target) ->
		console.log "Done"
		form = findFormParent target
		console.log form
		$(form).ajaxSubmit
			beforeSubmit: (a, f, o) ->
				o.dataType = 'json'
			complete: (x, t) ->
				console.log "Saved"
	if stoppedInput
		clearTimeout window.stoppedInput

	window.stoppedInput = setTimeout handleStop, 1000, e.target
#end of handleChangeOnInput

#method for adding a new category to
#the questionnaire
addNewCategoryToQuestionnaire = (e) ->
	$.post 'addNewCategory',
		(data) ->
			# console.log data
			loadNewCategoryTemplate data
	#end of post call
#end of the addNewCategoryToQuestionnaire

#Function for uploading the category image
window.categoryImageUpload = categoryImageUpload = (e) ->
	activeCat = this
	$(this).ajaxSubmit
		beforeSubmit: (a, f, o) ->
			o.dataType = 'json'
		complete: (x, t) ->
			if x.status == 200
				imgRes = JSON.parse x.responseText

				if $(activeCat).parent().children('img').length == 0
					$(activeCat).before('<img src="/uploads/' + imgRes.ref + '" alt="Bild för kategori" />')
				else
					$(activeCat).parent().children('img.catImg').attr 'src', '/uploads/' + imgRes.ref
			#end if x.status == 200
	#console.log form
#end of the categoryImageUpload

#Function for submitting the category audio upload
window.categoryAudioUpload = categoryAudioUpload = (e) ->
	activeCat = this.parentNode
	$(this).ajaxSubmit
		beforeSubmit: (a, f, o) ->
			o.dataType = 'json'
		complete: (x, t) ->
			if x.status == 200
				res = JSON.parse x.responseText

				if $(activeCat).parent().children('audio').length == 0
					$(activeCat).parent().prepend '<audio controls="controls" class="audioPlayer"><source src="/uploads/' + res.ref + '" type="audio/mpeg"> </audio>'
				else
					ap = $(activeCat).parent().children('audio')
					$(ap).attr 'src', '/uploads/' + res.ref
					ap.load
				#end of if-statement
#end of the function

#function for showing/hiding category/question content when
#an edit button is pressed called from .edit-btn
window.handleEditBtn = handleEditBtn = (e) ->
	e.preventDefault()
	#function for checking if the tag is an editable one
	checkEditableTag = (t) ->
		if $(t).hasClass('question-bar') || $(t).hasClass('category')
			#console.log "Found a valid element"
			return t
		else
			checkEditableTag t.parentNode
		#end of the if-statement
	#end of the method

	validElement = checkEditableTag e.target

	if $(validElement).hasClass('editing')
		$(validElement).removeClass('editing')
	else
		$('.editing').removeClass('editing')
		$(validElement).addClass('editing')
#end of handleEditBtn

#handle the delete-buttons
window.handleDeleteBtn = handleDeleteBtn = (e) ->
	e.preventDefault()
	console.log "Delete question"
	questionId = e.target.getAttribute 'data-question-id'
	console.log questionId

	$.ajax({
		'url' : '/questions/' + questionId
		'type' : 'DELETE'
		'success' : (data) ->
			#remove the HTML-element for the deleted question
			$('#question-bar-' + data.id).remove()
	})
#end of handling the delete-button


#method handling the sorting of categories
window.categoryDropped = categoryDropped = (e) ->
	lis = $(e.target).children 'li.category'
	order = []
	for li in lis
		do (li) ->
			cid = li.getAttribute 'data-categoryid'
			order.push cid
	#console.log order

	$.post 'updateCategoryOrder',
		catOrder: order
		(data) ->
			console.log data
#end of categoryDropped

#handleCategoryDelete
window.handleCatDelete = handleCatDelete = (e) ->
	e.preventDefault()
	console.log "Delete category"
	catId = $(e.target).attr('data-category-id')
	console.log catId

	$.ajax({
		'url' : '/categories/' + catId
		'type' : 'DELETE'
		'success' : (data) ->
			console.log data

			$('#category-' + data.id).remove()
	})
#end of categoryDelete

#responseOptionSelected
responseOptionSelected = (e) ->
	console.log e.target.parentNode
	$(e.target).parent().ajaxSubmit
		beforeSubmit: (a, f, o) ->
			o.dataType = 'json'
		complete: (x, t) ->
			console.log t
#end of responseOptionSelected


#Function for loading a response option set into the edit
#view
loadResponseOptionEdit = (e) ->
	console.log this.value
	roid = this.value

	$.ajax({
		'url' : '/response_options/getById/' + roid
		'success' : (data) ->
			#console.log data
			loadEditResponseOptionsTemplate data
	})
#end of loadResponseOptionEdit

#Function for loading the dropdown menu for the response options
window.loadResponseOptionMenu = loadResponseOptionMenu = () ->
	#console.log "loadResponseOptionMenu"
	$.ajax({
		'url' : '/response_options/list/all'
		'success' : (data) ->
			res = data
			#console.log res

			$('#respOptionsEditDropdown').html('<option ="0">Välj svarsalternativ</option>')
			for opt in res
				do (opt) ->
					#console.log opt
					$('#respOptionsEditDropdown').append '<option value="' + opt.id + '">' + opt.name + '</option>'
			#end of for
	})

	$('#respOptionsEditDropdown').on 'change', loadResponseOptionEdit
#end

#Method for handling dropped question-bar
window.dropped = dropped = (e, ui) ->
	originalCategory = this
	newCategory = $(ui.item).parent()

	if originalCategory.parentNode.id != newCategory[0].parentNode.id
		#update the original category
		lis = $(originalCategory).children 'li.question-bar'
		order = []
		for li in lis
			do (li) ->
				qid = li.getAttribute 'data-questionid'
				order.push qid

		cid = originalCategory.parentNode.getAttribute('data-categoryid')

		$.post 'categories/' + cid + '/updateOrder/',
			questOrder: order,
			(data) ->
				console.log "Updated order"

		#update the newCategory as well
		lis = $(newCategory[0]).children 'li.question-bar'
		order = []
		for li in lis
			do (li) ->
				qid = li.getAttribute 'data-questionid'
				order.push qid

		cid = newCategory[0].parentNode.getAttribute('data-categoryid')

		$.post 'categories/' + cid + '/updateOrder/',
			questOrder: order,
			(data) ->
				#console.log data
	else
		#Moved between different categories
		lis = $(e.target).children 'li.question-bar'

		order = []
		for li in lis
			do (li) ->
				qid = li.getAttribute 'data-questionid'
				order.push qid
		cid = this.parentNode.getAttribute('data-categoryid')

		$.post 'categories/' + cid + '/updateOrder/',
			questOrder: order,
			(data) ->
				console.log data
		#end of post
	#end of else
#end of dropped


#Function for setting a response option for all questions in a questionnaire
window.responseOptionForAllSelected = responseOptionForAllSelected = (e) ->
	val = e.target.value
	questionnaireId = e.target.getAttribute('data-questionnaireid')

	$.post '/questionnaires/' + questionnaireId + '/setResponseOptionForAllQuestions/',
		responseOption: val,
		(data) ->
			selects = $('.response_option_select')
			$('.response_option_select').val(data.responseOptionId)

#end of setResponseOptionForAll

#Function to call when the page is loaded
questionnaireInit = (e) ->
	$('form').on("submit", (e) ->
		#spinner = document.createElement 'p'
		#spinner.textContent = 'Sparar...'
		#spinner.id = 'formSpinner'

		#e.target.appendChild spinner
	)
	$('form').on("ajax:success", (e, data, status, xhr) ->
		console.log "sparad"

		wait = (ms, func) -> setTimeout func, ms

		#wait 1000, -> $('#formSpinner').fadeOut(500, (e) ->
			#$(this).remove()
			#console.log "removed"
		#)
	)

	$('.category-bar, .question-bar').on("mouseenter", (e) ->
		#console.log "Show options"
		$(this).children('.toolbar').css 'display', 'inline-block'
	)
	$('.category-bar, .question-bar').on("mouseleave", (e) ->
		#console.log "Hide options"
		$(this).children('.toolbar').css 'display', 'none'
	)
	#Open edit view
	$('.edit-btn').on "click", handleEditBtn
	$('.delete-btn').on "click", handleDeleteBtn

	#The delete button for the categories
	$('.delete-cat-btn').on "click", handleCatDelete

	#$('li.category').on("click", handleEditBtn)

	#ajaxSubmit
	window.uploadQuestImg = uploadQuestImg = (e) ->
		activeQuest = this
		$(this).parent().ajaxSubmit
			beforeSubmit: (a, f, o) ->
				o.dataType = 'json'
			complete: (x, t) ->
				#console.log x
				if x.status == 200
					imgRes = JSON.parse x.responseText
					$(activeQuest).parent().parent().siblings('.questionImgWrapper').html("")
					$(activeQuest).parent().parent().siblings('.questionImgWrapper').append '<p><img src="/uploads/' + imgRes.ref + '" > </p>'
				else
			#end of the complete function
	#end of the uploadQuestImg

	$('.imgUploadForm input').on "change", uploadQuestImg

	#code for handling the audio upload
	window.uploadQuestAudio = uploadQuestAudio = (e) ->
		activeQuest = this
		$(this).parent().ajaxSubmit
			beforeSubmit: (a, f, o) ->
				o.dataType = 'json'
			complete: (x, t) ->
				console.log x.responseText
				if x.status == 200
					audRes = JSON.parse x.responseText
					$(activeQuest).parent().parent().siblings('.questionAudioPlayer').html("")
					$(activeQuest).parent().parent().siblings('.questionAudioPlayer').append '<audio controls="controls" src="/uploads/' + audRes.ref + '"></audio>'
				else
					#if something went wrong, check it up innit

				#end of if-statement
	#end of the upload function

	$('.audioUploadForm input').on "change", uploadQuestAudio

	#make the categories sortable
	$(".category-questions" ).sortable({
		handle: '.question-name'
		placeholder: 'question-drop-placeholder'
		connectWith: '.category-questions'
		stop: dropped
	})

	$( ".category-questions").disableSelection()

	$('.survey-content').sortable({
		handle: '.category-bar'
		placeholder : {
			element: (clone, ui) ->
                return $('<li class="selected-category">'+ clone[0].innerHTML+'</li>');
            update: () ->
                return;
		}
		stop: categoryDropped
	})

	$('#setResponseOptionForAll').on 'change', responseOptionForAllSelected

	$('.editRespOption').on("click", (e) ->
		e.preventDefault()
		$('#editRespOptForm').css 'display', 'block'
	)

	$('.response_option_select').on 'change', responseOptionSelected

	$('.addQuestionToCategory').on 'click', addNewQuestionToCategory
	$('.addCategory').on 'click', addNewCategoryToQuestionnaire

	$('.catImgUploadForm').on 'change', categoryImageUpload
	$('.catAudioUploadForm').on 'change', categoryAudioUpload

	$('.closeRespPopup').on 'click', (e) ->
		e.preventDefault()
		$('#editRespOptForm').css 'display', 'none'

	#Listener for the change-events on the input elements
	$('input, textarea').on 'keyup', handleChangeOnInput

	loadResponseOptionMenu()
	#setup underscore settings
	setupUSSettings()

	$('.newResponseOptionSet').on("click", addNewResponseOptionSet);
#End of ready method
$(document).on("ready", questionnaireInit )
$(document).on("page:load", questionnaireInit )


# Restricting a field to numbers only

# copyright 1999 Idocs, Inc. http://www.idocs.com
# Distribute this script freely but keep this notice in place
@numbersonly = (myfield, e) ->
  key = undefined
  keychar = undefined

  if window.event
    key = window.event.keyCode
  else if e
    key = e.which
  else
    return true

  keychar = String.fromCharCode(key)

  if key == null or key == 0 or key == 8 or key == 9 or key == 13 or key == 27 # control keys
    true
  else if '0123456789'.indexOf(keychar) > -1 # numbers
    true
  else
    false
