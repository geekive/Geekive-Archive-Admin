<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>

<c:set var="pageContent">
<style>
.developing{
	display: flex !important;
	align-items: center !important;
	justify-content: center !important;
	font-weight: bold;
}

.home-wrapper{
	height: 94.3%; 
	margin-left: 0px; 
	margin-right: 0px; 
}

.home-wrapper .section{
	min-height: 50%;
}

.home-wrapper .section:nth-of-type(1) {
  padding-bottom: 20px;
}

.home-wrapper .section:nth-of-type(odd) {
  border-right: 1px solid black;
}

.home-wrapper .section:nth-of-type(4n+3),
.home-wrapper .section:nth-of-type(4n+4) {
  border-top: 1px solid black;
}

.home-wrapper .section .title{
	height: 15%;
	font-weight: bold;
	text-decoration: underline;
	user-select: none;
}

.home-wrapper .section .content{
	height: 85%;
}

.article-info{
	height: 19%;
}

.article-info:hover{
	background-color: rgba(0, 0, 0, 0.1);
	cursor: pointer;
}

.article-info:not(:last-of-type) {
  border-bottom: 1.5px solid rgba(0, 0, 0, 0.2);
}

.article-info  img{
	max-height: 59.68px;
	flex-shrink: 0;
}

.article-info .article-title{
	flex: 1;
	min-width: 0;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.article-info .article-view-count{
	flex-shrink: 0;
	white-space: nowrap;
}

@media ( max-width : 1199px) {
	.home-wrapper .section:nth-of-type(4n+3),
	.home-wrapper .section:nth-of-type(4n+4) {
	  border-top: 0px solid black;
	}

	.home-wrapper .section:nth-of-type(odd) {
	  border-right: 0px solid black;
	}
	
	.home-wrapper .section{
		border-bottom: 1px solid black;
		margin-bottom: 20px;
	}
	
}

@media ( max-height : 810px) {
	.article-info  img{
		max-height: 49.68px;
	}
}

@media ( max-height : 660px) {
	.article-info  img{
		max-height: 39.68px;
	}
}

@media ( max-height : 540px) {
	.article-info  img{
		display: none;
	}
}
</style>
	<div class="home-wrapper row">
	
		<!-- section :: Traffic Trend for My Archive -->
	    <div class="section col-xl-6">
			<div class="title d-flex align-items-center justify-content-center"><spring:message code="home.traffic"/></div>
	    	<div class="content">
	     		<canvas id="section01"></canvas>
	     	</div>
	    </div>
	    
	    <!-- section :: Top 5 Most Viewed Articles in the Last 30 Days -->
	    <div class="section col-xl-6">
			<div class="title d-flex align-items-center justify-content-center"><spring:message code="home.topArticles"/></div>
			<div class="content">
				<c:choose>
					<c:when test="${!empty top5ArticleList}">
						<c:forEach items="${top5ArticleList}" var="top5Article">
							<div class="article-info d-flex align-items-center" onclick="goToPage('/content/article/view?articleUid=${top5Article.articleUid}')">
								<img src="${top5Article.thumbnailUrlPath}" onerror="getErrorImageUrl(this, 'thumbnail')">
								<div class="article-title p-2">
									${top5Article.title}
								</div>
								<div class="article-view-count p-2">
									${top5Article.viewCount} <spring:message code="home.views"/>
								</div>
							</div>
						</c:forEach>				
					</c:when>
					<c:otherwise>
						<spring:message code="home.noViews"/>
					</c:otherwise>
				</c:choose>

	     	</div>
	    </div>
	    
	    <!-- section :: empty -->
	    <div class="section col-xl-6">
			<div class="title d-flex align-items-center justify-content-center"><spring:message code="home.empty"/></div>
	    	<div class="content developing">
	     	</div>
	    </div>
	    
	    <!-- section :: empty -->
	    <div class="section col-xl-6">
			<div class="title d-flex align-items-center justify-content-center"><spring:message code="home.empty"/></div>
	    	<div class="content developing">
	     	</div>
	    </div>
	    
	    <script>
	    	let dot = 0;
	    	setInterval(function(){
	    		if(dot > 6) {
		    		dot = 0;
	    		}
				let msg = '<spring:message code="home.developing" javaScriptEscape="true"/>';
	    		for(let i = 0; i < dot; i++) {
	    			msg += '.';
	    		}	
	    		$('.developing').html(msg);
	    		dot++;
	    	}, 300)
	    </script>
	</div>
	<script>
		let monthArray 		= new Array();
		let visitCountArray = new Array();
		let maxNumber 	= 0;
		<c:forEach items="${trafficTrendList}" var="trafficTrend">
			monthArray.push('${trafficTrend.month}');
			visitCountArray.push('${trafficTrend.visitCount}');
		</c:forEach>
		
		for(let i = 0; i < visitCountArray.length; i++) {
			let visitCount = parseInt(visitCountArray[i]);
			if(visitCount > maxNumber) {
				maxNumber = visitCount;
			}
		}
		maxNumber += Math.ceil(maxNumber * 0.1);
	
		let section01 		= document.getElementById('section01');

		let section01Chart = new Chart(section01, {
			type : 'line',
			data : {
				labels : monthArray,
				datasets : [ {
					label : '<spring:message code="home.visitors" javaScriptEscape="true"/>',
					data : visitCountArray,
					backgroundColor : '#292929',
					maxBarThickness : 30
				} ]
			},
			options : {
				responsive : true, // 반응형 여부 (기본값 true)
				maintainAspectRatio : false, // 크기 고정
				plugins : {
					tooltip : { // 튤팁 스타일링
						enabled : true, // 튤팁 활성화 (기본값 true)
						backgroundColor : '#000', // 튤팁 색상
						padding : 10
					// 튤팁 패딩
					},
					legend : { // 범례 스타일링
						display : false, // 범례 활성화 (기본값 true)
						position : 'bottom' // 범례 위치
					}
				},
				scales : { // x축과 y축에 대한 설정
					x : {
						grid : { // 축에 대한 격자선
							display : false, // grid 활성화 (기본값 true)
						}
					},
					y : {
						min : 0,
						max : maxNumber,
						border : {
							dash : [ 5, 5 ]
						},
						ticks : {
							precision : 0
						// 소수점 0자리로 설정
						}
					}
				}
			}
		});
	</script>
</c:set>
<%@ include file="/WEB-INF/jsp/common/layout.jsp" %>
