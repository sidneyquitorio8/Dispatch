var jobs;

jobs = (function() {

	$('.respond').click(function() {
    $('#response_job_id').val($(this).data('job-id'));
  });

	$('.cancel_button').click(function() {
    $('#edit_job').attr('action', '/jobs/' + $(this).data('job-id'));

  });	

  $('#button_on_it').click(function() {
  	$('#response_est_time').val(0);
  	$('#send_response').click();
  });

  $('#cancelcancel').click(function(){
    $('#cancel_modal').foundation('reveal','close');
  });

  //Client side validations
  $('#submit-job').click(function(e) {
    jobValidation(e);
  });

  $('#runner-job-submit').click(function(e) {
    runnerJobValidation(e);
  });

  $('.user_completed_container').on('click', '.user_completed_button', function(e) {
    var id = $(this).data('job-id');
    var url = "/jobs/" + id;
    $.ajax({
      type: "PUT",
      url: url,
      data: {job: {status: "completed"}},
      async: false, 
    });
  });

  function jobValidation(e) {
    var category = $('#job_category').val();
    var location = $('#job_location').val();
    var description = $('#job_description').val();
    if(category == "" || location == "" || description == "") {
      $('#new-job-errors').html('');
      e.preventDefault();
      $('#new-job-errors').append('<small style="color:red"> Please fill out all fields </small>');
    }
  };

  function runnerJobValidation(e) {
    var user_login = $('#user_login').val();
    var category = $('#category').val();
    var location = $('#location').val();
    var description = $('#description').val();
    var user_exists;
    //AJAX call to check if user exists in the database
    // $.post("/jobs/user_exists", {user_login: user_login}, function (response) {
    //   if(response == "false") {
    //     $('#runner-new-job-errors').html('');
    //     e.preventDefault();
    //     $('#runner-new-job-errors').append('<small style="color:red"> User doesnt exist </small>');
    //   }
    // });
    $.ajax({
      type: "POST",
      url: "/jobs/user_exists",
      data: {user_login: user_login},
      async: false, 
      success: function(response) {
        if(response == "false") {
          $('#runner-new-job-errors').html('');
          e.preventDefault();
          $('#runner-new-job-errors').append('<small style="color:red"> User doesnt exist </small>');
        }
      }
    });
    if(user_login == "" || category == "" || location == "" || description == "") {
        $('#runner-new-job-errors').html('');
        e.preventDefault();
        $('#runner-new-job-errors').append('<small style="color:red"> Please fill out all fields </small>');
      }

  }

});

$(document).ready(jobs);
$(document).on('page:load', jobs);