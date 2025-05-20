<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>회원가입 결과</title>
<script>
        // JavaScript 알림 함수
        function showAlert(message) {
            alert(message);
            // 입력 필드 초기화
            document.getElementById("signupForm").reset();
        }
    </script>
</head>
<body>
	<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    boolean isRegistered = false;
    String errorMessage = "";

    try {
    	 // H2 JDBC 드라이버 로드
        Class.forName("org.h2.Driver");
        // H2 데이터베이스 연결
        String dbURL = "jdbc:h2:tcp://localhost/~/webProject"; // 데이터베이스 경로
        String dbUser = "root";               // 사용자 이름
        String dbPassword = "1234";           // 비밀번호

        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        String sql = "INSERT INTO USERS (username, password, role) VALUES (?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, username);
        pstmt.setString(2, password);
        pstmt.setString(3, "user");

        int rows = pstmt.executeUpdate();
        if (rows > 0) {
            isRegistered = true;
        }

        pstmt.close();
        conn.close();
    } catch (SQLIntegrityConstraintViolationException e) {
        errorMessage = "중복된 아이디가 존재합니다. 다른 아이디를 입력해주세요.";
    } catch (SQLException e) {
        errorMessage = "데이터베이스 오류: " + e.getMessage();
    } catch (Exception e) {
        errorMessage = "알 수 없는 오류 발생:  + e.getMessage()";
    }

    if (isRegistered) {
    	%>
    	    <h1>회원가입 성공</h1>
    	    <p>환영합니다, <%= username %>님!</p>
    	    <a href="login.jsp">로그인 페이지로 이동</a>
    	<%
    	    } else {
    	%>
    	    <h1>회원가입 실패</h1>
    	    <p>회원가입 중 문제가 발생했습니다. 다시 시도해주세요.</p>
    	    <%= errorMessage %>
    	    <a href="signup.jsp">회원가입 페이지로 돌아가기</a>
    	<%
    	    }
%>
</body>
</html>
