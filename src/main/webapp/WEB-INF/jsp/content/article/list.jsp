<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<c:set var="pageContent">
	<form id="form">
		<c:import url="/option/checkbox">
			<c:param name="label">category</c:param>
			<c:param name="name">categoryUid</c:param>		
			<c:param name="codeType">category</c:param>		
			<c:param name="data">${categoryUidCSV}</c:param>		
		</c:import>
		
	 	<c:import url="/option/search">
			<c:param name="label">search</c:param>
			<c:param name="selectName">searchOption</c:param>
			<c:param name="selectData">${searchOption}</c:param>
			<c:param name="textName">searchValue</c:param>
			<c:param name="textData">${searchValue}</c:param>		
		</c:import>
		
		<div class="opt-wrapper row">
			<div class="col-xxl-12 text-end">
				<button type="button" id="btn-search" class="btn btn-outline-dark">search</button>
				<button type="button" id="btn-reset" class="btn btn-outline-dark">reset</button>
			</div>
		</div>
		
		<hr class="opt-separation"></hr>
		
		<div>
			<table class="table table-hover article-list-table">
				<thead>
					<tr>
						<th scope="col" class="article-number-column article-full-text">number</th>
						<th scope="col" width="10%" class="d-none d-lg-table-cell article-full-text">category</th>
						<th scope="col" class="text-start">title</th>
						<th scope="col" width="12%" class="d-none d-lg-table-cell">author</th>
						<th scope="col" width="12%" class="d-none d-lg-table-cell">activation state</th>
						<th scope="col" width="12%" class="d-none d-lg-table-cell article-full-text">date</th>
					</tr>
				</thead>
				<tbody>
					<c:choose>
						<c:when test="${!empty articleList}">
							<c:forEach items="${articleList}" var="articleMap" varStatus="status">
								<tr align="center" onclick="goToPage('/content/article/view?articleUid=${articleMap.articleUid}')">
									<th scope="row" class="article-full-text">${articleMap.num}</th>
								<td class="d-none d-lg-table-cell article-full-text">${articleMap.categoryName}</td>
								<td class="text-start">
									<div class="d-flex align-items-center gap-2">
										<c:if test="${articleMap.flagPrivate eq 'Y'}">
											<span class="badge text-bg-dark flex-shrink-0">Private</span>
										</c:if>
										<span class="text-truncate"><c:out value="${articleMap.title}"/></span>
									</div>
								</td>
									<td class="d-none d-lg-table-cell">${articleMap.registrationUser}</td>
									<td class="d-none d-lg-table-cell">${articleMap.flagActivated}</td>
								<td class="d-none d-lg-table-cell article-full-text">${articleMap.registrationDate}</td>
								</tr>
							</c:forEach>
						</c:when>
						<c:otherwise>
							<tr align="center">
								<td colspan="6" class="d-none d-lg-table-cell">No data</td>
								<td colspan="2" class="d-lg-none">No data</td>
							</tr>
						</c:otherwise>
					</c:choose>



				</tbody>
			</table>
		</div>
		
		<div class="bottom-btn-wrapper d-flex justify-content-end">
			<button type="button" class="btn btn-outline-dark" onclick="goToPage('/content/article/write')">write</button>
		</div>
	
		<div class="pagination-wrapper d-flex justify-content-center">
			<nav aria-label="Page navigation example">
				<ul class="pagination">
					<c:if test="${paginationMap.flagPreviousPageButtonGroup}">
						<li class="page-item">
							<a class="page-link" href="javascript:fnSearch('${paginationMap.pageNumberToPreviousPageButtonGroup}')" aria-label="Previous"> <span aria-hidden="true">&laquo;</span></a>
						</li>
					</c:if>
					<c:forEach items="${paginationMap.pageNumberList}" var="pageNumber">
						<li class="page-item ${paginationMap.currentPageNumber eq pageNumber ? 'active' : ''}">
							<a class="page-link" href="javascript:fnSearch('${pageNumber}')">${pageNumber}</a>
						</li>
					</c:forEach>
					<c:if test="${paginationMap.flagNextPageButtonGroup}">
						<li class="page-item">
							<a class="page-link" href="javascript:fnSearch('${paginationMap.pageNumberToNextPageButtonGroup}')" aria-label="Next"> <span aria-hidden="true">&raquo;</span></a>
						</li>
					</c:if>
				</ul>
			</nav>
		</div>
	</form>
	<script>
		var rwc = new ResponsiveWebController();
		rwc.addAndRemoveDflexAt(810);
	</script>
	<script>
		let fnSearch = function(pageNumber){
			if(pageNumber){
				$('<input>').attr({type : 'hidden', name : 'currentPageNumber', value : pageNumber}).appendTo('#form');
			}
		    $('#form').submit();
		}
		$(function(){
			$('#btn-search').on('click', function(){
				fnSearch();
			})
			$('#btn-reset').on('click', function(){
				fnResetOption('categoryUid');
				fnResetOption('searchOption');
				fnResetOption('searchValue');
			})
		})
	</script>
</c:set>
<%@ include file="/WEB-INF/jsp/common/layout.jsp" %>
