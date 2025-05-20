<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인 결과</title>
    <script>
        function showAlert(message, redirectURL) {
            alert(message);
            if (redirectURL) {
                window.location.href = redirectURL;
            }
        }
    </script>
</head>
<body>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    boolean isAuthenticated = false;
    String errorMessage = "";

    try {
   	 // H2 JDBC 드라이버 로드
        Class.forName("org.h2.Driver");
        // H2 데이터베이스 연결
        String dbURL = "jdbc:h2:tcp://localhost/~/webProject"; // 데이터베이스 경로
        String dbUser = "root";               // 사용자 이름
        String dbPassword = "1234";           // 비밀번호

        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        // 사용자 인증 SQL
        String sql = "SELECT * FROM Users WHERE username = ? AND password = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, username);
        pstmt.setString(2, password);

        ResultSet rs = pstmt.executeQuery();
        if (rs.next()) {
            isAuthenticated = true; // 사용자가 인증됨
            session.setAttribute("username", username); // 세션에 사용자 이름 저장
        }

        rs.close();
        pstmt.close();
        conn.close();
    } catch (SQLException e) {
        errorMessage = "데이터베이스 오류: " + e.getMessage();
    } catch (Exception e) {
        errorMessage = "알 수 없는 오류 발생: " + e.getMessage();
    }

    if (isAuthenticated) {
%>
    <script>
        showAlert("로그인 성공! 환영합니다, <%= username %>님!", "main.jsp");
    </script>
<%
    } else {
%>
    <script>
        showAlert("로그인 실패: 아이디 또는 비밀번호를 확인하세요.", "login.jsp");
    </script>
<%
    }
%>
</body>
</html>
