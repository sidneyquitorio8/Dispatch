var alerts;
var useralerts;

alerts = (function() {

	var pusher = new Pusher('e56f7a0fc697295bea83');
	var alertChannel = pusher.subscribe('alert_channel');
	var userID = $('#user').data('user-id');
	var runner = $('#user').data('runner');
    var runnerChannel = pusher.subscribe('runner'+userID+'_updates');

	function refresh() {
		pusher.disconnect();
		window.location.reload();
	}

	alertChannel.bind('new_job', function(job) {
        var url = window.location.pathname;
		if(url == "/jobs") {
          refresh();
        }
        else {
            var notification = "NEW JOB ALERT @ " + job.formatted_timestamp;
            change_notification(notification);
        }
	});

    alertChannel.bind('cancelled_job', function(job) {
        var url = window.location.pathname;
        var showurl = "/jobs/" + job.id;
        if(url == "/jobs" || url == showurl) {
          refresh();
        }
        else {
            var notification = "'" + job.category + "'" + "was cancelled";
            change_notification(notification);
        }
    });

    function change_notification(notification) {
        alert = "<div class='row'>" +
          "<div class='small-12 columns'>" +
            "<div class='panel dark' id='global-alerts'>" +
              "<div id='notification-alert'><b>" + notification + "</b></div>" +
            "</div>" +
          "</div>" +
        "</div>";
        $('#notification-box').html(alert);
    };

    runnerChannel.bind('new-notification', function(notification) {
        change_notification(notification);
    });

    runnerChannel.bind('assigned', function(job){
        var url = window.location.pathname;
        var showurl = "/jobs/" + job.id;
        if(url == "/jobs" || url == showurl) {
          refresh();
        }
        else {
            var notification = "You were just assigned the job '" + job.category + "'";
            change_notification(notification);
        }
    });

    runnerChannel.bind('reassigned', function(job){
        var url = window.location.pathname;
        var showurl = "/jobs/" + job.id;
        if(url == "/jobs" || url == "showurl") {
          refresh();
        }
        else {
            var notification = "'" + job.category + "' " + "was reassigned to another assistant";
            change_notification(notification);
        }
    });

    runnerChannel.bind('completed', function(job){
        var url = window.location.pathname;
        var showurl = "/jobs/" + job.id;
        if(url == "/jobs" || url == "showurl") {
          refresh();
        }
    });

});

