<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<div class="opt-wrapper row ${hide eq true ? 'hide' : ''}">
	<div class="opt-label col-1 d-flex align-items-center justify-content-center">${optionLabel}</div>
	<div class="opt-content col d-flex align-items-center">
		<div class="row">
			<c:if test="${all}">
				<div class="opt-chkbox col-1">
					<input class="chkbox-all form-check-input" type="checkbox" id="checkbox-all-${name}" attr-name="${name}" <c:if test="${fn:length(data) eq 0}">checked="checked"</c:if>>
					<label class="form-check-label" for="checkbox-all-${name}"><spring:message code="common.all"/></label>
				</div>
			</c:if>
		
			<c:forEach var="checkbox" items="${checkboxList}">
				<div class="opt-chkbox col-1">
					<input class="chkbox form-check-input" type="checkbox" id="checkbox-${checkbox.checkboxKey}" key="${checkbox.checkboxKey}" name="${name}" value="${checkbox.checkboxValue}" 
						<c:if test="${fn:length(data) eq 0 or (fn:contains(fn:join(data, ','), checkbox.checkboxKey) or fn:endsWith(fn:join(data, ','), checkbox.checkboxKey))}">checked="checked"</c:if>>
					<label class="form-check-label" for="checkbox-${checkbox.checkboxKey}"><spring:message code="option.code.${checkbox.checkboxKey}" text="${checkbox.checkboxLabel}" htmlEscape="true"/></label>
				</div>
			</c:forEach>
		</div>
	</div>
</div>
