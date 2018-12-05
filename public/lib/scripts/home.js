
function validateEmail(email) {
  var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(String(email).toLowerCase());
}

$( document ).ready(function() {

  function updateProfileImages(select) {
    if (typeof select == 'undefined') {
      var selects = document.getElementsByTagName('select');

      for(var i = 0; i < selects.length; i++) {
        updateProfileImages(selects[i])
      }
    }else {
      console.log("select= "+select.value);
      var img = $("#"+select.id+"_image");
      img.attr("src", "/lib/imgs/profiles/"+select.value.toLowerCase()+".png");
    }
  }

  $("#mmgvo").on('change', function(e) {
    updateProfileImages(e.target)
  });

  $("#revelacion").on('change', function(e) {
    updateProfileImages(e.target)
  });

  $("#infeliz").on('change', function(e) {
    updateProfileImages(e.target)
  });

  $("#jugador").on('change', function(e) {
    updateProfileImages(e.target)
  });

  $("#nunca").on('change', function(e) {
    updateProfileImages(e.target)
  });

  // Do an inital call to update profile images
  updateProfileImages();
});
