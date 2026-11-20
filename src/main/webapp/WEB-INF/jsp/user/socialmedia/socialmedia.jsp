<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<c:set var="pageContent">
	<form id="form">
		<c:forEach items="${socialMediaList}" var="socialMedia">
			<c:import url="/option/text">
				<c:param name="label">${socialMedia.codeLabel}</c:param>
				<c:param name="name">${socialMedia.codeValue}</c:param>
				<c:param name="maxlength">200</c:param>
				<c:param name="data">${socialMedia.url}</c:param>
			</c:import>
		</c:forEach>
		
		<div class="opt-wrapper row">
			<div class="col-xxl-12 text-end">
				<button type="button" id="btn-save" class="btn btn-outline-dark"><spring:message code="common.save"/></button>
			</div>
		</div>
	</form>
	<script>
		var rwc = new ResponsiveWebController();
		rwc.addAndRemoveDflexAt(810);
	</script>
	<script>
		$(function(){
		    $('#btn-save').on('click', function(){
		        let $text 				= $('input[type="text"]');
		        let socialMediaArray 	= [];
		        let isValid 			= true;
	
		        $text.each(function(){
		            let url = $(this).val();
		            if (!url) return true;

		            if (/[ㄱ-ㅎ가-힣]/.test(url)) {
		                openModal({
		                    type: 'alert',
		                    title: '<spring:message code="social.label" javaScriptEscape="true"/>',
		                    message: '<spring:message code="social.koreanUrl" javaScriptEscape="true"/>'
		                });
		                
		                $(this).focus();
		                isValid = false;
		                return false;
		            }

		            const urlPattern = /^(https?:\/\/)?(www\.)?(facebook\.com|youtube\.com|instagram\.com|twitter\.com|tiktok\.com|linkedin\.com|github\.com)\/[a-zA-Z0-9_.@-]+(\/)?$/;
		            if (!urlPattern.test(url)) {
		                openModal({
		                    type: 'alert',
		                    title: '<spring:message code="social.label" javaScriptEscape="true"/>',
		                    message: '<spring:message code="social.invalidUrl" javaScriptEscape="true"/>'
		                });
		                
		                $(this).focus();
		                isValid = false;
		                return false;
		            }

		            socialMediaArray.push({
		                'socialMediaType': $(this).attr('name'),
		                'url': url
		            });
		        });

		        if(!isValid) return;
	
		        $.ajax({
		            type		: 'post',
		            url			: './save-socialmedia',
		            contentType	: 'application/json',
		            data		: JSON.stringify(socialMediaArray),
		            success: function(data){
		                const message = data.resultCode === 1 ? '<spring:message code="common.saved" javaScriptEscape="true"/>' : data.resultMessage;
		                openModal({
		                    type: 'alert',
		                    title: '<spring:message code="social.label" javaScriptEscape="true"/>',
		                    message: message,
		                    close: data.resultCode === 1 ? function() { location.reload(); } : undefined
		                });
		            }
		        });
		    });
		});
	</script>
</c:set>
<%@ include file="/WEB-INF/jsp/common/layout.jsp" %>
