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
						, title		: 'article'
						, message	: 'only image file is allowed.'
					})
					return
				}

				pixelarity.open(this.files[0], true, function(succ, res){
					if(succ){
						if(isEmpty(res)){
							openModal({
								type 		: 'alert'
								, title		: 'preview'
								, message	: 'Failed to load preview image.'
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
                    , title		: 'profile'
                    , message	: 'Fill in user name.'
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
						type: 'alert', title: 'Profile', message: 'Fill in archive name.',
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
						type: 'alert', title: 'Profile', message: checkResponse.resultMessage,
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
						type: 'alert', title: 'Profile', message: availability.resultMessage,
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
						type: 'alert', title: 'Profile', message: 'Enter your current password.',
						close: () => $currentPassword.focus()
					});
					return;
				}
				if (password !== passwordCheck) {
					openModal({
						type: 'alert', title: 'Profile', message: 'Passwords do not match.',
						close: () => $password.focus()
					});
					return;
				}
				if (password.length < 10 || password.length > 72 || !isPasswordFormat(password)) {
					openModal({
						type: 'alert', title: 'Profile', message: 'Use 10–72 characters, including a letter, a number, and a special character.',
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
	                , title 	: 'Profile'
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
					, title		: 'Profile'
					, message	: 'You seem to have changed the archive name. Once the archive name changes, you cannot change it for 1 week. Are you sure to save?'
					, button	: 'Save'
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
				, title		: 'Profile'
				, message	: '[Account Deletion Notice] <br/><br/> Before proceeding with account deletion, please note the following: <br/><br/> 1. Account Removal: Your account information and profile will be deleted. <br/><br/> 2. Posts: Your posts will be deleted, but comments will remain. <br/><br/> 3. Irreversible Action: Once deleted, your account cannot be restored, and you will not be able to sign up again using the same email.'
				, button	: 'Delete'
				, confirm	: async function(){
					let deleteResponse = await $.ajax({
						type			: 'post'
						, url			: getFullPath('/user/delete-user')
						, contentType	: 'application/json'
			        })
			        let modalParam = {
		                type 		: 'alert'
		                , title 	: 'Profile'
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
				<c:param name="label">Email</c:param>
				<c:param name="maxlength">100</c:param>
				<c:param name="readonly">true</c:param>
				<c:param name="data">${userMap.email}</c:param>
			</c:import>
			
			<c:import url="/option/text">
				<c:param name="label">Name</c:param>
				<c:param name="name">userName</c:param>
				<c:param name="maxlength">20</c:param>
				<c:param name="data">${userMap.userName}</c:param>
			</c:import>
			
			<c:import url="/option/text">
				<c:param name="label">Archive</c:param>
				<c:param name="name">archiveName</c:param>
				<c:param name="maxlength">10</c:param>
				<c:param name="data">${userMap.archiveName}</c:param>
			</c:import>
			
			<c:import url="/option/password">
				<c:param name="label">Current password</c:param>
				<c:param name="name">currentPassword</c:param>
			</c:import>

			<c:import url="/option/password">
				<c:param name="label">New password</c:param>
				<c:param name="name">password</c:param>
				<c:param name="maxlength">72</c:param>
			</c:import>
			
			<c:import url="/option/password">
				<c:param name="label">Confirm</c:param>
				<c:param name="id">passwordCheck</c:param>
				<c:param name="name">passwordCheck</c:param>
				<c:param name="maxlength">72</c:param>
				<c:param name="placeholder">Confirm password</c:param>
			</c:import>
		</div>
		
		<div class="opt-wrapper row">
			<div class="col-xxl-12 text-end">
				<button type="button" id="btn-save" class="btn btn-outline-dark">Save</button>
				<button type="button" id="btn-delete" class="btn btn-outline-danger">Delete account</button>
			</div>
		</div>
	</form>
	<script>
		var rwc = new ResponsiveWebController();
		rwc.addAndRemoveDflexAt(810);
	</script>
</c:set>
<%@ include file="/WEB-INF/jsp/common/layout.jsp" %>
