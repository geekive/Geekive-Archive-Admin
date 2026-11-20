<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<div id="loading-wrapper" class="hide">
	<div id="loading-spinner" class="spinner-border" role="status"></div>
	<div id="loading-message"><spring:message code="common.loading"/></div>
</div>
<script>
	let openLoading = function(message){
		let $loadingWrapper = $('#loading-wrapper');
		$loadingWrapper.removeClass('hide');
		$loadingWrapper.children('#loading-message').html(isNotEmpty(message) ? message : '<spring:message code="common.loading" javaScriptEscape="true"/>');
	}
	
	let closeLoading = function(){
		let $loadingWrapper = $('#loading-wrapper');
		$loadingWrapper.addClass('hide');
	}
</script>
