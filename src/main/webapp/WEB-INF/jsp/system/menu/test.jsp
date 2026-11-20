<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/jstlcore.jsp"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<script type="text/javascript" charset="utf-8" src="<c:url value="/js/jquery/jquery-3.7.1.min.js"/>"></script>
	
	
		<link rel="stylesheet" type="text/css" href="<c:url value="/css/bootstrap/bootstrap.css"/>"/>
	
	<title>GEEKIVE LAB</title>
</head>
<body>

<div class="dropdown">
<a class="dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
  Dropdown link
</a>

<ul class="dropdown-menu">
  <li><a class="dropdown-item" href="#"><spring:message code="common.english"/></a></li>
  <li><a class="dropdown-item" href="#"><spring:message code="common.korean"/></a></li>
</ul>
</div>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js" integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous"></script>
<script type="text/javascript" charset="utf-8" src="<c:url value="/js/bootstrap/bootstrap.js"/>"></script>

</body>
</html>
