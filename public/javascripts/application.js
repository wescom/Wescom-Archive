$(document).ready(function(){

	// Screen Resizing - Hide/Show Table Columns
	if (parseInt($('#table-block').css("width"))) {
		//alert('Screen size: ' + parseInt($('#table-block').css("width")));
		screen_width=parseInt($('#table-block').css("width"))
		if (screen_width < 578) {
			$(".action_col").hide();
		}
		else {
			$(".action_col").show();
		}
		
		if (screen_width < 519) {
			$(".status_col").hide();
		}
		else {
			$(".status_col").show();
		}
		
		if (screen_width < 519) {
			$(".system_col").hide();
		}
		else {
			$(".system_col").show();
		}
		
		if (screen_width < 409) {
			$(".section_col").hide();
		}
		else {
			$(".section_col").show();
		}
  };

	if (parseInt($('#story-content').css("width"))) {
		screen_width=parseInt($('#story-content').css("width"))
		//alert('story-content size: '+screen_width);
		if (screen_width < 830) {
			$("#sidebar").hide();
			$('#story_block').css('width', '95%');
			$("#lower-block").show();
		}
		else {
			$("#sidebar").show();
			$('#story_block').css('width', '');
			$("#lower-block").hide();
		}
	};

	if (parseInt($('#image-content').css("width"))) {
		screen_width=parseInt($('#image-content').css("width"))
		//alert('story-content size: '+screen_width);
		if (screen_width < 920) {
			$("#image_edit").hide();
			$('#image_image').css('width', '95%');
			$('#image_info').css('width', '95%');
		}
		else {
			$("#image_edit").show();
			$('#image_image').css('width', '');
			$('#image_info').css('width', '');
		}
		if (screen_width < 460) {
			$('.image_large').css('width', '95%');
		}
		else {
			$('.image_large').css('width', '');
		}
	};

	$(window).resize(function() {
		screen_width=parseInt($('#table-block').css("width"))
		// alert('Screen size: '+screen_width);
		if (screen_width < 578) {
			$(".action_col").hide();
		}
		else {
			$(".action_col").show();
		}
		
		if (screen_width < 519) {
			$(".status_col").hide();
		}
		else {
			$(".status_col").show();
		}
		
		if (screen_width < 519) {
			$(".system_col").hide();
		}
		else {
			$(".system_col").show();
		}
		
		if (screen_width < 409) {
			$(".section_col").hide();
		}
		else {
			$(".section_col").show();
		}

		screen_width=parseInt($('#story-content').css("width"))
		//alert('story-content size: '+screen_width);
		if (screen_width < 830) {
			$("#sidebar").hide();
			$('#story_block').css('width', '95%');
			$("#lower-block").show();
		}
		else {
			$("#sidebar").show();
			$('#story_block').css('width', '');
			$("#lower-block").hide();
		}

		screen_width=parseInt($('#image-content').css("width"))
		//alert('image-content size: '+screen_width);
		if (screen_width < 920) {
			$("#image_edit").hide();
			$('#image_image').css('width', '95%');
			$('#image_info').css('width', '95%');
		}
		else {
			$("#image_edit").show();
			$('#image_image').css('width', '');
			$('#image_info').css('width', '');
		}
		if (screen_width < 460) {
			$('.image_large').css('width', '95%');
		}
		else {
			$('.image_large').css('width', '');
		}
  });

	// Advanced Search
  $("#advanced-search").hide();
  $(".short_date_picker").datepicker({ changeMonth: true, changeYear: true });
	$("#sidebar_today").hide();

  $(".toggle_hide").click(function () {
    $("#advanced-search").slideToggle("slow");
    return false;
  });

  $("#toggle_today").click(function () {
    $("#sidebar_today").slideToggle("medium");
    return false;
  });

	// Modal boxes - to all links with rel="facebox"
	$('a[rel*=facebox]').facebox();
	
	// Image Gallery
	$('#image-gallery').masonry({
    itemSelector : '.image_gallery',
//    columnWidth : 250
  });
});
 