<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<div id="article-viewers" class="opt-wrapper row ${hide eq true ? 'hide' : ''}">
	<div class="opt-label col-1 d-flex align-items-center justify-content-center text-center">
		<label for="article-viewer-query"><c:out value="${optionLabel}"/></label>
	</div>
	<div class="opt-content col d-flex align-items-center">
		<div class="opt-txt">
			<div id="article-viewer-lookup" class="position-relative">
				<input type="search" class="form-control" id="article-viewer-query" placeholder="Search by archive name" maxlength="40" autocomplete="off" aria-controls="article-viewer-results">
				<div id="article-viewer-suggestions" class="article-viewer-suggestions position-absolute top-100 start-0 w-100 bg-white border rounded-bottom shadow-sm overflow-auto" hidden>
					<div id="article-viewer-status" class="small px-3 py-2" role="status"></div>
					<div id="article-viewer-results" class="list-group list-group-flush"></div>
				</div>
			</div>
			<ul id="article-viewer-selection" class="article-viewer-selection list-unstyled d-flex flex-wrap gap-2 mb-0">
				<c:forEach items="${requestScope.articleViewers}" var="viewer">
					<li class="badge article-viewer-badge bg-white text-dark border border-dark rounded-pill d-inline-flex align-items-center gap-1 fw-normal text-wrap text-break mw-100" data-viewer-uid="<c:out value='${viewer.userUid}'/>">
						<img class="article-viewer-avatar rounded-circle flex-shrink-0" src="<c:out value='${viewer.profileImageUrlPath}'/>" alt="" onerror="this.onerror = null; getErrorImageUrl(this, 'profile');">
						<span><c:out value="${viewer.archiveName}"/></span>
						<button type="button" class="btn-close flex-shrink-0 remove-article-viewer" aria-label="Remove <c:out value='${viewer.archiveName}'/>"></button>
					</li>
				</c:forEach>
			</ul>
			<input type="hidden" id="article-viewer-uids">
		</div>
	</div>
</div>

<script>
	$(document).ready(function(){
		const $viewerOption = $('#article-viewers');
		const $viewerLookup = $('#article-viewer-lookup');
		const $viewerQuery = $('#article-viewer-query');
		const $viewerSuggestions = $('#article-viewer-suggestions');
		const $viewerStatus = $('#article-viewer-status');
		const $viewerResults = $('#article-viewer-results');
		const $viewerSelection = $('#article-viewer-selection');
		const $viewerUids = $('#article-viewer-uids');
		const $privacy = $('input[name="flagPrivate"]');
		let viewerSearch;
		let viewerSearchTimer;

		function isPrivate() {
			return $privacy.filter(':checked').val() === 'Y';
		}

		function selectedViewerUids() {
			return $viewerSelection.children().map(function() {
				return $(this).attr('data-viewer-uid');
			}).get();
		}

		function updateViewerUids() {
			$viewerUids.val(selectedViewerUids().join(','));
		}

		updateViewerUids();
		$privacy.on('change', function() {
			$viewerOption.toggleClass('hide', !isPrivate());
			if (!isPrivate()) {
				clearViewerSuggestions();
				$viewerQuery.val('');
			}
		});
		$viewerSelection.on('click', '.remove-article-viewer', function() {
			$(this).closest('li').remove();
			updateViewerUids();
			$viewerStatus.empty();
		});
		$viewerLookup.on('focusout', function(event) {
			if (event.relatedTarget && !this.contains(event.relatedTarget)) {
				clearViewerSuggestions();
			}
		});
		$(document).on('pointerdown', function(event) {
			if (!$viewerLookup[0].contains(event.target)) {
				clearViewerSuggestions();
			}
		});
		$viewerLookup.on('keydown', function(event) {
			if (event.originalEvent && event.originalEvent.isComposing) {
				return;
			}
			const $first = $viewerResults.children('button').first();
			if (event.key === 'Escape') {
				event.preventDefault();
				$viewerQuery.trigger('focus');
				clearViewerSuggestions();
			} else if (event.target === $viewerQuery[0] && event.key === 'Enter') {
				event.preventDefault();
				$first.trigger('click');
			} else if (event.target === $viewerQuery[0] && event.key === 'ArrowDown' && $first.length) {
				event.preventDefault();
				$first.trigger('focus');
			}
		});

		function clearViewerSuggestions() {
			clearTimeout(viewerSearchTimer);
			if (viewerSearch) {
				viewerSearch.abort();
				viewerSearch = null;
			}
			$viewerResults.empty();
			$viewerStatus.empty();
			$viewerSuggestions.prop('hidden', true);
		}

		$viewerQuery.on('input compositionend focus', function(event) {
			clearViewerSuggestions();
			const query = $viewerQuery.val().trim();
			if (query && !(event.originalEvent && event.originalEvent.isComposing)) {
				viewerSearchTimer = setTimeout(function() {
					searchViewerSuggestions(query);
				}, 180);
			}
		});

		function createViewerAvatar(user) {
			const $avatar = $('<img>', {class: 'article-viewer-avatar rounded-circle flex-shrink-0', alt: ''});
			if (user.profileImageUrlPath) {
				$avatar.one('error', function() {
					getErrorImageUrl(this, 'profile');
				}).attr('src', user.profileImageUrlPath);
			} else {
				getErrorImageUrl($avatar[0], 'profile');
			}
			return $avatar;
		}

		function searchViewerSuggestions(query) {
			$viewerStatus.text('Searching…');
			$viewerSuggestions.prop('hidden', false);
			viewerSearch = $.getJSON(getFullPath('/content/article/viewer-search'), {query: query}).done(function(users) {
				const selected = selectedViewerUids();
				const available = users.filter(user => !selected.includes(user.userUid));
				$viewerStatus.text(available.length ? '' : 'No matching users to add.');
				available.forEach(function(user) {
					$('<button>', {type: 'button', class: 'list-group-item list-group-item-action d-flex align-items-center gap-2'})
						.append(createViewerAvatar(user), $('<span>').text(user.archiveName))
						.on('click', function() {
							if (selectedViewerUids().length >= 100) {
								$viewerStatus.text('Select at most 100 viewers.');
								return;
							}
						$('<li>', {class: 'badge article-viewer-badge bg-white text-dark border border-dark rounded-pill d-inline-flex align-items-center gap-1 fw-normal text-wrap text-break mw-100'})
								.attr('data-viewer-uid', user.userUid)
								.append(createViewerAvatar(user))
								.append($('<span>').text(user.archiveName))
								.append($('<button>', {type: 'button', class: 'btn-close flex-shrink-0 remove-article-viewer', 'aria-label': 'Remove ' + user.archiveName}))
								.appendTo($viewerSelection);
							updateViewerUids();
							clearViewerSuggestions();
							$viewerQuery.val('').trigger('focus');
						}).appendTo($viewerResults);
				});
			}).fail(function(_, status) {
				if (status !== 'abort') {
					$viewerStatus.text('Search failed. Try again.');
				}
			});
		}
	});
</script>
