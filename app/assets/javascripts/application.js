//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require_self
//= require_tree .

$(document).ready(function(){

	// Advanced Search
  $("#advanced-search").hide();
  $(".short_date_picker").datepicker();

  $(".toggle_hide").click(function () {
    $("#advanced-search").slideToggle("slow");
    return false;
  });

	// Modal boxes - to all links with rel="facebox"
	$('a[rel*=facebox]').facebox()
	
});
 