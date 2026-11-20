<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<ul id="category-parent" class="category-parent-wrapper">
	<c:forEach items="${categoryList}" var="parentMap">
		<li id="${parentMap.categoryUid}">
			<div class="category-parent d-flex align-items-center" 
				attr-depth="${parentMap.depth}" 
				attr-categoryUid="${parentMap.categoryUid}"
				attr-categoryName="${parentMap.categoryName}"
				attr-flagActivated="${parentMap.flagActivated}">
				${parentMap.categoryName}
			</div>
			<ul id="category-${parentMap.categoryUid}" class="category-child">
				<c:forEach items="${parentMap.childList}" var="childMap">
					<li id="${childMap.categoryUid}" class="d-flex align-items-center" 
						attr-depth="${childMap.depth}" 
						attr-categoryUid="${childMap.categoryUid}"
						attr-categoryName="${childMap.categoryName}"
						attr-urlPath="${childMap.urlPath}"
						attr-flagActivated="${childMap.flagActivated}">
						└→ ${childMap.categoryName}
					</li>
				</c:forEach>
			</ul>
		</li>
	</c:forEach>
</ul>
<script>
	function fnSaveOrder(categoryArray){
		$.ajax({
			type			: 'post'
			, url			: './save-category-order'
			, contentType 	: 'application/json'
			, data			:  JSON.stringify({categoryArray : categoryArray})
			, success		: function(data){
				if(data.resultCode == 1){
					openToast('<spring:message code="common.orderSaved" javaScriptEscape="true"/>');
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
	$(document).ready(function(){
		let id 			= '#category-parent';
	    let $category 	= $(id);
	    $category.sortable({
			containment	: id
			, tolerance	: 'pointer'
			, cursor	: 'move'
			, update	: function(){
                let categoryArray = $(this).sortable('toArray');
                fnSaveOrder(categoryArray);
			}
	    });
	    $category.disableSelection();
	})
</script>
<c:forEach items="${categoryList}" var="parentMap">
	<script>
		$(document).ready(function(){
			let id 			= '#category-${parentMap.categoryUid}';
		    let $category 	= $(id);
		    $category.sortable({
				containment	: id
		      	, tolerance	: 'pointer'
		      	, cursor	: 'move'
		    	, update	: function(){
					let categoryArray = $(this).sortable('toArray');
					fnSaveOrder(categoryArray);
				}
		    });
		    $category.disableSelection();    
		})
	</script>
</c:forEach>
