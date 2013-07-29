var surveys;

surveys = (function() {
	$('#submit-survey').click(function(e) {
		surveyValidation(e);
	});

	function surveyValidation(e) {
		var speed_checked = $('input[name="survey[speed]"]:checked').length;
		var service_checked = $('input[name="survey[service]"]:checked').length;
		if(speed_checked == 0 || service_checked == 0) {
			e.preventDefault();
			if($('#submit-error-message').length <= 0) {
				$('#submit-survey').parent().append("<small id='submit-error-message' style='color:red'> Please fill out required fields </small>");
			}
		}
	 };

});

$(document).ready(surveys);