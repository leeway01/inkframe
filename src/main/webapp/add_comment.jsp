<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // DB 연결 정보
    String dbURL = "jdbc:h2:tcp://localhost/~/webProject";
    String dbUser = "root";
    String dbPassword = "1234";

    request.setCharacterEncoding("UTF-8"); // 인코딩 설정
    int postId = Integer.parseInt(request.getParameter("post_id")); // 대상 게시글 ID
    String content = request.getParameter("content"); // 댓글 내용
    String username = (String) session.getAttribute("username"); // 댓글 작성자 이름

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    int authorId = -1;

    try {
        Class.forName("org.h2.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        // 작성자 ID 조회
        String userQuery = "SELECT user_id FROM USERS WHERE username = ?";
        stmt = conn.prepareStatement(userQuery);
        stmt.setString(1, username);
        rs = stmt.executeQuery();

        if (rs.next()) {
            authorId = rs.getInt("user_id");
        }
        rs.close();
        stmt.close();

        // 댓글 저장
        String insertComment = "INSERT INTO COMMENT (post_id, author_id, content, create_time) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
        stmt = conn.prepareStatement(insertComment);
        stmt.setInt(1, postId);
        stmt.setInt(2, authorId);
        stmt.setString(3, content);
        stmt.executeUpdate();

        response.sendRedirect("post_view.jsp?post_id=" + postId); // 댓글 작성 후 게시글 페이지로 리다이렉트
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>
