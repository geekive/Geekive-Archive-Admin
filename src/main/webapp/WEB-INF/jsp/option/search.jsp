<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<div class="opt-wrapper row ${hide eq true ? 'hide' : ''}">
	<div class="opt-label col-1 d-flex align-items-center justify-content-center">${optionLabel}</div>
	<div class="opt-content col d-flex align-items-center">
		<select class="opt-slt form-select" name="${selectName}">
			<c:forEach items="${selectList}" var="select">
				<option value="${select.codeValue}" <c:if test="${select.codeValue eq selectData}">selected="selected"</c:if>><spring:message code="option.code.${select.codeKey}" text="${select.codeLabel}" htmlEscape="true"/></option>
			</c:forEach>
		</select>
		<input type="text" class="opt-txt form-control" autocomplete="off" name="${textName}" value="${textData}">
	</div>
</div>
