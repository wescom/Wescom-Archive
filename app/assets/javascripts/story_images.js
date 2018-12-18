jQuery(function() {
  if ($('#gallery_paginate .pagination').length) {
    $(window).scroll(function() {
      var url;
      url = $('.pagination .next_page').attr('href');
      if (url && ($(window).scrollTop() > ($(document).height() - $(window).height() - 800))) {
			  $('.pagination').replaceWith('<div class="pagination fetching_images_text"><img class="spinner" src="./images/Spinner.gif"></br>Fetching more images...</div>');
        return $.getScript(url);
      }
    });
    return $(window).scroll();
  }
});