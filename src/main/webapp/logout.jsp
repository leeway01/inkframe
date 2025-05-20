<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 세션 무효화
    session.invalidate();
%>
<script>
    alert("로그아웃 되었습니다.");
    window.location.href = "main.jsp";
</script>
