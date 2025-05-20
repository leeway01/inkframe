package inkframe.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/image")
public class ImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getParameter("path"); // 이미지 경로를 파라미터로 받음
        
        if (path == null || path.contains("..")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid image path");
            return;
        }

        // 요청의 referer 헤더 확인
        String referer = request.getHeader("Referer");
        String imagePath;

        if (referer != null && referer.contains("post_view.jsp")) {
            // post_view.jsp에서 요청된 경우
            imagePath = "C:/Temp/post-image/" + path;
        } else {
            // 다른 JSP에서 요청된 경우
            imagePath = "C:/Temp/" + path;
        }

        File file = new File(imagePath);
        if (!file.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
            return;
        }

        response.setContentType(getServletContext().getMimeType(imagePath));
        response.setContentLength((int) file.length());

        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}
