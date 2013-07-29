var responses;

responses = (function() {
//DIRTY JAVASCRIPT FIX THIS LATER
	$('#send_response').click(function(e) {
		responseValidation(e);

		$(document).foundation('reveal', {
			closed:function(){
				$('#responder-error-message').hide();
			}
		});

	});

	function responseValidation(e) {
		var est_time = $('#response_est_time').val();
		if(isNaN(est_time) || est_time == "" || parseInt(est_time) < 0) {
			e.preventDefault();
			$('#responder-error-message').show();
		 }
	 };

});

$(document).ready(responses);
// $(document).on('page:load', responses);