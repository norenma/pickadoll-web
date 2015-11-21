function setupUSSettings() {
	_.templateSettings = {
    	interpolate: /\[\%\=(.+?)\%\]/g,
    	evaluate: /\[\%(.+?)\%\]/g
	};
}

// Makes sure all of the listeners are set (once and only once)
function setListeners() {
	$('form.changes input, form.changes textarea').off().on('keyup', handleChangeOnInput);
	$('#edit_response_option :file').off().on('change', handleChangeOnInput);
	$('.responseOptionAvailability :checkbox').off().on('change', handleChangeOnInput);

	// In question view
	$('.edit-btn').off().on("click", window.handleEditBtn);
	$('.delete-btn').off().on("click", window.handleDeleteBtn);

	$('.imgUploadForm input').off().on("change", window.uploadQuestImg);
	$('.audioUploadForm input').off().on("change", window.uploadQuestAudio);

	$('.addQuestionToCategory').off().on('click', window.addNewQuestionToCategory);
	$('.catImgUploadForm').off().on('change', window.categoryImageUpload);
	$('.catAudioUploadForm').off().on('change', window.categoryAudioUpload);

	$('.editRespOption').off().on("click", function (e) {
		e.preventDefault();
		$('#editRespOptForm').css('display', 'block');
	});

	$('.editRespAllOption').off().on("click", function (e) {
		e.preventDefault();

		// Update response option menu
		window.showingForQuestion = null;
		window.loadResponseOptionMenu();

		$('#editRespOptForm').css('display', 'block');
	});

	// In response option view
	$('.response_option_select').off().on('change', responseOptionSelected);
	$('.addRespOption').off().on("click", addResponseOption);
	$('.delete a').off().on("click", handleDeleteResposeOption);

	$('.newResponseOptionSet').off().on("click", addNewResponseOptionSet);
	$('.deleteResponseOptionSet').off().on('click', deleteResponseOptionSet);
}

function loadNewQuestionTemplate (button, questData, cid) {
	console.log("Loading new question template");
	var htmlTmp = $('#newQuestionFormTemp').html()
	var data = questData;
	$(button).parent().parent().before(_.template(htmlTmp, data));

	// Load the listeners required for the question form
	setListeners();
}


function loadEditResponseOptionsTemplate (responseOptionData) {
	console.log("Loading edit response options template");
	var htmlTmp = $('#editResponseOptionsForm').html()
	// console.log(responseOptionData);
	var data = {
		'name' : responseOptionData.name,
		'availability' : responseOptionData.availability,
		'options' : JSON.parse(responseOptionData.options),
		'id' : responseOptionData.id
	};

	$('#respEditDetailed').html(_.template(htmlTmp, data ));
	$('#edit_response_option').submit(function (e) {
		$(this).ajaxSubmit({
			success : function (res) {
				console.log("Response");
				console.log(res);
			}
		});
		return false;
	});

	//Add listener for the addResponse button
	setListeners();

	// Add audio players to response options
	window.updateResponseOptionAudio();

	// $('#edit_response_option :file').on('change', function (e) {
	// 	optId = $(e.target.parentNode.parentNode).children(':hidden').val();
	// 	console.log("Noticed change in response option " + optId);
	// 	activeOption = this;
	//
	// 	$.ajax({
	// 		'url' : '/response_options/getAudioById/' + optId,
	// 		'success' : function (data) {
	// 			console.log(data);
	// 			$(activeOption).siblings('.respOptAudio').html("");
	// 			$(activeOption).siblings('.respOptAudio').append('<audio controls="controls" src="/uploads/' + data.ref + '"></audio>');
	// 		}
	// 	});
	// });
}

function loadAddExistingCategoryTemplate(categoryData) {
	console.log("Loading add existing category template");
	var htmlTmp = $('#addExistingCategoryForm').html()
	// console.log(categoryData);
	var data = {
		'categories' : categoryData
	};
	$('#addExistingCategoryDetailed').html(_.template(htmlTmp, data));

	// Add handler
	$('.categoriesInput a').off().on("click", handleAddExistingCategory);
}

function loadAddExistingQuestionTemplate(categoryId, questionData) {
	console.log("Loading add existing question template");
	var htmlTmp = $('#addExistingQuestionForm').html()
	// console.log(questionData);
	var data = {
		'categoryId' : categoryId,
		'questions' : questionData
	};
	$('#addExistingQuestionDetailed').html(_.template(htmlTmp, data));

	// Add handler
	$('.questionsInput a').off().on("click", handleAddExistingQuestion);
}

function loadNewCategoryTemplate(data) {
	var htmlTmp = $('#newCategoryTmp').html()
	$('ul.survey-content').append(_.template(htmlTmp, data));
	console.log(data);

	//Sortable questions in categories
	$(".category-questions" ).sortable({
		handle: '.question-name',
		placeholder: 'question-drop-placeholder',
		connectWith: '.category-questions',
		stop: window.dropped
	});
	$( ".category-questions").disableSelection();
	//Sortable categories
	$('.survey-content').sortable({
		handle: '.category-bar',
		placeholder : {
			element: function (clone, ui) {
				return $('<li class="selected-category">'+ clone[0].innerHTML+'</li>');
			},
            update: function () {
            	return;
            }
		},
		stop: window.categoryDropped
	});

	// Add relevant listeners for the new category
	setListeners();
}

function addResponseOption (e) {
	console.log("Adding new response option");
	var responseOptionId = $('.response_option_id').val();
	var htmlTmp = $('#newResponseOptionTemp').html();
	var derp = e.target;
	$.ajax({
		type: 'POST',
		data: {},
		url: '/response_options/' + responseOptionId + '/addNewItem',
		success : function (data) {
			console.log(data);
			console.log(e.target);
			$('#editResponseOptionTBody').append(_.template(htmlTmp, {'id' : data.id }))

			// Add relevant listeners for the new row
			setListeners();
		}
	});
}

function addNewResponseOptionSet (e) {
	console.log("Adding new response option set");
	$.ajax({
		type: 'POST',
		url: '/response_options',
		data: {question_id : window.showingForQuestion},
		success: function (data) {
			// console.log(data);
			loadResponseOptionMenu();
			$.ajax({
				'url' : '/response_options/getById/' + data.id,
				'success' : function (data) {
					loadEditResponseOptionsTemplate(data);
					console.log("Added new responseOptionId")
					$('.response_option_select').append('<option value="' + data.id + '">' + data.name + '</option>');
					$('#setResponseOptionForAll').append('<option value="' + data.id + '">' + data.name + '</option>');
				}
			});
		}
	})
}

function handleDeleteResposeOption (e) {
	e.preventDefault();
	var responseElement = e.target.parentNode.parentNode;
	var responseOptionItemId = $(e.target).attr('data-item-id');
	$.ajax({
		type : 'DELETE',
		url: '/response_options/deleteItem/' + responseOptionItemId,
		success : function (data) {
			console.log(data);
			$(responseElement).remove();
		}
 	});
	return false;
}

function handleEditResponseOptionSubmit (e) {
	e.preventDefault();
	$(this).submit(function () {
		$(this).ajaxSubmit({
			beforeSubmit: function(a, f, o) {
				o.dataType = 'json'
			},
			success : function (res) {
				console.log("Response");

			}
		});
	});
}

function deleteResponseOptionSet (e) {
	$.ajax({
		type : 'DELETE',
		url : '/response_options/' + $('.response_option_id').val(),
		success : function (data) {
			console.log(data);

			$('#respEditDetailed').html("");
			loadResponseOptionMenu();
		}
	});
}
