<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<div class="balloon-wrapper hide">
	<button type="button" class="balloon-close-button btn-close" aria-label="<spring:message code='common.close' htmlEscape='true'/>"></button>
	<div class="balloon-line"></div>
	<p class="balloon-text"><spring:message code="common.notice"/></p>
</div>
<div class="balloon-redbox hide"></div>
<script>
	function openBallon(data) {
		let targetElement 	= document.getElementById(data.id);
		let rect 			= targetElement.getBoundingClientRect();

		let $blln			= $('.balloon-wrapper');
		let $clonedblln 	= $blln.clone();
		
		let $bllnLine		= $clonedblln.find('.balloon-line');
		if(isEmpty(data.direction) || data.direction == 'right'){
			$clonedblln.css('left', (rect.right + 20) + 'px');
			$bllnLine.addClass('balloon-line-right');
		}else if(data.direction == 'left'){
			let bllnWidth = Number($blln.css('width').replace('px', ''));
			$clonedblln.css('right', (rect.left + bllnWidth + 25) + 'px');
			$bllnLine.addClass('balloon-line-left');
		}
		$clonedblln.css('top', (rect.top 	+ 10) + 'px');	
		$clonedblln.removeClass('hide');
		$clonedblln.find('.balloon-text').html(data.message);	
		$blln.after($clonedblln);
		
		let $bllnRb 		= $('.balloon-redbox');
		let $clonedBllnRb	= $bllnRb.clone();
		$clonedBllnRb.css('height', rect.height + 'px');
		$clonedBllnRb.css('width', rect.width + 'px');
		$clonedBllnRb.css('left', rect.left + 'px');
		$clonedBllnRb.css('top', rect.top + 'px');
		$clonedBllnRb.removeClass('hide');
		$bllnRb.after($clonedBllnRb);

		$clonedblln.find('.balloon-close-button').off('click').on('click', function(){
			fnRemoveBallone();
		})
		
		$clonedBllnRb.off('click').on('click', function(){
			fnRemoveBallone();
		})
		
		let resizeTimer;
		$(window).off('click').on('resize', function() {
			fnRemoveBallone();
		});
		
		function fnRemoveBallone(){
			$clonedblln.remove();
			$clonedBllnRb.remove();
		}
	}
	
	
</script>
