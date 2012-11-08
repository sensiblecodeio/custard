(function( $ ) {
  $.fn.stripes = function() {
      var holder = $('<div id="stripes">');
      var colour = this.data('stripes');
      var stripes = ['first','second','third','fourth','fifth','sixth'];
      for (i=0;i<stripes.length;i++){
          $('<div class="' + stripes[i] + '" style="background-color: ' + colour + '">').appendTo(holder);
      }
      return this.append(holder);
  };
})( jQuery );

$(function(){
    $('body[data-stripes]').stripes();
});