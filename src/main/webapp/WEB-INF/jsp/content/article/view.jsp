<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<c:set var="pageContent">
	<form id="form">
		<script>
			let rwc = new ResponsiveWebController();
			rwc.addAndRemoveDflexAt(810);
		</script>
		
		<input type="hidden" name="articleUid" value="${articleMap.articleUid}">
	
		<div class="opt-wrapper row">
			<div class="opt-label col-1 d-flex align-items-center justify-content-center">category</div>
			<div class="opt-content col d-flex align-items-center">${articleMap.categoryName}</div>
		</div>
		
		<div class="opt-wrapper row">
			<div class="opt-label col-1 d-flex align-items-center justify-content-center">activation state</div>
			<div class="opt-content col d-flex align-items-center">${articleMap.flagActivated}</div>
		</div>
		
		<div class="opt-wrapper row">
			<div class="opt-label col-1 d-flex align-items-center justify-content-center">thumbnail</div>
			<div class="opt-content col d-flex align-items-center">
				<img src="${articleMap.thumbnailUrlPath}" width="200px" border="1" onerror="getErrorImageUrl(this, 'thumbnail')">
			</div>
		</div>

		<div class="opt-wrapper row">
			<div class="opt-label col-1 d-flex align-items-center justify-content-center">title</div>
			<div class="opt-content col d-flex align-items-center gap-2">
				<c:if test="${articleMap.flagPrivate eq 'Y'}">
					<span class="badge text-bg-dark flex-shrink-0">Private</span>
				</c:if>
				<span><c:out value="${articleMap.title}"/></span>
			</div>
		</div>

		<div class="opt-wrapper row">
			<div class="opt-label col-1 d-flex align-items-center justify-content-center">content</div>
			<div class="col"><c:out value="${articleMap.content}" escapeXml="false"/></div>
		</div>

		<div class="opt-wrapper row">
			<div class="col-xxl-12 text-end">
				<button type="button" id="btn-edit" class="btn btn-outline-dark">edit</button>
				<button type="button" id="btn-back" class="btn btn-outline-dark">back</button>
				<button type="button" id="btn-delete" class="btn btn-outline-danger">delete</button>
			</div>
		</div>
	</form>
	
	<script>
		$(function(){
			/* event :: s */
			$('#btn-edit').on('click', function(){
				goToPage('/content/article/write?articleUid=${articleMap.articleUid}');
			})
			
			$('#btn-back').on('click', function(){
				goToPage('/content/article/list');
			})
			
			$('#btn-delete').on('click', function(){
				openModal({
					type 		: 'confirm'
					, title		: 'menu'
					, message	: 'are you sure to delete this article?'
					, button	: 'delete'
					, confirm	: function(){
						$.ajax({
							type		: 'post',
							url			: './delete',
							contentType : 'application/json',
							data		: $('#form').getStringifiedJSON(),
							success		: function(data){
								if(data.resultCode == 1){
									openModal({
										type 		: 'alert'
										, title		: 'menu'
										, message	: 'the article has been successfully deleted.'
										, close		: function(){
											goToPage('/content/article/list');
										}
									})
								}else if(data.resultCode == 0){
									openModal({
										type 		: 'alert'
										, title		: 'menu'
										, message	: data.resultMessage
									})
								}
							}
						});
					}
				})
			})
			/* event :: e */
		})
	</script>
</c:set>
<%@ include file="/WEB-INF/jsp/common/layout.jsp" %>