useralerts = (function(){
    var pusher = new Pusher('e56f7a0fc697295bea83');
    var userID = $('#user').data('user-id');
    var runner = $('#user').data('runner');
    var userChannel = pusher.subscribe('user'+userID+'_updates');

    function refresh() {
        pusher.disconnect();
        window.location.reload();
    }

    userChannel.bind('update', function(assignment){
        refresh();
    });

    function assigned_job(job) {
        var url = window.location.pathname;
        if(url == "/jobs") {
            var id = job.id;
            var a_li = "#a" + id + "-job";
            var $this = $(a_li);
            var est_completed_at = job.formatted_est_completed_at;
            var target_div = '<li class="avatar">' +
                    '<div><strong>Assigned to<br/></strong></div>' +
                    '<img src=' + job.runner_gravatar + '><br>' +
                    '<div><strong>' + job.runner_login + '</strong></div>' +
                    '<div id="time" class="est-time small radius button secondary disabled">Target: ' + est_completed_at + '</div><br>' +
                  '</li>';
            $this.children('#job-status-button').html('assigned');
            $this.children('#job-status-button').attr('class', 'status small radius button disabled assigned');
            if($this.children('#time').length > 0) {
                $this.children('#time').remove();
            }
            $this.after(target_div);

            var job_buttons_div = "#a" + job.id + "-job-buttons";
            var job_buttons = $(job_buttons_div);
            job_buttons.children('.cancel_button').removeAttr('data-reveal-id');
            job_buttons.children('.cancel_button').removeClass('cancel_button').addClass('disabled');
            var user_completed = '<div class="row job-buttons" id="user_completed_button_row' + id + '">' +
                                    '<div class="small-6 columns">' +
                                        '<div class="button small success radius user_completed_button" data-job-id="' + id + '">job completed</div>' +
                                    '</div>' +
                                  '</div>';
            var user_completed_div = "#user_completed" + id;
            $(user_completed_div).html(user_completed);
        }
        var showurl = "/jobs/" + job.id;
        if(url == showurl) {
            var id = job.id;
            $(".status.small.radius.button.disabled.alert").html("assigned");
            var target_div = '<li class="avatar">' +
                    '<div><strong>Assigned to<br/></strong></div>' +
                    '<img src=' + job.runner_gravatar + '><br>' +
                    '<div><strong>' + job.runner_login + '</strong></div>' +
                    '<div id="time" class="est-time small radius button secondary disabled">Target: ' + job.formatted_est_completed_at + '</div><br>' +
                  '</li>';
            $("#job-info").after(target_div);
            $(".status.small.radius.button.disabled.alert").attr('class', "status small radius button disabled assigned");
            var $this = $(".row.job-buttons");
            $this.children(".small-6.small-offset-6.columns").html('<div class="button small radius alert disabled">cancel job</div>');
            var user_completed = '<div class="row job-buttons" id="user_completed_button_row' + id + '">' +
                                    '<div class="small-6 columns">' +
                                        '<div class="button small success radius user_completed_button" data-job-id="' + id + '">job completed</div>' +
                                    '</div>' +
                                  '</div>';
            var user_completed_div = "#user_completed" + id;
            $(user_completed_div).html(user_completed);
        }
        var notification = '"' + job.category + '"' + " has been assigned @ " + job.formatted_timestamp;
        change_notification(notification);

    }

    userChannel.bind('assigned', function(job){
        assigned_job(job);
    });

    function completed_job(job) {
        var url = window.location.pathname;
        var id = job.id;
        if(url == "/jobs") {
            var completed_job = "#active-job" + job.id + "-li";
            var a_li = "#a" + id + "-job";
            var cancel = "#a" + id + "-job-buttons";
            var messages = ".messages.am" + id;
            var div_class = 'messages hm' + id;
            var $this = $(a_li);
            var user_completed_button_row = "#user_completed_button_row" + id;
            //cleanup completed job
            var formatted_completed_at = job.formatted_completed_at;
            $(user_completed_button_row).remove();
            $this.children('#job-status-button').html('completed');
            $this.children('#job-status-button').attr('class', 'status small radius button disabled success');
            var ended = '<div class="est-time small radius button secondary disabled">Ended: '+  formatted_completed_at + '</div><br>';
            $this.children('#job-status-button').next().next().next().after(ended);
            $(completed_job).children(".row.job-buttons").children(cancel).remove();
            $(completed_job).children(messages).css("display", "none");
            $(completed_job).children(messages).attr('class', div_class);
            if($('#history-job-ul').length == 0) {
                $('.empty.panel.radius.history-job').replaceWith("<ul id='history-job-ul'> </ul>");
            }
            $('#history-job-ul').prepend($(completed_job));
            var l = $('#active-job-ul').children('.job.panel.radius').length;
            if ($('#active-job-ul').children('.job.panel.radius').length == 0) { //checks if there is anymore job-li's in the list
                $('#active-job-ul').replaceWith('<div class="empty panel radius"><p>no active jobs at the moment</p></div>');
            }
            $(completed_job).removeAttr("id");
            var msgButton = 'div[onClick="$(' + '".am' + id + '").toggle();' + '"]';
            var click = '$(".hm' + id + '").toggle();';
            $(msgButton).attr("onClick", click);
        }
        var showurl = "/jobs/" + job.id;
        if(url == showurl) {
            var ended = '<div class="est-time small radius button secondary disabled">Ended: '+  job.formatted_completed_at + '</div><br>';
            var user_completed_button_row = "#user_completed_button_row" + id;
            $(user_completed_button_row).remove();
            $(".status.small.radius.button.disabled").html("completed");
            $(".status.small.radius.button.disabled").next().next().next().after(ended);
            $(".status.small.radius.button.disabled").attr('class', 'status small radius button disabled success');
        }
        var notification = '"' + job.category + '"' + " has been completed @ " + job.formatted_timestamp;
        change_notification(notification);
    }

    userChannel.bind('completed', function(job){
        completed_job(job);
    });


    function change_notification(notification) {
        alert = "<div class='row'>" +
          "<div class='small-12 columns'>" +
            "<div class='panel dark' id='global-alerts'>" +
              "<div id='notification-alert'><b>" + notification + "</b></div>" +
            "</div>" +
          "</div>" +
        "</div>";
        $('#notification-box').html(alert);
    };

    userChannel.bind('new-notification', function(notification) {
        change_notification(notification);
    });

});


$(document).ready(function(){
    var runner = $('#user').data('runner');
    if(runner == true){
        alerts()
    }
    else{
        useralerts()
    }
});