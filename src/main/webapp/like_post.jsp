<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONObject" %>
<%
    String dbURL = "jdbc:h2:tcp://localhost/~/webProject";
    String dbUser = "root";
    String dbPassword = "1234";

    // 세션에서 사용자 이름 가져오기
    String username = (String) session.getAttribute("username");
    String postIdParam = request.getParameter("post_id");

    JSONObject json = new JSONObject();

    if (username == null) {
        json.put("success", false);
        json.put("message", "로그인이 필요합니다.");
    } else {
        Connection conn = null;
        PreparedStatement checkStmt = null, insertStmt = null;

        try {
            int postId = Integer.parseInt(postIdParam);

            // 데이터베이스 연결
            conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

            // 좋아요 중복 확인
            String checkSQL = "SELECT 1 FROM LIKES WHERE post_id = ? AND user_id = (SELECT user_id FROM USERS WHERE username = ?)";
            checkStmt = conn.prepareStatement(checkSQL);
            checkStmt.setInt(1, postId);
            checkStmt.setString(2, username);

            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                json.put("success", false);
                json.put("message", "이미 좋아요를 눌렀습니다.");
            } else {
                // 좋아요 추가
                String insertSQL = "INSERT INTO LIKES (post_id, user_id) VALUES (?, (SELECT user_id FROM USERS WHERE username = ?))";
                insertStmt = conn.prepareStatement(insertSQL);
                insertStmt.setInt(1, postId);
                insertStmt.setString(2, username);
                insertStmt.executeUpdate();

                json.put("success", true);
                json.put("message", "좋아요 성공");
            }
        } catch (Exception e) {
            json.put("success", false);
            json.put("message", "오류 발생: " + e.getMessage());
        } finally {
            if (checkStmt != null) try { checkStmt.close(); } catch (SQLException ignored) {}
            if (insertStmt != null) try { insertStmt.close(); } catch (SQLException ignored) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    response.getWriter().write(json.toString());
%>
