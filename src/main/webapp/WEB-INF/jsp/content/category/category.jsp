<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<c:set var="pageContent">
	<form id="form">
		<input type="hidden" name="categoryUid">
		<input type="hidden" name="parentCategoryUid">
		<input type="hidden" name="currentMode" value="add"> 
		
		<div class="category-wrapper row">
			<div id="category-tree-wrapper" class="category-tree-wrapper col d-flex justify-content-center"></div>
			<script>
				$(function(){
					if (navigator.userAgentData?.mobile || window.matchMedia('(hover: none) and (pointer: coarse)').matches) {
						return;
					}
					openBallon({
						id 			: 'category-tree-wrapper'
						, direction : 'right'
						, message	: '<spring:message code="settings.dragCategory" javaScriptEscape="true"/>'
					})
				})
			</script>
			<div class="menu-option-wrapper col-xl-8">
				
				<c:import url="/option/radio">
					<c:param name="label"><spring:message code="settings.depth"/></c:param>
					<c:param name="name">depth</c:param>
					<c:param name="codeType">CATEGORY_DEPTH</c:param>
				</c:import>
			
				<c:import url="/option/radio">
					<c:param name="label"><spring:message code="state.activated"/></c:param>
					<c:param name="name">flagActivated</c:param>
					<c:param name="codeType">YES_NO</c:param>
				</c:import>
			
	 			<c:import url="/option/text">
					<c:param name="label"><spring:message code="settings.parentCategory"/></c:param>
					<c:param name="name">parentCategory</c:param>
					<c:param name="placeholder"><spring:message code="settings.chooseParentCategory"/></c:param>
					<c:param name="readonly">true</c:param>
					<c:param name="hide">true</c:param>
				</c:import>
				
				<c:import url="/option/text">
					<c:param name="label"><spring:message code="settings.categoryName"/></c:param>
					<c:param name="name">categoryName</c:param>
					<c:param name="maxlength">40</c:param>
				</c:import>
				
				<c:import url="/option/text">
					<c:param name="label"><spring:message code="settings.url"/></c:param>
					<c:param name="name">urlPath</c:param>
					<c:param name="placeholder"><spring:message code="settings.autoUrl"/></c:param>
					<c:param name="maxlength">40</c:param>
					<c:param name="hide">true</c:param>
				</c:import>
			
				<div class="btn-wrapper row">
					<div class="col-xxl-12 text-end">
						<button type="button" id="btn-mode" class="btn btn-outline-dark"><spring:message code="settings.editMode"/></button>
						<button type="button" id="btn-save" class="btn btn-outline-dark"><spring:message code="common.save"/></button>
						<button type="button" id="btn-reset" class="btn btn-outline-dark"><spring:message code="common.reset"/></button>
						<button type="button" id="btn-delete" class="btn btn-outline-danger hide"><spring:message code="common.delete"/></button>
					</div>
				</div>
			</div>
		</div>
	</form>
	<script type="text/javascript">
		$(document).ready(function(){
			// objects used a lot
			let obj = {
					$depth 					: $('input[name="depth"]')
					, $flagActivated 		: $('input[name="flagActivated"]')
					, $parentCategory		: $('input[name="parentCategory"]')
					, $categoryName 		: $('input[name="categoryName"]')
					, $urlPath 				: $('input[name="urlPath"]')
					, $btnDelete			: $('#btn-delete')
					, $categoryUid 			: $('input[name="categoryUid"]')
					, $parentCategoryUid 	: $('input[name="parentCategoryUid"]')
					, $currentMode 			: $('input[name="currentMode"]')
			}
			
			/* category list -------------------------------------- start */
			// draw category jsp
       		$.ajax({
				type		: 'post'
				, url		: './category-list'
				, dataType	: 'html'
				, success	: function(data){
					$('.category-tree-wrapper').html(data);
					
					let $category = $('.category-parent, .category-child > li');
					$category.on('click', function(){
						fnDrawCategoryData($(this));
						
						$category.removeClass('category-clicked');
						$(this).addClass('category-clicked');
					})
				}
			});

			// function - put data
    		function fnDrawCategoryData($category){
    			let currentMode 	= obj.$currentMode.val();
    		    let depth 			= $category.attr('attr-depth');
    		    let categoryUid		= $category.attr('attr-categoryUid');
    		    let categoryName	= $category.attr('attr-categoryName');
    		    let urlPath			= $category.attr('attr-urlPath');
    		    let flagActivated	= $category.attr('attr-flagActivated');
    		    
    		    if(currentMode == 'add'){
    		    	if(depth == 1 && obj.$depth.filter(':checked').key() == 'CD-02'){
    		    		obj.$parentCategory.val(categoryName);
        		 		obj.$parentCategoryUid.val(categoryUid);
    		    	}
    		    }else if(currentMode == 'edit'){
    		    	obj.$categoryUid.val(categoryUid);
  
    		    	// depth checkbox
        		    let $targetDepth = obj.$depth.filter('[value="' + depth + '"]');
        		    $targetDepth.prop('checked', true).prop('disabled', false);
        		    obj.$depth.not($targetDepth).prop('disabled', true);
        		    
        		    // flagActivated checkbox
        		    obj.$flagActivated.filter('[value="' + flagActivated + '"]')
        		    	.prop('checked', true);
        		 	
        		    if(depth == 1){
        		    	fnHideOptionWrapper(obj.$parentCategory);
        		    	fnHideOptionWrapper(obj.$urlPath);
        		 		
        		 		obj.$parentCategory.val('');
        		 		obj.$parentCategoryUid.val('');
        		 	}else{
        		 		let $categoryParent 	= $category.parent().siblings('.category-parent');
        		 		let parentCategoryName 	= $categoryParent.attr('attr-categoryName');
        		 		let parentCategoryUid 	= $categoryParent.attr('attr-categoryUid');

        		 		fnShowOptionWrapper(obj.$parentCategory);
        		 		fnShowOptionWrapper(obj.$urlPath);
 
        		 		obj.$parentCategory.val(parentCategoryName);
        		 		obj.$parentCategoryUid.val(parentCategoryUid);
        		 		obj.$urlPath.val('/' + urlPath.toLowerCase());
        		 	}
        		    obj.$categoryName.val(categoryName);
    		    }
    		}
			/* category list -------------------------------------- end */

			/* event --------------------------------------- start */
    		// mode button
			$('#btn-mode').on('click', function(){
    			let currentMode = obj.$currentMode.val();
    			let targetMode	= currentMode == 'add' ? 'edit' : 'add';
    			
    			// modify mode button
    			fnChangeModeButton(targetMode);
    			
    			if(targetMode == 'add'){	
    				fnReset();
    			}else if(targetMode == 'edit'){
    				// show delete button
    				fnShowObject(obj.$btnDelete);
    				
    				let $category = $('.category-clicked');
    				if($category.length == 0){
    					$category = $('.category-parent:first');
    					$category.addClass('category-clicked');
    				}
    				fnDrawCategoryData($category);
    			}
    		})
    		
    		// function - change button's attribute and hidden data
    		function fnChangeModeButton(targetMode){
				// change currren mode value
    			obj.$currentMode.val(targetMode);
    			
    			// modify mode button
				$('#btn-mode').attr('attr-current-mode', targetMode).html(targetMode == 'add' ? '<spring:message code="settings.editMode" javaScriptEscape="true"/>' : '<spring:message code="settings.addMode" javaScriptEscape="true"/>');
			}
			
			obj.$categoryName.on('input', function () {
			    let value = $(this).val().replace(/\s+/g, ' ').replace(/[^a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ()'!?.\s]/g, '');
				$(this).val(value);

			    let urlPath = '/' + value.replace(/\s+/g, '-').replace(/[^a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\-]/g, '');
			    obj.$urlPath.val(urlPath.toLowerCase());
			});
			
			obj.$urlPath.on('input', function () {
			    let value = '/' + $(this).val().replace(/[^a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ-]/g, '');
			    $(this).val(value.toLowerCase());
			});
    		
			// save button
    		$('#btn-save').on('click', function(){
    			let currentMode = obj.$currentMode.val();
    			let key			= obj.$depth.filter(':checked').key();
    			if(currentMode == 'add' && key == 'CD-02'){
    				if(isEmpty(obj.$parentCategoryUid.val())){
    					openModal({
    						type 		: 'alert'
							, title		: '<spring:message code="article.category" javaScriptEscape="true"/>'
							, message	: '<spring:message code="settings.parentCategoryRequired" javaScriptEscape="true"/>'
    					})
    					return
    				}
    			}
    			if(isEmpty(obj.$categoryName.val())){
					openModal({
						type 		: 'alert'
						, title		: '<spring:message code="article.category" javaScriptEscape="true"/>'
						, message	: '<spring:message code="settings.categoryRequired" javaScriptEscape="true"/>'
						, close		: function(){
							obj.$categoryName.focus();
						}
					})
					return
    			}
    			if(key == 'CD-02'){
        			if(isEmpty(obj.$urlPath.val().replace('/', ''))){
    					openModal({
    						type 		: 'alert'
							, title		: '<spring:message code="article.category" javaScriptEscape="true"/>'
							, message	: '<spring:message code="settings.urlRequired" javaScriptEscape="true"/>'
    						, close		: function(){
    							obj.$urlPath.focus();
    						}
    					})
    					return
        			}else{
        				obj.$urlPath.val(obj.$urlPath.val().toLowerCase());
        			}
    			}

    			$.ajax({
					type	: 'post',
					url		: './save-category',
					contentType : 'application/json',
					data	: $('#form').getStringifiedJSON(),
					success	: function(data){
						if(data.resultCode == 1){
							openModal({
								type 		: 'alert'
								, title		: '<spring:message code="article.category" javaScriptEscape="true"/>'
								, message	: '<spring:message code="common.saved" javaScriptEscape="true"/>'
								, close		: function(){
									location.reload();
								}
							})
						}else if(data.resultCode == 0){
							openModal({
								type 		: 'alert'
								, title		: '<spring:message code="article.category" javaScriptEscape="true"/>'
								, message	: data.resultMessage
							})
						}
					}
				});
    		})
    		
    		// reset button
    		$('#btn-reset').on('click', function(){
    			fnReset();
    		})
    		function fnReset(){
    			fnHideOptionWrapper(obj.$parentCategory);
    			fnHideObject(obj.$btnDelete);
    			obj.$depth.prop('disabled', false);
    			obj.$depth.first().prop('checked', true);
    			obj.$flagActivated.first().prop('checked', true);
    			obj.$parentCategory.val('');
    			obj.$parentCategoryUid.val('');
    			obj.$categoryName.val('');
    			obj.$categoryUid.val('');
    			fnChangeModeButton('add');
    			$('.category-clicked').removeClass('category-clicked');
    		}
			
			// delete button
			obj.$btnDelete.on('click', function(){
				let $category 	= $('.category-clicked');
				let depth		= $category.attr('attr-depth');
				
				if(depth == 1 && $category.siblings('.category-child').children('li').length > 0){
					openModal({
						type 		: 'alert'
						, title		: '<spring:message code="article.category" javaScriptEscape="true"/>'
						, message	: '<spring:message code="settings.categoryHasChildren" javaScriptEscape="true"/>'
					})
					return
				}
				
				openModal({
					type 		: 'confirm'
					, title		: '<spring:message code="article.category" javaScriptEscape="true"/>'
					, message	: '<spring:message code="settings.confirmDeleteCategory" javaScriptEscape="true"/>'
					, button	: '<spring:message code="common.delete" javaScriptEscape="true"/>'
					, confirm	: function(){
						$.ajax({
							type			: 'post'
							, url			: './delete-category'
							, contentType 	: 'application/json'
							, data			: $('#form').getStringifiedJSON()
							, success		: function(data){
								if(data.resultCode == 1){
									openModal({
										type 		: 'alert'
										, title		: '<spring:message code="article.category" javaScriptEscape="true"/>'
										, message	: '<spring:message code="common.deleted" javaScriptEscape="true"/>'
										, close		: function(){
											location.reload();
										}
									})
								}else if(data.resultCode == 0){
									openModal({
										type 		: 'alert'
										, title		: '<spring:message code="article.category" javaScriptEscape="true"/>'
										, message	: data.resultMessage
									})
								}
							}
						});
					}
				})
			})
			
			// depth checkbox     		
			obj.$depth.on('change', function(){
    			let key = $(this).key();
    			if(key == 'CD-01'){
    				fnHideOptionWrapper(obj.$parentCategory);
    				fnHideOptionWrapper(obj.$urlPath);
    			}else if(key == 'CD-02'){
    				fnShowOptionWrapper(obj.$parentCategory);
					fnShowOptionWrapper(obj.$urlPath);
    			}
		 		obj.$parentCategory.val('');
		 		obj.$parentCategoryUid.val('');
		 		obj.$categoryName.val('');
		 		obj.$urlPath.val('');
    		})
			/* event --------------------------------------- end */
		})
	</script>
</c:set>
<%@ include file="/WEB-INF/jsp/common/layout.jsp" %>
