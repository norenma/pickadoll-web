#Awful global variable to keep check on the input things
window.stoppedInput = null

#Another waful global variable to store the forms in which something's been changed
window.targetsWithChanges = []

#Another awful global variable to keep track of response option view's state
window.showingForQuestion = null

#method for adding a new question to a category
#adds the question to the database via the API then
#adds the required HTML in the category
window.addNewQuestionToCategory = addNewQuestionToCategory = (e) ->
  button = e.target
  # console.log "Add new question to category " + e.target.getAttribute('data-categoryid')
  cid = e.target.getAttribute('data-categoryid')
  $.post 'categories/' + cid + '/addNewQuestionToCategory',
    catid : cid,
    (data) ->
      tmpData = JSON.parse(data.quest)
      tmpData['questid'] = data.questid
      tmpData['response_options'] = data.response_options
      console.log tmpData
      loadNewQuestionTemplate(button, tmpData, cid)
#end of addNewQuestionToCategory

#Method for finding an elements form parent
window.findFormParent = findFormParent = (el) ->
  console.log "finding form parent for element of type #{$(el).prop('tagName')}"
  parent = null

  checkIfForm = (el) ->
    if $(el).is('form')
      console.log 'Found form'
      return $(el)
    else
      console.log 'Did not find form'
      checkIfForm $(el).parent()

  form = checkIfForm $(el).parent()
  return form
#end of finding form

#Function for adding audio players for each response option in the edit view
window.updateResponseOptionAudio = updateResponseOptionAudio = (e) ->
  console.log 'updateResponseOptionAudio'
  $('#edit_response_option :file').each (e) ->
    optId = $(@parentNode.parentNode).children(':hidden').val()
    # console.log "Noticed change in response option #{optId}"
    activeOption = this
    $.ajax
      'url' : '/response_options/getAudioById/' + optId
      'success' : (data) ->
        # console.log data
        $(activeOption).siblings('.respOptAudio').html ''
        $(activeOption).siblings('.respOptAudio').append '<audio controls="controls" src="/uploads/' + data.ref + '"></audio>'
        return
    return
#end of updateResponseOptionAudio

#Method for handling changes on input elements, some sort of auto-save function
window.handleChangeOnInput = handleChangeOnInput = (e) ->
  console.log 'Handling change on input ...'

  handleStop = () ->
    for target in window.targetsWithChanges
      form = findFormParent target
      console.log "Saving with form #{form}"

      $(form).ajaxSubmit
        beforeSubmit: (a, f, o) ->
          o.dataType = 'json'
        complete: (x, t) ->
          console.log 'Saved'
          window.targetsWithChanges = window.targetsWithChanges.filter (t) -> t isnt target # Remove target from array
          updateResponseOptionAudio e
          updateResponseOptionSelectors()
  #end of handleStop

  clearTimeout window.stoppedInput if stoppedInput

  # Add target to array, since it has been changed
  window.targetsWithChanges.push e.target if e.target not in window.targetsWithChanges

  window.stoppedInput = setTimeout handleStop, 1000
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
  console.log "upload img", this
  $(this).ajaxSubmit
    beforeSubmit: (a, f, o) ->
      o.dataType = 'json'
    complete: (x, t) ->
      if x.status == 200
        $(activeCat).parent().find('.clear-cat-img-btn').show();
        imgRes = JSON.parse x.responseText
        if $(activeCat).parent().children('img').length == 0
          $(activeCat).after('<img src="/uploads/' + imgRes.ref + '" alt="Bild för kategori" class="catImg"/>')
        else
          $(activeCat).parent().children('img.catImg').show()
          $(activeCat).parent().children('img.catImg').attr 'src', '/uploads/' + imgRes.ref
      #end if x.status == 200
  #console.log form
#end of the categoryImageUpload

#Function for submitting the category audio upload
window.categoryAudioUpload = categoryAudioUpload = (e) ->
  activeCat = @parentNode
  $(this).ajaxSubmit
    beforeSubmit: (a, f, o) ->
      o.dataType = 'json'
    complete: (x, t) ->
      if x.status == 200
        res = JSON.parse x.responseText
        $(activeCat).parent().parent().find('button.clear-cat-audio-btn').show();
        console.log "the parent", $(activeCat).parent()
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

  # Update response option menu
  window.showingForQuestion = $(this).parent().parent().parent().parent().attr 'data-questionid'
  window.loadResponseOptionMenu()

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
  console.log 'Delete question'
  questionId = e.target.getAttribute 'data-question-id'
  console.log questionId

  if confirm "Är du säker på att du vill radera frågan? Detta kan inte ångras."
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

