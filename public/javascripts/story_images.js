jQuery(function() {
  if ($('#gallery_paginate .pagination').length) {
    $(window).scroll(function() {
      var url;
      url = $('.pagination .next_page').attr('href');
      if (url && ($(window).scrollTop() > ($(document).height() - $(window).height() - 400))) {
        $('.pagination').text("Fetching more products...");
        return $.getScript(url);
      }
    });
    return $(window).scroll();
  }
});