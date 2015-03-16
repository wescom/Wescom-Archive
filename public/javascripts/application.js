$(document).ready(function(){

	  $("#search_announcement").hide().delay(1000).slideDown('slow');

	// Navigation Bar
	$("ul li ul").hide();
	$("ul li").click(function() {
		$(this).find('ul').addClass("active").slideToggle();
	});


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
  
	var todays_date = new Date();
	var max_year = (todays_date.getFullYear()+5);
	$(".short_date_picker").datepicker({ 
		changeMonth: true, 
		changeYear: true,
		yearRange: "1992:"+max_year
	});
	$(".input_date_picker").datepicker({ 
		altField: "#pubdate-alt",
		altFormat: "yy-mm-d", 
		changeMonth: true, 
		changeYear: true,
		yearRange: "1992:"+max_year
	});
	
	$("#sidebar_today").hide();

  $(".toggle_hide").click(function () {
    $("#advanced-search").slideToggle("slow");
    return false;
  });

  $("#toggle_today").click(function () {
    $("#sidebar_today").slideToggle("medium");
    return false;
  });

  $(".taxonomy_head").click(function () {
    $("#taxonomy").slideToggle("medium");
    return false;
  });

	// Modal boxes - to all links with rel="facebox"
	$('a[rel*=facebox]').facebox();

	$(".location_plans").hide();
  $("#toggle_pubs").click(function () {
    $(".location_plans").toggle("slow");
		if ($(this).html() == "(show pubs)") {
			document.getElementById("toggle_pubs").innerHTML = '(hide pubs)';
		} else {
			document.getElementById("toggle_pubs").innerHTML = '(show pubs)';
		}
    return false;
  });
	
	// Image Gallery
	var $container = $('#image-gallery');
	$container.imagesLoaded( function(){
	  $container.masonry({
    itemSelector : '.image_gallery',
//    columnWidth : 250
		});
	});

	$('.image_gallery_caption').hide();
	$(".image_gallery").mouseenter(function() {
		$(this).find('.image_gallery_caption').fadeIn('fast');
	});
	$(".image_gallery").mouseleave (function() {
		$(this).find('.image_gallery_caption').fadeOut('fast')
	});
	
	// PDF Pages Booklet View
	$('#mybook').booklet({ 
		width: '70%',
		height: 750,
		pageNumbers: false,
		closed: true,
		autoCenter: true,
		arrows: true,
	});
	
	// Filter pub_select and section_select by location
	$('select#location').change(function() {
			var location = $('select#location').val();
			var pub_type = $('select#pub_type').val();
			var pub_select = $('select#pub_select').val();
			var section_select = $('select#section_select').val();
			// Send the request and update select dropdowns
			jQuery.getJSON('/plans/publications_and_section_options/',{pub_type: pub_type, location: location, pub_select: pub_select, ajax: 'true'}, function(data){
				// update Publication list
				$("select#pub_select option").remove();
				var row = "<option value=\"" + "" + "\">" + "- Select Publication -" + "</option>";
				$(row).appendTo("select#pub_select");
				for (var i = 0; i < data["publications"].length; i++) {
					row = "<option value=\"" + data["publications"][i].plan.pub_name + "\">" + data["publications"][i].plan.pub_name + "</option>";
					$(row).appendTo("select#pub_select");
				}
				// update Section list
				$("select#section_select option").remove();
				var row = "<option value=\"" + "" + "\">" + "- Select Section -" + "</option>";
				$(row).appendTo("select#section_select");
				for (var i = 0; i < data["sections"].length; i++) {
					row = "<option value=\"" + data["sections"][i].plan.section_name + "\">" + data["sections"][i].plan.section_name + "</option>";
					$(row).appendTo("select#section_select");
				}
			});
		});

	// Filter pub_select and section_select by pub_type
	$('select#pub_type').change(function() {
		var location = $('select#location').val();
		var pub_type = $('select#pub_type').val();
		var pub_select = $('select#pub_select').val();
		var section_select = $('select#section_select').val();
		// Send the request and update select dropdowns
		jQuery.getJSON('/plans/publications_and_section_options/',{pub_type: pub_type, location: location, pub_select: pub_select, ajax: 'true'}, function(data){
			// update Publication list
			$("select#pub_select option").remove();
			var row = "<option value=\"" + "" + "\">" + "- Select Publication -" + "</option>";
			$(row).appendTo("select#pub_select");
			for (var i = 0; i < data["publications"].length; i++) {
				row = "<option value=\"" + data["publications"][i].plan.pub_name + "\">" + data["publications"][i].plan.pub_name + "</option>";
				$(row).appendTo("select#pub_select");
			}
			// update Section list
			$("select#section_select option").remove();
			var row = "<option value=\"" + "" + "\">" + "- Select Section -" + "</option>";
			$(row).appendTo("select#section_select");
			for (var i = 0; i < data["sections"].length; i++) {
				row = "<option value=\"" + data["sections"][i].plan.section_name + "\">" + data["sections"][i].plan.section_name + "</option>";
				$(row).appendTo("select#section_select");
			}
		});
	});

	// Filter section_select by publication
	$('select#pub_select').change(function() {
		var location = $('select#location').val();
		var pub_type = $('select#pub_type').val();
		var pub_select = $('select#pub_select').val();
		var section_select = $('select#section_select').val();

		// Send the request and update select dropdowns
		jQuery.getJSON('/plans/publications_and_section_options/',{pub_type: pub_type, location: location, pub_select: pub_select, ajax: 'true'}, function(data){
			// update Section list
			$("select#section_select option").remove();
			var row = "<option value=\"" + "" + "\">" + "- Select Section -" + "</option>";
			$(row).appendTo("select#section_select");
			for (var i = 0; i < data["sections"].length; i++) {
				row = "<option value=\"" + data["sections"][i].plan.section_name + "\">" + data["sections"][i].plan.section_name + "</option>";
				$(row).appendTo("select#section_select");
			}
		});
	});

	$('.progress_bar').click(function() {
		$('#ProgressOverlay').show()
	});
	
});

