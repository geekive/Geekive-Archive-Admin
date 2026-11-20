<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<div id="image-preview-wrapper" class="image-preview-wrapper">
	<span class="btn-image-preview-close">&times;</span>
	<img id="preview-image" class="preview-image">
</div>

<script>
	let $imagePreviewWrapper 	= $('#image-preview-wrapper');
	let $previewImage 			= $('#preview-image');
	let $btnImagePreviewClose 	= $('.btn-image-preview-close');

	$btnImagePreviewClose.on('click', function() {
		$imagePreviewWrapper.css('display', 'none');
	});

	$imagePreviewWrapper.on('click', function(event) {
	    if($(event.target).is($imagePreviewWrapper)){
	    	$imagePreviewWrapper.css('display', 'none');
	    }
	});

	function initializeImagePreviewButton($object, $base64){
		$object.on('click', function(){
			let base64 = $base64.val();
			if(isEmpty(base64)){
				openModal({
					type 		: 'alert'
					, title		: '<spring:message code="common.preview" javaScriptEscape="true"/>'
					, message	: '<spring:message code="common.previewEmpty" javaScriptEscape="true"/>'
				})
				return
			}
			$imagePreviewWrapper.css('display', 'flex');
			$previewImage.attr('src', $base64.val());
		})
	}
</script>
