(function($) {
  'use strict';

  $(function() {
    var $fullText = $('.admin-fullText');
    $('#admin-fullscreen').on('click', function() {
      $.AMUI.fullscreen.toggle();
    });

    $(document).on($.AMUI.fullscreen.raw.fullscreenchange, function() {
      $fullText.text($.AMUI.fullscreen.isFullscreen ? '退出全屏' : '开启全屏');
    });
  });
  
  $('.selectAddress').on('click',function(){
  	$('#address_content').hide();
  	$('#address_select').show();
  });
  
  var Gid  = document.getElementById;
	var showArea = function(){
		$('#show').html($('#s_province').val()+$('#s_city').val()+$('#s_county').val()) 
	}
	$('#s_county').on('change',function(){
  	showArea();
  	$('#address_select').hide();
  	$('#address_content').show();
  });
  
})(jQuery);
