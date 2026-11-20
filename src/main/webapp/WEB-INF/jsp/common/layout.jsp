<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<c:set var="archiveLogo" value="${isLogin eq true ? sessionScope.userMap.archiveLogo : ''}"/>
<c:set var="adminArchiveLogo" scope="request" value="${fn:endsWith(archiveLogo, ' Admin') ? fn:substring(archiveLogo, 0, fn:length(archiveLogo) - 6) : archiveLogo}"/>

<jsp:include page="/WEB-INF/jsp/common/head.jsp">
	<jsp:param value="${isLogin}" name="title"/>
</jsp:include>

<body>
	<input type="hidden" id="contextPath" value="${contextPath}">
	
	<jsp:include page="/WEB-INF/jsp/common/modal.jsp"/>
	<jsp:include page="/WEB-INF/jsp/common/toast.jsp"/>
	<jsp:include page="/WEB-INF/jsp/common/balloon.jsp"/>
	<jsp:include page="/WEB-INF/jsp/common/imagePreview.jsp"/>
	<jsp:include page="/WEB-INF/jsp/common/loading.jsp"/>
	
	<c:choose>
		<c:when test="${isLogin eq true}">
			<input type="hidden" id="adminSessionContext" value="<c:out value='${sessionScope.adminSessionContext}'/>">
			<div class="layout-container container-fruid d-flex">
		
				<div class="offcanvas-lg offcanvas-start admin-menu-panel" id="admin-menu" tabindex="-1" aria-label="<spring:message code='common.adminMenu' htmlEscape='true'/>">
				<div class="d-flex d-lg-none justify-content-end p-2" data-bs-theme="dark">
						<button type="button" class="btn-close p-2" data-bs-dismiss="offcanvas" data-bs-target="#admin-menu" aria-label="<spring:message code='common.closeMenu' htmlEscape='true'/>"></button>
					</div>
					<c:import url="/menu">
						<c:param name="subPath" value="${subPath}"></c:param>
					</c:import>
				</div>
				
				<div class="content-wrapper">
					<div class="top-menu-name-bar d-flex align-items-center justify-content-between">
						<div class="top-menu-heading d-flex align-items-center gap-2">
							<button type="button" class="btn border-0 d-lg-none admin-menu-toggle" data-bs-toggle="offcanvas" data-bs-target="#admin-menu" aria-controls="admin-menu" aria-label="<spring:message code='common.openMenu' htmlEscape='true'/>">
								<i class="bi bi-list" aria-hidden="true"></i>
							</button>
							<div><c:out value="${currentMenuTitle}"/></div>
						</div>
						<div class="right-button-wrapper">
							<span class="right-button" onclick="window.open('${sessionScope.userMap.myArchiveFullUrlPath}','_blank')"><spring:message code="common.myArchive"/></span>
							<c:if test="${sessionScope.signinType eq 'normal'}">
								<span class="right-button" onclick="goToPage('/login/logout');"><spring:message code="common.logout"/></span>
							</c:if>
						</div>
					</div>
					<c:out value="${pageContent}" escapeXml="false"/>
				</div>
			</div>
		</c:when>
		<c:when test="${isLogin eq false}">
			<c:out value="${pageContent}" escapeXml="false"/>
		</c:when>
	</c:choose>
</body>
</html>