#handleAddExistingCategory
window.handleAddExistingCategory = handleAddExistingCategory = (e) ->
  e.preventDefault()
  catId = $(e.target).attr('data-category-id')
  console.log "Add an existing category: #{catId}"

  $.ajax({
    'url' : '/questionnaires/' + questionnaire_id + '/categories/' + catId + '/add'
    'type' : 'POST'
    'success' : (data) ->
      console.log data
    })
#end of handleAddExistingCategory

#handleAddExistingQuestion
window.handleAddExistingQuestion = handleAddExistingQuestion = (e) ->
  e.preventDefault()
  catId = $(e.target).attr('data-category-id')
  questId = $(e.target).attr('data-question-id')
  console.log "Add an existing question #{questId} to category #{catId}"

  $.ajax({
    'url' : '/questionnaires/' + questionnaire_id + '/categories/' + catId + '/questions/' + questId + '/add'
    'type' : 'POST'
    'success' : (data) ->
      console.log data
    })
#end of handleAddExistingQuestion

#handleCategoryDelete
window.handleCatDelete = handleCatDelete = (e) ->
  e.preventDefault()
  console.log 'Delete category'
  catId = $(e.target).attr('data-category-id')
  console.log catId

  if confirm "Är du säker på att du vill radera kategorin? Detta kan inte ångras."
    $.ajax({
      'url' : '/categories/' + catId
      'type' : 'DELETE'
      'success' : (data) ->
        console.log data

        $('#category-' + data.id).remove()
    })
#end of categoryDelete

#responseOptionSelected
window.responseOptionSelected = responseOptionSelected = (e) ->
  console.log "Selected response option #{e.target.parentNode}"
  $(e.target).parent().ajaxSubmit
    beforeSubmit: (a, f, o) ->
      o.dataType = 'json'
    complete: (x, t) ->
      console.log t
#end of responseOptionSelected

window.addResultCat = addResultCat = (e) ->
  console.log("add result", e.target)
  inputElement = $(e.target).find('#newResultCatInput')
  console.log "inputElement", inputElement[0]
  questionnaireId = inputElement[0].getAttribute('data-questionnaireid')
  value = $('#newResultCatText').val()
  console.log value
  $.post '/result_categories/new',
    {
      'questionnaire_id': questionnaireId
      'name': value
      },
    (data) ->
      console.log 'success'
      window.loadEditResultCategories()
      $('#newResultCatText').val('')
      return
  return




#Function for loading a response option set into the edit
#view
loadResponseOptionEdit = (e) ->
  console.log @value
  roid = @value

  $.ajax({
    'url' : '/response_options/getById/' + roid
    'success' : (data) ->
      #console.log data
      loadEditResponseOptionsTemplate data
  })
#end of loadResponseOptionEdit

#Function for loading the dropdown menu for the response options
window.loadResponseOptionMenu = loadResponseOptionMenu = ->
  #console.log "loadResponseOptionMenu"
  $.ajax({
    'url' : '/response_options/list/all'
    'success' : (data) ->
      res = data
      # console.log res

      $('#respOptionsEditDropdown').html('<option ="0">Välj svarsalternativ</option>')
      for opt in res
        do (opt) ->
          # console.log opt
          # console.log "Checking id " + window.showingForQuestion + ", owner " + opt.question_id + " and availability " + opt.availability
          if window.showingForQuestion && (window.showingForQuestion == "#{opt.question_id}" || opt.availability) # Show only the question's set
            $('#respOptionsEditDropdown').append '<option value="' + opt.id + '">' + opt.name + '</option>'
          else if !window.showingForQuestion # Show everything
            $('#respOptionsEditDropdown').append '<option value="' + opt.id + '">' + opt.name + '</option>'
      #end of for
  })

  $('#respOptionsEditDropdown').off().on 'change', loadResponseOptionEdit
#end

