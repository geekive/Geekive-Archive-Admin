<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<c:set var="pageContent">
<script>
	$(function(){
		let $profileImage 	= $('.profile-picture-wrapper img');
		let $file 			= $('.profile-picture-wrapper input[type="file"]');
		let $hidden 		= $file.prev();
		
		function fnReset(){
			$file.val('');$hidden.val('');
		}
		
		$profileImage.on('click', function(){
			$file.trigger('click');
		})
		
		$file.on('change', function(){
			if(this.files.length > 0){
				let type = this.files[0].type;
				if(!type.includes('image')){
					fnReset();
					openModal({
						type 		: 'alert'
						, title		: '<spring:message code="article.label" javaScriptEscape="true"/>'
						, message	: '<spring:message code="common.imageOnly" javaScriptEscape="true"/>'
					})
					return
				}

				pixelarity.open(this.files[0], true, function(succ, res){
					if(succ){
						if(isEmpty(res)){
							openModal({
								type 		: 'alert'
								, title		: '<spring:message code="common.preview" javaScriptEscape="true"/>'
								, message	: '<spring:message code="common.previewFailed" javaScriptEscape="true"/>'
							})
							return
						}
						$profileImage.attr('src', res);
						$hidden.val(res);
					}else{
						fnReset();
					}
				}, 'jpg', 1)
			}else{
				fnReset();
				return
			}
		})
		
		let $userName 						= $('input[name="userName"]');
		let $archiveName 					= $('input[name="archiveName"]');
		const initialArchiveName = $archiveName[0].defaultValue.trim();
		let archiveNameEdited = false;
		let $currentPassword 				= $('input[name="currentPassword"]');
		let $password 						= $('input[name="password"]');
		let $passwordCheck 					= $('#passwordCheck');
		let $btnSave 						= $('#btn-save')
		
		$userName.on('input', function(){
			$(this).val($(this).val().replace(/[^^\p{L}\s]/gu, '').replace(/\s{2,}/g, ' '));
		})
		
		$archiveName.attr('autocomplete', 'off').on('beforeinput', function(event) {
			if (event.originalEvent && event.originalEvent.cancelable) {
				archiveNameEdited = true;
			}
		}).on('input', function(){
			$(this).val($(this).val().replace(/[^a-zA-Z0-9]/g, '').toLowerCase());
		})
		
		$password.on('input', function(){
			fnPasswordRegularExpression($(this));
		})
		
		$passwordCheck.on('input', function(){
			fnPasswordRegularExpression($(this));
		})
		
		function fnPasswordRegularExpression($this){
			$this.val($this.val().replace(/[^A-Za-z0-9!@#$%^&*(),.?:{}|<>_-]/g, ''));
		}
		
		$btnSave.on('click', async function(){
			await fnSave();
			$btnSave.prop('disabled', false);
	    });
		
		async function fnSave(){
			$btnSave.prop('disabled', true);
			
	        if(isEmpty($userName.val())){
	        	openModal({
                    type		: 'alert'
                    , title		: '<spring:message code="profile.label" javaScriptEscape="true"/>'
                    , message	: '<spring:message code="profile.nameRequired" javaScriptEscape="true"/>'
                    , close		: function(){
                    	$userName.focus();
                    }
                });
	        	return
	        }
	        
			const archiveName = archiveNameEdited ? $archiveName.val().trim() : initialArchiveName;
			const archiveNameChanged = archiveName !== initialArchiveName;
			$archiveName.val(archiveName);
			if (archiveNameChanged) {
				if (isEmpty(archiveName)) {
					openModal({
						type: 'alert', title: '<spring:message code="profile.label" javaScriptEscape="true"/>', message: '<spring:message code="profile.archiveRequired" javaScriptEscape="true"/>',
						close: () => $archiveName.focus()
					});
					return;
				}

				const request = {
					type: 'post',
					contentType: 'application/json',
					data: JSON.stringify({archiveName: archiveName})
				};
				const checkResponse = await $.ajax({
					...request,
					url: getFullPath('/user/check-archive-name-existence')
				});
				if (checkResponse.resultCode == 0) {
					openModal({
						type: 'alert', title: '<spring:message code="profile.label" javaScriptEscape="true"/>', message: checkResponse.resultMessage,
						close: () => $archiveName.focus()
					});
					return;
				}
				const availability = await $.ajax({
					...request,
					url: getFullPath('/user/check-archive-name-update-available')
				});
				if (availability.resultCode == 0) {
					openModal({
						type: 'alert', title: '<spring:message code="profile.label" javaScriptEscape="true"/>', message: availability.resultMessage,
						close: () => $archiveName.val(initialArchiveName).focus()
					});
					return;
				}
			}
	        
			let password = $password.val();
			let passwordCheck = $passwordCheck.val();
			if (isNotEmpty(password) || isNotEmpty(passwordCheck)) {
				if (isEmpty($currentPassword.val())) {
					openModal({
						type: 'alert', title: '<spring:message code="profile.label" javaScriptEscape="true"/>', message: '<spring:message code="profile.currentPasswordRequired" javaScriptEscape="true"/>',
						close: () => $currentPassword.focus()
					});
					return;
				}
				if (password !== passwordCheck) {
					openModal({
						type: 'alert', title: '<spring:message code="profile.label" javaScriptEscape="true"/>', message: '<spring:message code="profile.passwordMismatch" javaScriptEscape="true"/>',
						close: () => $password.focus()
					});
					return;
				}
				if (password.length < 10 || password.length > 72 || !isPasswordFormat(password)) {
					openModal({
						type: 'alert', title: '<spring:message code="profile.label" javaScriptEscape="true"/>', message: '<spring:message code="profile.passwordFormat" javaScriptEscape="true"/>',
						close: () => $password.focus()
					});
					return;
				}
			}
	        
	        async function fnUpdate(){
				let formData;
				$archiveName.prop('disabled', !archiveNameChanged);
				try {
					formData = $('#form').getFormData();
				} finally {
					$archiveName.prop('disabled', false);
				}
	        	let updateResponse = await $.ajax({
		            type			: 'post'
		            , url			: getFullPath('/user/save-profile')
		            , contentType 	: false
					, processData 	: false
		            , data			: formData
		        });
		        let modalParam = {
	                type 		: 'alert'
	                , title 	: '<spring:message code="profile.label" javaScriptEscape="true"/>'
	                , message 	: updateResponse.resultMessage
	                , close 	: () => {
	                	if(updateResponse.resultCode == 1){
	                		location.reload();
	                	}
	                }
				}
		        openModal(modalParam);
	        }
	        
			if (archiveNameChanged) {
	    		openModal({
					type 		: 'confirm'
					, title		: '<spring:message code="profile.label" javaScriptEscape="true"/>'
					, message	: '<spring:message code="profile.confirmArchiveChange" javaScriptEscape="true"/>'
					, button	: '<spring:message code="common.save" javaScriptEscape="true"/>'
					, confirm	: function(){
						fnUpdate();
					}
				})
	        }else{
	        	fnUpdate();
	        }
		}
		
		let $btnDelete = $('#btn-delete');
		$btnDelete.on('click', function(){
			openModal({
				type 		: 'confirm'
				, title		: '<spring:message code="profile.label" javaScriptEscape="true"/>'
				, message	: '<spring:message code="profile.deleteNotice" javaScriptEscape="true"/>'
				, button	: '<spring:message code="common.delete" javaScriptEscape="true"/>'
				, confirm	: async function(){
					let deleteResponse = await $.ajax({
						type			: 'post'
						, url			: getFullPath('/user/delete-user')
						, contentType	: 'application/json'
			        })
			        let modalParam = {
		                type 		: 'alert'
		                , title 	: '<spring:message code="profile.label" javaScriptEscape="true"/>'
		                , message 	: deleteResponse.resultMessage
		                , close 	: () => {
		                	if(deleteResponse.resultCode == 1){
		                		goToPage('/');
		                	}
		                }
					}
			        openModal(modalParam);
				}
			})
		})
	})
</script>
	<form id="form" class="profile-form">
		
		<div class="profile-picture-wrapper d-flex align-items-center justify-content-center">
			<img class="rounded-circle" src="${userMap.profileImageUrlPath}" onerror="getErrorImageUrl(this, 'profile')" width="200">
			<input type="hidden" name="profileImage">
			<input type="file" class="hide" name="profileImage" accept="image/*">
		</div>

		<div class="profile-opt-wrapper">
			<c:import url="/option/text">
				<c:param name="label"><spring:message code="profile.email"/></c:param>
				<c:param name="maxlength">100</c:param>
				<c:param name="readonly">true</c:param>
				<c:param name="data">${userMap.email}</c:param>
			</c:import>
			
			<c:import url="/option/text">
				<c:param name="label"><spring:message code="profile.name"/></c:param>
				<c:param name="name">userName</c:param>
				<c:param name="maxlength">20</c:param>
				<c:param name="data">${userMap.userName}</c:param>
			</c:import>
			
			<c:import url="/option/text">
				<c:param name="label"><spring:message code="profile.archive"/></c:param>
				<c:param name="name">archiveName</c:param>
				<c:param name="maxlength">10</c:param>
				<c:param name="data">${userMap.archiveName}</c:param>
			</c:import>
			
			<c:import url="/option/password">
				<c:param name="label"><spring:message code="profile.currentPassword"/></c:param>
				<c:param name="name">currentPassword</c:param>
			</c:import>

			<c:import url="/option/password">
				<c:param name="label"><spring:message code="profile.newPassword"/></c:param>
				<c:param name="name">password</c:param>
				<c:param name="maxlength">72</c:param>
			</c:import>
			
			<c:import url="/option/password">
				<c:param name="label"><spring:message code="common.confirm"/></c:param>
				<c:param name="id">passwordCheck</c:param>
				<c:param name="name">passwordCheck</c:param>
				<c:param name="maxlength">72</c:param>
				<c:param name="placeholder"><spring:message code="profile.confirmPassword"/></c:param>
			</c:import>
		</div>
		
		<div class="opt-wrapper row">
			<div class="col-xxl-12 text-end">
				<button type="button" id="btn-save" class="btn btn-outline-dark"><spring:message code="common.save"/></button>
				<button type="button" id="btn-delete" class="btn btn-outline-danger"><spring:message code="profile.deleteAccount"/></button>
			</div>
		</div>
	</form>
	<script>
		var rwc = new ResponsiveWebController();
		rwc.addAndRemoveDflexAt(810);
	</script>
</c:set>
<%@ include file="/WEB-INF/jsp/common/layout.jsp" %>
