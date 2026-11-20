<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<c:set var="pageContent">
	<form id="form" class="article-form">
		<script>
			let rwc = new ResponsiveWebController();
			rwc.addAndRemoveDflexAt(810);
		</script>
		
		<input type="hidden" name="articleUid" value="${articleMap.articleUid}">
	
		<div class="opt-wrapper row">
			<div class="opt-label col-1 d-flex align-items-center justify-content-center"><spring:message code="article.category"/></div>
			<div class="opt-content col d-flex align-items-center">${articleMap.categoryName}</div>
		</div>
		
		<div class="opt-wrapper row">
			<div class="opt-label col-1 d-flex align-items-center justify-content-center"><spring:message code="article.activation"/></div>
			<div class="opt-content col d-flex align-items-center"><spring:message code="state.${articleMap.flagActivated}" text="${articleMap.flagActivated}" htmlEscape="true"/></div>
		</div>

		<c:if test="${articleMap.flagPrivate eq 'Y'}">
			<div class="opt-wrapper row">
				<div class="opt-label col-1 d-flex align-items-center justify-content-center text-center"><spring:message code="article.viewers"/></div>
				<div class="opt-content col d-flex align-items-center">
					<c:choose>
						<c:when test="${empty articleViewers}">
							<span><spring:message code="article.onlyYou"/></span>
						</c:when>
						<c:otherwise>
							<ul class="list-unstyled d-flex flex-wrap gap-2 mb-0">
								<c:forEach items="${articleViewers}" var="viewer">
									<li class="badge article-viewer-badge bg-white text-dark border border-dark rounded-pill d-inline-flex align-items-center gap-1 fw-normal text-wrap text-break mw-100">
										<img class="article-viewer-avatar rounded-circle flex-shrink-0" src="<c:out value='${viewer.profileImageUrlPath}'/>" alt="" onerror="this.onerror = null; getErrorImageUrl(this, 'profile');">
										<span><c:out value="${viewer.archiveName}"/></span>
									</li>
								</c:forEach>
							</ul>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
		</c:if>
		
		<div class="opt-wrapper row">
			<div class="opt-label col-1 d-flex align-items-center justify-content-center"><spring:message code="article.thumbnail"/></div>
			<div class="opt-content col d-flex align-items-center">
				<img src="${articleMap.thumbnailUrlPath}" width="200px" border="1" onerror="getErrorImageUrl(this, 'thumbnail')">
			</div>
		</div>

		<div class="opt-wrapper row">
			<div class="opt-label col-1 d-flex align-items-center justify-content-center"><spring:message code="option.code.SO-01"/></div>
			<div class="opt-content col d-flex align-items-center gap-2">
				<c:if test="${articleMap.flagPrivate eq 'Y'}">
					<span class="badge text-bg-dark flex-shrink-0"><spring:message code="article.private"/></span>
				</c:if>
				<span><c:out value="${articleMap.title}"/></span>
			</div>
		</div>

		<div class="opt-wrapper row">
			<div class="opt-label col-1 d-flex align-items-center justify-content-center"><spring:message code="article.content"/></div>
			<div class="col"><c:out value="${articleMap.content}" escapeXml="false"/></div>
		</div>

		<div class="opt-wrapper row">
			<div class="col-xxl-12 text-end">
				<button type="button" id="btn-edit" class="btn btn-outline-dark"><spring:message code="common.edit"/></button>
				<button type="button" id="btn-back" class="btn btn-outline-dark"><spring:message code="common.back"/></button>
				<button type="button" id="btn-delete" class="btn btn-outline-danger"><spring:message code="common.delete"/></button>
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
					, title		: '<spring:message code="settings.menu" javaScriptEscape="true"/>'
					, message	: '<spring:message code="article.confirmDelete" javaScriptEscape="true"/>'
					, button	: '<spring:message code="common.delete" javaScriptEscape="true"/>'
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
										, title		: '<spring:message code="settings.menu" javaScriptEscape="true"/>'
										, message	: '<spring:message code="article.deleted" javaScriptEscape="true"/>'
										, close		: function(){
											goToPage('/content/article/list');
										}
									})
								}else if(data.resultCode == 0){
									openModal({
										type 		: 'alert'
										, title		: '<spring:message code="settings.menu" javaScriptEscape="true"/>'
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