#Function for showing the template to add a new result category
window.loadEditResultCategories = loadEditResultCategories = ->
  console.log "loadEditResultCategories"
  console.log $(this)
  questionnaire_id = $('.showAddResultCat').attr('data-questionnaireid')
  console.log "id", questionnaire_id
  $.ajax({
    'url' : '/result_categories/list/' + questionnaire_id
    'success' : (data) ->
      res = data
      # console.log res
      $('#result-cat-list').html('');

      for opt in res
        do (opt) ->
          console.log opt
          $('#result-cat-list').append '<li> - ' + opt.name + '</li>' + '<input class="remove-result-cat" data-result_cat_id="' + opt.id + '" type="button" value="[Ta bort]">'
          bindRemove = ->
            console.log "bind"
            $('.remove-result-cat').on 'click', window.removeResultCat
            return
          window.setTimeout bindRemove(), 1000
      #end of for
  })
#end

window.removeResultCat = removeResultCat = ->
  console.log "remove cat!"
  id = $(this).attr('data-result_cat_id')
  $.ajax({
    'url' : '/result_categories/deleteItem/' + id
    'type' : 'DELETE'
    'success' : (data) ->
      console.log "success!"
      window.loadEditResultCategories()
  })
  return

# Function for updating all response option selectors in questions
window.updateResponseOptionSelectors = updateResponseOptionSelectors = ->
  # console.log "updateResponseOptionSelectors"
  $.ajax({
    'url' : '/response_options/list/all'
    'success' : (data) ->
      res = data
      # console.log res

      $('.response_option_select').each ->
        question_id = $(this).attr('data-question-id')
        selector = $(this)
        selector.html('<option value>Välj svarsalternativ</option>')

        for opt in res
          do (opt) ->
            # console.log opt
            # console.log "Checking id " + question_id + ", owner " + opt.question_id + " and availability " + opt.availability
            if parseInt(question_id) in opt.used_by # Option set is selected for this question
              selector.append '<option selected="selected" value="' + opt.id + '">' + opt.name + '</option>'
            else if question_id == "#{opt.question_id}" || opt.availability # Show only the question's set
              selector.append '<option value="' + opt.id + '">' + opt.name + '</option>'
        #end of for
  })

  $('.response_option_select').off().on 'change', responseOptionSelected
#end

#Function for loading the dropdown menu for the response options
window.loadAddCategoryMenu = loadAddCategoryMenu = ->
  console.log 'loadAddCategoryMenu'

  str = $('#category-search-field').val()

  $.ajax({
    'url' : '/categories/list/all'
    'data' : { search_string : str }
    'success' : (data) ->
      res = data
      loadAddExistingCategoryTemplate(res)
  })
#end

#Function for loading the dropdown menu for the response options
window.loadAddQuestionMenu = loadAddQuestionMenu = (categoryId) ->
  console.log "loadAddQuestionMenu #{categoryId}"
  console.log questionnaire_id

  # Set the category id in the search field
  $('#question-search-field').attr('data-categoryid', categoryId)

  str = $('#question-search-field').val()

  $.ajax({
    'url' : '/questions/list/all'
    'data' : { search_string : str }
    'success' : (data) ->
      res = data
      loadAddExistingQuestionTemplate(categoryId, res)
  })
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
      questOrder : order,
      (data) ->
        console.log 'Updated order'

    #update the newCategory as well
    lis = $(newCategory[0]).children 'li.question-bar'
    order = []
    for li in lis
      do (li) ->
        qid = li.getAttribute 'data-questionid'
        order.push qid

    cid = newCategory[0].parentNode.getAttribute('data-categoryid')

    $.post 'categories/' + cid + '/updateOrder/',
      questOrder : order,
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
    cid = @parentNode.getAttribute('data-categoryid')

    $.post 'categories/' + cid + '/updateOrder/',
      questOrder : order,
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
    responseOption : val,
    (data) ->
      updateResponseOptionSelectors()

#end of setResponseOptionForAll


