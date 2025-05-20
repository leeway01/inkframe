package inkframe.controller;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;


@WebServlet("/ComicController")
@MultipartConfig(maxFileSize = 1024 * 1024 * 5) // 최대 파일 크기 5MB
public class ComicController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // POST 요청 처리
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("saveComic".equals(action)) {
            saveComicData(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "잘못된 action 요청입니다.");
        }
    }

    private void saveComicData(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        Connection conn = null;

        try {
            // **DB 연결 설정**
            conn = DriverManager.getConnection("jdbc:h2:tcp://localhost/~/webProject", "root", "1234");

            // **POST 테이블에 데이터 저장**
            String title = request.getParameter("title");
            String createTime = request.getParameter("createTime");
            int pageCount = Integer.parseInt(request.getParameter("pageCount"));
            String username = (String) request.getSession().getAttribute("username");

            if (title == null || createTime == null || pageCount <= 0 || username == null) {
                throw new Exception("모든 값을 입력해주세요.");
            }

            // **post_id 자동 증가 (MAX+1)**
            int postId = getNextPostId(conn);

            // **author_id 조회**
            int authorId = getAuthorId(conn, username);

            // **POST 테이블에 데이터 삽입**
            String insertSQL = "INSERT INTO POST (post_id, title, author_id, create_time, page_count) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(insertSQL)) {
                stmt.setInt(1, postId);
                stmt.setString(2, title);
                stmt.setInt(3, authorId);
                stmt.setString(4, createTime);
                stmt.setInt(5, pageCount);
                stmt.executeUpdate();
            }

            // **이미지 파일 저장**
            String uploadPath = "C:/Temp/post-image/" + postId; // 절대 경로 사용
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // **cover 이미지 저장**
            Part coverPart = request.getPart("cover");
            if (coverPart != null && coverPart.getSize() > 0) {
                coverPart.write(uploadPath + "/cover.png");
            }

            int cutIndex = 1;
            for (Part part : request.getParts()) {
                if (part.getName().startsWith("cut")) {
                    part.write(uploadPath + "/" + cutIndex + ".png");
                    cutIndex++;
                }
            }

            // **성공 응답**
            out.write("{\"success\": true, \"postId\": " + postId + "}");
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
        }
    }

    // 다음 post_id 가져오기
    private int getNextPostId(Connection conn) throws SQLException {
        String query = "SELECT COALESCE(MAX(post_id), 0) + 1 AS next_post_id FROM POST";
        try (PreparedStatement pstmt = conn.prepareStatement(query);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("next_post_id");
            } else {
                throw new SQLException("post_id를 가져오는 데 실패했습니다.");
            }
        }
    }

    // 사용자 ID 조회
    private int getAuthorId(Connection conn, String username) throws SQLException {
        String query = "SELECT user_id FROM users WHERE username = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                } else {
                    throw new SQLException("사용자명을 찾을 수 없습니다: " + username);
                }
            }
        }
    }
}
