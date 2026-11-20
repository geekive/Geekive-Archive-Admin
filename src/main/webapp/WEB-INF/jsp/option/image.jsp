<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>
<div class="opt-wrapper row ${hide eq true ? 'hide' : ''}">
	<div class="opt-label col-1 d-flex align-items-center justify-content-center">${optionLabel}</div>
	<div class="opt-content col d-flex align-items-center">
 		<input type="hidden" id="${id}" name="${name}" value="${data.urlPath}">
		<input type="file" class="hide" name="${name}" accept="image/*">
		<input type="text" class="${preview eq true ? 'opt-file-preview' : 'opt-txt'} form-control" readonly="readonly" placeholder="<spring:message code='common.selectFile' htmlEscape='true'/>" value="${data.originalName}">
		<c:if test="${preview}">
			<span class="file-img-preview"><spring:message code="common.preview"/></span>
		</c:if>
	</div>
</div>
<script>
	$(function(){
 		let name 	= '<c:out value="${name}"/>';
 		let $file 	= $('input[type="file"][name="' + name + '"]');
 		let $hidden = $file.prev();
		let $text	= $file.next();
		
		function fnReset(){
			$file.val('');$hidden.val('');$text.val('');
		}
		
		$text.on('click', function(){
			$file.trigger('click');
		})
		
		$file.on('change', function(){
			if(this.files.length > 0){
				let type = this.files[0].type;
				if(!type.includes('image')){
					fnReset();
					openModal({
						type 		: 'alert'
						, title		: '<spring:message code="article.label" javaScriptEscape="true"/>'
						, message	: '<spring:message code="common.imageOnly" javaScriptEscape="true"/>'
					})
					return
				}
				
				let message = this.files[0].name;
				$text.val(message);
				
				<c:if test="${crop}">
					pixelarity.open(this.files[0], true, function(succ, res){
						if(succ){
							$hidden.val(res);
						}else{
							fnReset();
						}
					}, 'jpg', 1)
				</c:if>
			}else{
				fnReset();
				return
			}
		})
		
		<c:if test="${preview}">
			let $preview = $file.nextAll().eq(1);
			initializeImagePreviewButton($preview, $hidden);
		</c:if>	
	})
</script>
