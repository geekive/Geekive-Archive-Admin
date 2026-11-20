<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<!-- Button trigger modal -->
<button type="button" id="btn-modal-open" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modal" style="display: none;"><spring:message code="common.notice"/></button>

<!-- Modal -->
<div class="modal fade" id="modal" tabindex="-1" aria-labelledby="modalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h1 class="modal-title fs-5" id="modalLabel"><spring:message code="common.notice"/></h1>
				<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<spring:message code='common.close' htmlEscape='true'/>"></button>
			</div>
			<div class="modal-body">...</div>
			<div class="modal-footer">
				<button type="button" id="btn-modal-event" class="btn btn-outline-dark" data-bs-dismiss="modal"><spring:message code="common.saveChanges"/></button>
				<button type="button" id="btn-modal-close" class="btn btn-outline-dark" data-bs-dismiss="modal"><spring:message code="common.close"/></button>
			</div>
		</div>
	</div>
</div>

<script>
	let modalObj = {
			$modal 		: $('#modal')
			, $btnClose	: $('#btn-modal-close')
			, $btnEvent	: $('#btn-modal-event')
	}
	let flagModalOpen = false;
	
	modalObj.$modal.on('hidden.bs.modal', function(){
		flagModalOpen = false;
	})
	
	function openModal(data){
		if(flagModalOpen){
			let modalInterval = setInterval(function(){
				changeModalData(data)
				clearInterval(modalInterval);
			}, 500)	
		}else{
			changeModalData(data);
			flagModalOpen = true;
		}
	}
	
	function changeModalData(data){
		$('#modalLabel').html(data.title);
		$('.modal-body').html(data.message);
		
		if(data.type == 'alert'){
			modalObj.$btnEvent.hide();
		}else if(data.type == 'confirm'){
			modalObj.$btnEvent.show().html(data.button || '<spring:message code="common.confirm" javaScriptEscape="true"/>').off('click').on('click', data.confirm);
		}
		
		$('#btn-modal-open').click();
		modalObj.$btnClose.off('click').on('click', data.close);
		modalObj.$modal.off('hidden.bs.modal').on('hidden.bs.modal', function(){
			flagModalOpen = false;
			if(data.close){
				data.close();
			}
		})
	}
	
	$(document).ready(function(){
		modalObj.$modal.on('shown.bs.modal', function(){
			$('#btn-modal-close').focus();
        });
	})
</script>
