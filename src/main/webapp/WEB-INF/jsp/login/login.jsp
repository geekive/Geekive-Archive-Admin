<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<c:set var="pageContent">
	<form id="form">
		<div class="d-flex justify-content-center"> 
			<div class="login-container container-fluid d-flex align-items-center justify-content-center">
				<div class="login-wrapper">
					<div class="row">
						<div class="login-ga col-12 text-center">
							<spring:message code="common.indexTitle"/>
						</div>
					</div>
					<div class="mb-3 row">
						<label for="email" class="col-xl-2 col-form-label"><spring:message code="profile.email"/></label>
						<div class="col-12 col-xl-10">
							<input type="text" class="form-control" id="email" name="email" inputmode="email" autocomplete="username">
						</div>
					</div>
					<div id="login-password-row" class="mb-3 row hide">
						<label for="password" class="col-xl-2 col-form-label"><spring:message code="profile.password"/></label>
						<div class="col-12 col-xl-10">
							<input type="password" class="form-control" id="password" name="password" autocomplete="current-password">
						</div>
					</div>
					<div class="row">
						<div class="col-sm-12 text-end">
							<button type="button" id="btn-continue" class="btn btn btn-outline-dark"><spring:message code="common.continue"/></button>
							<button type="button" id="btn-login" class="btn btn btn-outline-dark hide"><spring:message code="common.login"/></button>
						</div>
					</div>
				</div>
			</div>
		</div>
	</form>
	<script>
		$(document).ready(function(){
			
			$('#email').focus();
			
			/* login process : start */
			$('#btn-continue').on('click', function(){
				fnCheckEmail();
			})
		
			$('input[name="email"]').on('keydown', function(event){
	            if(event.keyCode === 13){
	            	fnCheckEmail();
	            }
	        });
		
			$('#btn-login').on('click', function(){
				fnCheckPassword();
			})
			
			$('input[name="password"]').on('keydown', function(event){
	            if(event.keyCode === 13){
	            	fnCheckPassword();
	            }
	        });
			
			function fnCheckEmail(){
				let $btn		= $('#btn-continue');
				let $email 		= $('input[name="email"]');
				let email 		= $.trim($email.val());
				let fnClose		= function(){
					$email.focus();
				}
				if(isEmpty(email)){
					openModal({
						type 		: 'alert'
						, title		: '<spring:message code="common.login" javaScriptEscape="true"/>'
						, message	: '<spring:message code="login.emailRequired" javaScriptEscape="true"/>'
						, close		: fnClose
					})
					return
				}else if(!isEmailFormat(email)){
					openModal({
						type 		: 'alert'
						, title		: '<spring:message code="common.login" javaScriptEscape="true"/>'
						, message	: '<spring:message code="login.invalidEmail" javaScriptEscape="true"/>'
						, close		: fnClose
					})
					return
				}else{
		    		$.ajax({
						type		: 'post',
						url			: './login/check-email',
						contentType : 'application/json',
						data		: $('#form').getStringifiedJSON(),
						success		: function(data){
							if(data.resultCode == 1){
								$email.attr('readonly', true).on('input', () => goToPage('/'));
								$('#login-password-row').removeClass('hide');
								$('#btn-login').removeClass('hide');
								$('input[name="password"]').focus();
								$btn.hide();		
							}else if(data.resultCode == 0){
								openModal({
									type 		: 'alert'
									, title		: '<spring:message code="common.login" javaScriptEscape="true"/>'
									, message	: data.resultMessage
									, close		: fnClose
								})
							}
						}
					});
				}
			}
			
			function fnCheckPassword(){
				let $password 	= $('input[name="password"]');
				let password	= $password.val();
				let fnClose		= function(){
					$password.val('').focus();
				}
				if(isEmpty(password)){
					openModal({
						type 		: 'alert'
						, title		: '<spring:message code="common.login" javaScriptEscape="true"/>'
						, message	: '<spring:message code="login.passwordRequired" javaScriptEscape="true"/>'
						, close		: fnClose
					})
					return
				}else{
		    		$.ajax({
						type		: 'post',
						url			: './login/check-password',
						contentType : 'application/json',
						data		: $('#form').getStringifiedJSON(),
						success		: function(data){
							if(data.resultCode == 1){
								goToPage('', 'replace');
							}else if(data.resultCode == 0){
								openModal({
									type 		: 'alert'
									, title		: '<spring:message code="common.login" javaScriptEscape="true"/>'
									, message	: data.resultMessage
									, close		: fnClose
								})
							}
						}
					});
				}
			}
			/* login process : end */
		})
	</script>
</c:set>
<%@ include file="/WEB-INF/jsp/common/layout.jsp" %>