#Function to call when the page is loaded
questionnaireInit = (e) ->
  $('form').on('submit', (e) ->
    #spinner = document.createElement 'p'
    #spinner.textContent = 'Sparar...'
    #spinner.id = 'formSpinner'

    #e.target.appendChild spinner
  )
  $('form').on('ajax:success', (e, data, status, xhr) ->
    console.log 'Saved'

    wait = (ms, func) -> setTimeout func, ms

    #wait 1000, -> $('#formSpinner').fadeOut(500, (e) ->
      #$(this).remove()
      #console.log "removed"
    #)
  )

  $('.category-bar, .question-bar').on('mouseenter', (e) ->
    #console.log "Show options"
    $(this).children('.toolbar').css 'display', 'inline-block'
  )
  $('.category-bar, .question-bar').on('mouseleave', (e) ->
    #console.log "Hide options"
    $(this).children('.toolbar').css 'display', 'none'
  )
  #Open edit view
  $('.edit-btn').on 'click', handleEditBtn
  $('.delete-btn').on 'click', handleDeleteBtn

  #The delete button for the categories
  $('.delete-cat-btn').on 'click', handleCatDelete

  #$('li.category').on('click', handleEditBtn)

  #ajaxSubmit
  window.uploadQuestImg = uploadQuestImg = (e) ->
    activeQuest = this

    $(this).parent().ajaxSubmit
      beforeSubmit: (a, f, o) ->
        o.dataType = 'json'
      complete: (x, t) ->
        #console.log x
        if x.status == 200
          console.log($(activeQuest))
          $(activeQuest).parent().parent().parent().find('.clear-question-img-btn').show();
          imgRes = JSON.parse x.responseText
          $(activeQuest).parent().parent().siblings('.questionImgWrapper').html('')
          $(activeQuest).parent().parent().siblings('.questionImgWrapper').append '<p><img src="/uploads/' + imgRes.ref + '" class="qImg"> </p>'
        else
      #end of the complete function
  #end of the uploadQuestImg

  #code for handling the audio upload
  window.uploadQuestAudio = uploadQuestAudio = (e) ->
    activeQuest = this
    console.log('active', $(activeQuest).parent().parent().parent())
    $(this).parent().ajaxSubmit
      beforeSubmit: (a, f, o) ->
        o.dataType = 'json'
      complete: (x, t) ->
        console.log x.responseText
        if x.status == 200
          $(activeQuest).parent().parent().parent().find('.clear-question-audio-btn').show();
          audRes = JSON.parse x.responseText
          $(activeQuest).parent().parent().siblings('.questionAudioPlayer').html('')
          $(activeQuest).parent().parent().siblings('.questionAudioPlayer').append '<audio controls="controls" src="/uploads/' + audRes.ref + '"></audio>'
        else
          #if something went wrong, check it up innit

        #end of if-statement
  #end of the upload function

  $('.imgUploadForm input').on 'change', uploadQuestImg
  $('.audioUploadForm input').on 'change', uploadQuestAudio

  #make the categories sortable
  $('.draggable-category-questions').sortable({
    handle : '.question-name'
    placeholder : 'question-drop-placeholder'
    connectWith : '.category-questions'
    stop : dropped
  })

  $('.category-questions').disableSelection()

  $('.draggable-survey-content').sortable({
    handle : '.category-bar'
    placeholder : {
      element: (clone, ui) ->
        return $('<li class="selected-category">' + clone[0].innerHTML + '</li>')
      update: ->
        return
    }
    stop : categoryDropped
  })

  $('#setResponseOptionForAll').on 'change', responseOptionForAllSelected

  $('.editRespOption').on('click', (e) ->
    e.preventDefault()
    $('#editRespOptForm').css 'display', 'block'
  )

  $('.editRespAllOption').on('click', (e) ->
    e.preventDefault()

    # Update response option menu
    window.showingForQuestion = null
    window.loadResponseOptionMenu()

    $('#editRespOptForm').css 'display', 'block'
  )

  $('.showAddResultCat').on('click', (e) ->
    e.preventDefault()
    console.log "Hej"
    window.loadEditResultCategories()

    $('#editResultCategories').css 'display', 'block'
  )

  $('.clear-cat-img-btn').on('click', (e) ->
    fileInput = $('#category-' + $(e.target).attr('data-categoryid') + " #category_image")
    fileInput.replaceWith(fileInput.val('').clone(true));
    imgTag = $('#category-' + $(e.target).attr('data-categoryid') + ' .catImg')
    imgTag.attr('src', '')
    imgTag.hide()
    $.post '/categories/remove_image', cat_id : $(e.target).attr('data-categoryid'),
      (data) ->
        console.log "image removed", data
        $(e.target).hide()
        return
    return;
  )

  $('.clear-cat-audio-btn').on('click', (e) ->
    fileInput = $('#category-' + $(e.target).attr('data-categoryid') + " #category_audio")
    fileInput.replaceWith(fileInput.val('').clone(true));
    audioTag = $('#category-' + $(e.target).attr('data-categoryid') + ' audio')
    audioTag.attr('src', '')
    #imgTag.hide()
    $.post '/categories/remove_audio', cat_id : $(e.target).attr('data-categoryid'),
      (data) ->
        console.log "audio removed", data
        console.log "hiding.. ", $(e.target)
        $(e.target).hide()
        return
    return;
  )

  $('.clear-question-img-btn').on('click', (e) ->
    target = $(e.target)
    question = $('#question-bar-' + target.attr('data-questionId'))
    fileInput = question.find('input#question_image')
    console.log(fileInput)
    # Empty file input
    fileInput.replaceWith(fileInput.val('').clone(true));

    imgTag = question.find('.qImg')
    imgTag.attr('src', '')
    imgTag.hide()
    $.post '/questions/remove_image', q_id : target.attr('data-questionId'),
      (data) ->
        console.log "image removed", data
        target.hide()
        return
    return;
  )

  $('.clear-question-audio-btn').on('click', (e) ->
    target = $(e.target)
    question = $('#question-bar-' + target.attr('data-questionId'))
    fileInput = question.find('input#question_audio')
    console.log(fileInput)
    # Empty file input
    fileInput.replaceWith(fileInput.val('').clone(true));

    audioTag = question.find('audio')
    audioTag.attr('src', '')
    #audioTag.hide()
    $.post '/questions/remove_audio', q_id : target.attr('data-questionId'),
      (data) ->
        console.log "audio removed", data
        target.hide()
        return
    return;
  )

  $('.addExistingCategory').on 'click', (e) ->
    e.preventDefault()
    $('#category-search-field').val('') # Reset search field
    loadAddCategoryMenu()
    $('#addExCatForm').css 'display', 'block'

  $('.addExistingQuestionToCategory').on 'click', (e) ->
    e.preventDefault()
    $('#question-search-field').val('') # Reset search field
    categoryId = e.target.getAttribute('data-categoryid')
    loadAddQuestionMenu(categoryId)
    $('#addExQuestForm').css 'display', 'block'

  # Listeners for change events on searching
  $('#category-search-field').on 'keyup', loadAddCategoryMenu
  $('#question-search-field').on 'keyup', (e) ->
    categoryId = e.target.getAttribute('data-categoryid')
    loadAddQuestionMenu(categoryId)

  $('.response_option_select').on 'change', responseOptionSelected

  $('.addQuestionToCategory').on 'click', addNewQuestionToCategory
  $('.addCategory').on 'click', addNewCategoryToQuestionnaire

  $('.catImgUploadForm').on 'change', categoryImageUpload
  $('.catAudioUploadForm').on 'change', categoryAudioUpload

  $('.closeRespPopup').on 'click', (e) ->
    e.preventDefault()
    $('#editRespOptForm').css 'display', 'none'

  $('.close-button').on 'click', (e) ->
    e.preventDefault()
    $('.popupForm').css 'display', 'none'
    return

  $('.closeAddCatPopup').on 'click', (e) ->
    e.preventDefault()
    $('#addExCatForm').css 'display', 'none'

  $('.closeAddQuestPopup').on 'click', (e) ->
    e.preventDefault()
    $('#addExQuestForm').css 'display', 'none'

  #Listener for the change-events on the input elements
  $('form.changes input, form.changes textarea').on 'keyup', handleChangeOnInput

  $('.newResponseOptionSet').on 'click', addNewResponseOptionSet
  $('#new-result-cat-form').on 'submit', addResultCat

  $('#toggle_use_result_cat').on 'change', (e) ->
    console.log "hej"
    return 

  loadResponseOptionMenu()
  #setup underscore settings
  setupUSSettings()
#End of ready method

$(document).on('ready', questionnaireInit )
$(document).on('page:load', questionnaireInit )


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
