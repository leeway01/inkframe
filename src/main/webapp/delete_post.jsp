<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
String username = (String) session.getAttribute("username");
if (username == null) {
    response.sendRedirect("login.jsp"); // 로그인되지 않은 경우 로그인 페이지로 리다이렉트
    return;
}

String dbURL = "jdbc:h2:tcp://localhost/~/webProject";
String dbUser = "root";
String dbPassword = "1234";
String userRole = "";

// DB에서 사용자 역할(role) 조회
try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
     PreparedStatement stmt = conn.prepareStatement("SELECT role FROM USERS WHERE username = ?")) {
    stmt.setString(1, username);
    try (ResultSet rs = stmt.executeQuery()) {
        if (rs.next()) {
            userRole = rs.getString("role");
        }
    }
}

// 관리자 권한 확인
if (!"admin".equals(userRole)) {
    response.sendRedirect("error.jsp"); // 권한 부족 시 에러 페이지로 리다이렉트
    return;
}

// 게시글 ID 가져오기
String postIdParam = request.getParameter("post_id");
int postId = (postIdParam != null) ? Integer.parseInt(postIdParam) : -1;

// 데이터 삭제
try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
    conn.setAutoCommit(false); // 트랜잭션 시작

    // LIKES 테이블에서 삭제
    try (PreparedStatement stmtLikes = conn.prepareStatement("DELETE FROM LIKES WHERE post_id = ?")) {
        stmtLikes.setInt(1, postId);
        stmtLikes.executeUpdate();
    }

    // COMMENT 테이블에서 삭제
    try (PreparedStatement stmtComments = conn.prepareStatement("DELETE FROM COMMENT WHERE post_id = ?")) {
        stmtComments.setInt(1, postId);
        stmtComments.executeUpdate();
    }

    // POST 테이블에서 삭제
    try (PreparedStatement stmtPost = conn.prepareStatement("DELETE FROM POST WHERE post_id = ?")) {
        stmtPost.setInt(1, postId);
        int rows = stmtPost.executeUpdate();

        if (rows > 0) {
            conn.commit(); // 모든 삭제가 성공하면 커밋
            response.sendRedirect("notice.jsp"); // 삭제 후 공지사항 페이지로 이동
        } else {
            conn.rollback(); // 실패 시 롤백
            response.getWriter().println("게시글 삭제 실패");
        }
    }
} catch (Exception e) {
    e.printStackTrace();
    response.getWriter().println("오류 발생: " + e.getMessage());
}
%>
