<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<c:set var="pageContent">
	<form id="form">
		<script>
			let rwc = new ResponsiveWebController();
			rwc.addAndRemoveDflexAt(810);
		</script>
		
		<input type="hidden" name="articleUid" value="${articleMap.articleUid}">
	
		<c:import url="/option/radio">
			<c:param name="label">category</c:param>
			<c:param name="name">categoryUid</c:param>		
			<c:param name="codeType">category</c:param>
			<c:param name="data">${articleMap.categoryUid}</c:param>
		</c:import>
		
		<c:import url="/option/radio">
			<c:param name="label">activated</c:param>
			<c:param name="name">flagActivated</c:param>
			<c:param name="codeType">YES_NO</c:param>
			<c:param name="data">${articleMap.flagActivated}</c:param>
		</c:import>
		
		<c:import url="/option/radio">
			<c:param name="label">private</c:param>
			<c:param name="name">flagPrivate</c:param>
			<c:param name="codeType">YES_NO</c:param>
			<c:param name="data">${empty articleMap.flagPrivate ? 'N' : articleMap.flagPrivate}</c:param>
		</c:import>

		<c:import url="/option/image">
			<c:param name="label">thumbnail</c:param>
			<c:param name="name">thumbnail</c:param>
			<c:param name="crop">true</c:param>
			<c:param name="preview">true</c:param>
			<c:param name="data">${articleMap.thumbnailUid}</c:param>
		</c:import>

		<c:import url="/option/text">
			<c:param name="label">title</c:param>
			<c:param name="name">title</c:param>
			<c:param name="maxlength">100</c:param>
			<c:param name="data">${articleMap.title}</c:param>
		</c:import>
	
		<c:import url="/option/tinymce">
			<c:param name="label">content</c:param>
			<c:param name="id">contentEditor</c:param>
			<c:param name="name">content</c:param>
			<c:param name="height">500px</c:param>
			<c:param name="width">100%</c:param>
			<c:param name="data">${articleMap.content}</c:param>
		</c:import>
		
		<div class="opt-wrapper row">
			<div class="col-xxl-12 text-end">
				<button type="button" id="btn-save" class="btn btn-outline-dark">save</button>
				<button type="button" id="btn-back" class="btn btn-outline-dark">back</button>
			</div>
		</div>
	</form>
	
	<script>
		$(document).ready(function(){
			/* event :: s */
			// save button
			$('#btn-save').on('click', function(){			
				let $title = $('input[name="title"]');
				if(isEmpty($title.val())){
					openModal({
						type 		: 'alert'
						, title		: 'content'
						, message	: 'fill in title.'
						, close		: function(){
							$title.focus();
						}
					})
					return
				}
				if(isEmpty(tinymceEditor.getContent())){
					openModal({
						type 		: 'alert'
						, title		: 'content'
						, message	: 'fill in content.'
						, close		: function(){
							tinymceEditor.focus();
						}
					})
					return
				}

	   			$.ajax({
					type		: 'post',
					url			: './save',
					contentType : false,
					processData : false,
					data		: $('#form').getFormData(),
					success		: function(data){
						if(data.resultCode == 1){
							openModal({
								type 		: 'alert'
								, title		: 'category'
								, message	: 'data has been successfully saved.'
								, close		: function(){
									goToPage('/content/article/view?articleUid=' + data.articleUid);
								}
							})
						}else if(data.resultCode == 0){
							openModal({
								type 		: 'alert'
								, title		: 'category'
								, message	: data.resultMessage
							})
						}
					}
				});
			})
			
			$('#btn-back').on('click', function(){
				window.history.back();
			})
			/* event :: e */
		})
	</script>
</c:set>
<%@ include file="/WEB-INF/jsp/common/layout.jsp" %>
