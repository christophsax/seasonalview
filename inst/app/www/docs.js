$( document ).ready(function() {
  
  // click and drag tooltip
  $("#output-box").hover(function(){
      $("#info-zoom").show();
  }, function() {
      $("#info-zoom").hide();
  });

  // shinyIDCallback.js relies on this (at the end)
  $(".shiny-id-el").click(function() {
      $(".shiny-id-el").removeClass("active");
      $(this).addClass("active");
  });
})
