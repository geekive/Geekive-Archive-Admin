<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>
<div class="menu-wrapper">
	<div class="project-name d-flex align-items-center justify-content-center" onclick="goToPage('/');">
		${sessionScope.userMap.archiveLogo}
	</div>
	
	<div class="profile-picture d-flex align-items-center justify-content-center">
		<img class="rounded-circle" src="${profileImageUrlPath}" onerror="getErrorImageUrl(this, 'profile')" width="150"  onclick="goToPage('/user/profile')">
	</div>

	<c:forEach items="${menuList}" var="parentVO" varStatus="status">
		<div class="accordion">
		  	<div class="menu-acc-item accordion-item">
		    	<h2 class="accordion-header">
			      	<button class="menu-acc-btn accordion-button ${parentVO.flagSelected eq 'Y' ? '' : 'collapsed'}" type="button" data-bs-toggle="collapse" data-bs-target="#menu${status.index}" aria-expanded="false" aria-controls="menu${status.index}">
						<c:out value="${parentVO.title}"/>
			      	</button>
		    	</h2>
		    	<div id="menu${status.index}" class="accordion-collapse collapse ${parentVO.flagSelected eq 'Y' ? 'show' : ''}">
		    		<c:forEach items="${parentVO.childList}" var="childVO">
						<div class="menu-sub d-flex align-items-center ${childVO.flagSelected eq 'Y' ? 'menu-sub-selected' : ''}" onclick="goToPage('${parentVO.path}${childVO.path}')"><c:out value="${childVO.title}"/></div>
		      		</c:forEach>
		    	</div>
		  	</div>
		</div>
	</c:forEach>
</div>
