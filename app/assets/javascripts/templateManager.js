function setupUSSettings() {
	_.templateSettings = {
    	interpolate: /\[\%\=(.+?)\%\]/g,
    	evaluate: /\[\%(.+?)\%\]/g
	};
}

function loadNewQuestionTemplate (button, questData, cid) {
	var htmlTmp = $('#newQuestionFormTemp').html()
	var data = questData;
	$(button).parent().parent().before(_.template(htmlTmp, data));

	//Load the listeners required for the question form
	$('.edit-btn').off().on("click", window.handleEditBtn);
	$('.delete-btn').off().on("click", window.handleDeleteBtn)
	$('input, textarea').off().on('keyup', handleChangeOnInput);
	$('.imgUploadForm input').off().on("change", window.uploadQuestImg);
	$('.audioUploadForm input').off().on("change", window.uploadQuestAudio);
}


function loadEditResponseOptionsTemplate (responseOptionData) {
	var htmlTmp = $('#editResponseOptionsForm').html()
	//console.log(responseOptionData);
	var data = {
		'name' : responseOptionData.name,
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
	$('.addRespOption').off().on("click", addResponseOption);
	$('.delete a').off().on("click", handleDeleteResposeOption);
	$('input, textarea').off().on('keyup', handleChangeOnInput);
	$('.deleteResponseOptionSet').off().on('click', deleteResponseOptionSet);
}

function loadNewCategoryTemplate(data) {
	var htmlTmp = $('#newCategoryTmp').html()
	$('ul.survey-content').append(_.template(htmlTmp, data));

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

	//Add relevant listeners for the new category
	$('.edit-btn').off().on("click", window.handleEditBtn);
	$('.delete-cat-btn').off().on("click", window.handleCatDelete);
	$('.addQuestionToCategory').off().on('click', window.addNewQuestionToCategory)
	$('.catImgUploadForm').off().on('change', window.categoryImageUpload)
	$('.catAudioUploadForm').off().on('change', window.categoryAudioUpload)
	$('input, textarea').off().on('keyup', handleChangeOnInput);
}

function addResponseOption (e) {
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
		}
	});
}

function addNewResponseOptionSet (e) {
	$.ajax({
		type: 'GET',
		url: '/response_options/new/',
		success: function (data) {
			console.log(data);
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
