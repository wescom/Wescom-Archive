
$(document).ready(function(){

	// Advanced Search
  $("#advanced-search").hide();
  $(".short_date_picker").datepicker();
	$("#sidebar_today").hide();

  $(".toggle_hide").click(function () {
    $("#advanced-search").slideToggle("slow");
    return false;
  });

  $(".toggle_today").click(function () {
    $("#sidebar_today").slideToggle("medium");
    return false;
  });

	// Modal boxes - to all links with rel="facebox"
	$('a[rel*=facebox]').facebox();
	
});
 