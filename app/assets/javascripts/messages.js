// var messages;

// messages = (function() {
// 	var pusher = new Pusher('5b2ddfa2cd67ec68c353');
// 	pusher.connection.bind('state_change', function() {
// 		$('#conn_state').text(pusher.connection.state);
// 	});

// 	function addMessage(msg) {
		
// 		var body = "<li class='message'>" +
//                      	"<p>" + 
//                         "<strong>" + msg["login"] + "</strong>: " + msg["body"] + "<br>" +
//                         "<span id='sent-at'>Sent on " + msg["formatted_created_at"] + "</span>" +
//                      	"</p>" +
//                 "</li>";

// 		$('.msg_list').append(body);
// 	};

// 	var msgChannel = pusher.subscribe('msg_channel');
// 	msgChannel.bind('msg_added', function(msg) {

// 		var message_job_id = msg["job_id"];
// 		var url = window.location.pathname;
// 		var job_show_id = url.substring(url.lastIndexOf('/') + 1);
// 		var show_integer = parseInt(job_show_id);
// 		if(message_job_id == show_integer) {
// 			addMessage(msg);
// 		}
// 	});

// });

// $(document).ready(messages);
// $(document).on('page:load', messages);

var messages;

messages = function() {

	$('.new_message').submit(function(e) {
		var $this = $(this);
		var body = $this.children('#message_body').val();
		var id = $this.children('#message_job_id').val();
		messageValidation(e, body, id);
    var url = window.location.pathname;
    var message_url = "/jobs/" + id;
    if(url == message_url) {   
      $.ajax({
        type: "POST",
        url: "/messages",
        data: {message: {body: body, job_id: id}}
      });
      $("#message_body").val('');
      return false;
    }
	});

	function messageValidation(e, body, id) {
		var div = '#message' + id + '-validation-errors';
    var result = true;
    if(body == "") {
      $(div).html('');
      e.preventDefault();
      result = false;
      $(div).html('<small style="color:red"> Message body empty </small>');
    }
    return result;
	};

	var pusher = new Pusher('e56f7a0fc697295bea83');

  function addMessageToIndex(msg) {
    
  var body = "<li class='message'>" +
                    "<p>" + 
                      "<strong>" + msg["login"] + "</strong>: " + msg["body"] +
                      "<span id='sent-at'>Sent on " + msg["formatted_created_at"] + "</span>" +
                    "</p>" +
              "</li>";

    //Add message to active job tab if the job exists there
    var am_ul = "#am" + msg["job_id"] + "-message-ul";
    var am_no_message_li = "#am" + msg["job_id"] + "-no-message";
    if( $(am_ul).length ) {
	    $(am_ul).append(body);
	    $(am_no_message_li).remove();
	  }

	  //Add message to unassigned job tab if the job exists there
	  var um_ul = "#um" + msg["job_id"] + "-message-ul";
    var um_no_message_li = "#um" + msg["job_id"] + "-no-message";
    if( $(um_ul).length ) {
	    $(um_ul).append(body);
	    $(um_no_message_li).remove();
	  }

    //Add message to all job tab if the job exists there
    var aj_ul = "#aj" + msg["job_id"] + "-message-ul";
    var aj_no_message_li = "#aj" + msg["job_id"] + "-no-message";
    if( $(aj_ul).length ) {
      $(aj_ul).append(body);
      $(aj_no_message_li).remove();
    }

	  //Add message to assigned job tab if the job exists there
	  var asm_ul = "#asm" + msg["job_id"] + "-message-ul";
    var asm_no_message_li = "#asm" + msg["job_id"] + "-no-message";
    if( $(asm_ul).length ) {
	    $(asm_ul).append(body);
	    $(asm_no_message_li).remove();
	  }

	  //Add message to history job tab if the job exists there
	  var hm_ul = "#hm" + msg["job_id"] + "-message-ul";
    var hm_no_message_li = "#hm" + msg["job_id"] + "-no-message";
    if( $(hm_ul).length ) {
	    $(hm_ul).append(body);
	    $(hm_no_message_li).remove();
	  }

  };

  function addMessageToShow(msg) {
      
  var body = "<li class='message'>" +
                    "<p>" + 
                      "<strong>" + msg["login"] + "</strong>: " + msg["body"] +
                      "<span id='sent-at'>Sent on " + msg["formatted_created_at"] + "</span>" +
                    "</p>" +
              "</li>";

	  $('.msg_list').append(body);
	  $('#no-messages-job').remove();
  };

  var msgChannel = pusher.subscribe('msg_channel');
    
  msgChannel.bind('msg_added', function(msg) {
    var message_job_id = msg["job_id"];
    var url = window.location.pathname;
    var message_url = "/jobs/" + message_job_id;
    if(url == "/jobs") {
      addMessageToIndex(msg);
    }
    else if(url == message_url) {
       addMessageToShow(msg);
    }
  });

};

$(document).ready(messages);