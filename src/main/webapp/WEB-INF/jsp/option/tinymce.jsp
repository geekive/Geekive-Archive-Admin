<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>
<div class="opt-wrapper row">
	<div class="opt-label col-1 d-flex align-items-center justify-content-center">${optionLabel}</div>
	<div class="opt-content col d-flex align-items-center">
		<textarea id="${id}"></textarea>
		<input type="hidden" name="${name}">
	</div>
</div>
<div id="${id}-data" class="hide">
	${data}
</div>
<script>
let tinymceEditor;
const useDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
const isSmallScreen = window.matchMedia('(max-width: 1023.5px)').matches;
tinymce.init({
	selector : '#${id}'
	, language : '${pageContext.response.locale.language eq 'ko' ? 'ko_KR' : 'en'}'
	, plugins : 'preview importcss searchreplace autolink autosave save directionality code visualblocks visualchars fullscreen image link media codesample table charmap pagebreak nonbreaking anchor insertdatetime advlist lists wordcount help charmap emoticons accordion'
	, editimage_cors_hosts : ['picsum.photos']
	, menubar : 'file edit view insert format tools table help'
	, toolbar : "undo redo | accordion accordionremove | blocks fontfamily fontsize | bold italic underline strikethrough | align numlist bullist | link image | table media | lineheight outdent indent| forecolor backcolor removeformat | charmap emoticons | code fullscreen preview | save print | pagebreak anchor codesample | ltr rtl"
  	, codesample_languages: [
	    {text: 'HTML/XML', value: 'markup'}
	    , {text: 'JavaScript', value: 'javascript'}
	    , {text: 'CSS', value: 'css'}
	    , {text: 'Java', value: 'java'}
	    , {text: 'Nginx', value: 'nginx'}
	    , {text: 'Bash', value: 'bash'}
	    , {text: '.properties', value: 'properties'}
	  ]
	, setup : function (editor){
		tinymceEditor = editor;
		editor.on('init', function(){
			let $content = $('#${id}-data');
			$('input[name="${name}"]').val($content.html());
			fnPutWidthStyle(false, $content);
			editor.setContent($content.html());
			$content.remove();
		});
		editor.on('keyup change', function(e){
			setTimeout(function(){
				let content 	= editor.getContent();
				let $content 	= $('<div></div>').html(content);
				fnPutWidthStyle(true, $content);
				$('input[name="${name}"]').val($content.html());
			}, 100);
		})
		
		editor.on('click', function(e){
			setTimeout(() => {
				let $tinymceNotification = $('.tox-notification--warning');
				if($tinymceNotification.length > 0){
					$tinymceNotification.remove();
				}
			}, 2000)
		})
		let fnPutWidthStyle = function(flag, $object) {
			if(flag){
				$object.find('img, video').each(function(){
					let $el 		= $(this);
					let widthAttr 	= $el.attr('width');

					if(isNotEmpty(widthAttr)){
						$el.css({
							'max-width': '100%',
							'height': 'auto'
						});
					}else{
						$el.css({
							'max-width': $el[0].naturalWidth + 'px',
							'width': '100%'
						});
					}
				});
				$object.find('iframe[src*="youtube"]').each(function(){
					let $el 		= $(this);
					let widthAttr 	= $el.attr('width');
					if(isNotEmpty(widthAttr)){
						$el.css({
							'max-width': '100%'
						});
					}
				});
			}else{
				$object.find('img').each(function(){
					$(this).css({
						'max-width': '',
						'width': ''
					});
				});
			}
		};
	}
	, autosave_ask_before_unload : false
	, autosave_interval : '30s'
	, autosave_prefix : '{path}{query}-{id}-'
	, autosave_restore_when_empty : false
	, autosave_retention : '2m'
	, image_advtab : true
	, link_list : [
		{ title: '<spring:message code="common.examplePage1" javaScriptEscape="true"/>', value: 'https://www.tiny.cloud' },
		{ title: '<spring:message code="common.examplePage2" javaScriptEscape="true"/>', value: 'http://www.moxiecode.com' }
	]
	, image_list : [
		{ title: '<spring:message code="common.examplePage1" javaScriptEscape="true"/>', value: 'https://www.tiny.cloud' },
		{ title: '<spring:message code="common.examplePage2" javaScriptEscape="true"/>', value: 'http://www.moxiecode.com' }
	]
	, image_title : true
	, image_class_list : [
		{ title: '<spring:message code="common.none" javaScriptEscape="true"/>', value: '' },
		{ title: '<spring:message code="common.exampleClass" javaScriptEscape="true"/>', value: 'class-name' }
 	]
	, importcss_append : true
	, file_picker_callback : (callback, value, meta) => {
	    if(meta.filetype === 'file') {
	      callback('https://www.google.com/logos/google.jpg', { text: '<spring:message code="common.exampleText" javaScriptEscape="true"/>' });
	    }
	
	    if(meta.filetype === 'image') {
	      callback('https://www.google.com/logos/google.jpg', { alt: 'My alt text' });
	    }
	
	    if(meta.filetype === 'media') {
	      callback('movie.mp4', { source2: 'alt.ogg', poster: 'https://www.google.com/logos/google.jpg' });
	    }
	}
	, height : 600
	, image_caption : true
	, quickbars_selection_toolbar : 'bold italic | quicklink h2 h3 blockquote quickimage quicktable'
	, noneditable_class : 'mceNonEditable'
	, toolbar_mode : 'sliding'
	, contextmenu : 'link image table'
	/* , skin : useDarkMode ? 'oxide-dark' : 'oxide' */
	/* , content_css : useDarkMode ? 'dark' : 'default' */
	, content_style : 'body { font-family:Helvetica,Arial,sans-serif; font-size:16px }'
	, paste_data_images : false
	, image_uploadtab : false
	/* , images_upload_handler : function (blobInfo, success, failure){
	    let formData = new FormData();
	    formData.append('image', blobInfo.blob(), blobInfo.blob().name);
	    fetch(getFullPath('/uploadTinyMceFile'), {method: 'POST', body: formData})
	    .then(response => {return response.json();})
	    .then(result => {
	      	$('div[aria-label="Notifications"]').remove();
	      	let iframeDocument = $("#contentEditor_ifr")[0].contentWindow.document;
			$(iframeDocument).find("img[src^='blob:']").attr("src", result.url);
	    })
	} */
	, file_picker_callback: function(callback, value, meta){
    	const input = document.createElement('input');

    	if(meta.filetype === 'image'){
    	      input.type = 'file';
    	      input.accept = 'image/*';

    	}else if(meta.filetype === 'media'){
    	      input.type = 'file';
    	      input.accept = 'video/*';

    	}else{
    		return;
    	}
    	
    	input.click();
    	
    	input.onchange = function () {
    		const file = input.files[0];
    		if (!file) return;

    		openLoading();
    		
      		const formData = new FormData();
      		formData.append('tinymce', file, file.name);

      		fetch(getFullPath('/option/upload-tinymce'), {
      			method: 'POST',
				headers: getAdminSessionHeaders(),
      			body: formData
      		})
			.then(response => {
				if (response.status === 409 && response.headers.get('X-Admin-Session-Changed') === 'true') {
					window.location.reload();
					return null;
				}
				return response.json();
			})
      		.then(result => {
      			closeLoading();
				if (!result) return;
      			callback(result.urlPath, { title: file.name });
      		})
      		.catch(() => {
      			closeLoading();
				alert('<spring:message code="common.uploadFailed" javaScriptEscape="true"/>');
      		});		
    	};
	}
});
</script>
