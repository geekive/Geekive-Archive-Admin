<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<div class="toast-container position-fixed bottom-0 end-0 p-3"></div>
<div id="toast" class="toast align-items-center border-0 toast-bg" role="alert" aria-live="assertive" aria-atomic="true">
	<div class="d-flex">
		<div class="toast-body"><spring:message code="common.notice"/></div>
		<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="<spring:message code='common.close' htmlEscape='true'/>"></button>
	</div>
</div>

<script>
	function openToast(data){
		let $container		= $('.toast-container');
		let $clonedToast 	= $('#toast').clone();
		
		$clonedToast.find('.toast-body').html(data);
		let toastBootstrap = bootstrap.Toast.getOrCreateInstance($clonedToast);
		$container.append($clonedToast);
		toastBootstrap.show();
	}
</script>
