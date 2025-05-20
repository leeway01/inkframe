<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*, java.sql.*, org.json.JSONObject, org.json.JSONArray"%>
<%
String username = (String) session.getAttribute("username");
String description = request.getParameter("imageDescription");

// 입력 확인
if (description == null || description.trim().isEmpty()) {
    out.println("<p>이미지 설명을 입력하세요.</p>");
    return;
}

// OpenAI ChatGPT API 설정
String openaiApiUrl = "https://api.openai.com/v1/chat/completions";
String openaiApiKey = "gpt-key"; // OpenAI API 키
String translatedDescription = ""; // 번역된 텍스트 저장

try {
    // ChatGPT API를 사용하여 번역 요청
    URL openAiUrl = new URL(openaiApiUrl);
    HttpURLConnection openAiConn = (HttpURLConnection) openAiUrl.openConnection();
    openAiConn.setRequestMethod("POST");
    openAiConn.setRequestProperty("Authorization", "Bearer " + openaiApiKey);
    openAiConn.setRequestProperty("Content-Type", "application/json");
    openAiConn.setDoOutput(true);

    // ChatGPT 요청 본문
    JSONObject openAiRequestBody = new JSONObject();
    openAiRequestBody.put("model", "gpt-4");
    JSONArray messages = new JSONArray();
    messages.put(new JSONObject().put("role", "system").put("content", "Translate the following text into English."));
    messages.put(new JSONObject().put("role", "user").put("content", description));
    openAiRequestBody.put("messages", messages);

    OutputStream os = openAiConn.getOutputStream();
    os.write(openAiRequestBody.toString().getBytes("UTF-8"));
    os.close();

    // 번역 결과 처리
    int openAiResponseCode = openAiConn.getResponseCode();
    if (openAiResponseCode == 200) {
        BufferedReader br = new BufferedReader(new InputStreamReader(openAiConn.getInputStream(), "UTF-8"));
        StringBuilder openAiResponse = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            openAiResponse.append(line);
        }
        br.close();

        JSONObject responseJson = new JSONObject(openAiResponse.toString());
        translatedDescription = responseJson.getJSONArray("choices").getJSONObject(0).getJSONObject("message").getString("content").trim();
    } else {
        out.println("<p>ChatGPT API 호출 실패: " + openAiResponseCode + "</p>");
        return;
    }
} catch (Exception e) {
    e.printStackTrace();
    out.println("<p>번역 중 오류가 발생했습니다: " + e.getMessage() + "</p>");
    return;
}

// Stability AI API 및 데이터베이스 설정
String stabilityApiUrl = "https://api.stability.ai/v2beta/stable-image/generate/sd3";
String stabilityApiKey = "sk-Y0grkfvflhd703qCF2qLdT7hHRtwEka4jdzM9kuBftu1v9zI"; // Stability AI API 키
String savePath = "C:/Temp/img/" + username + "/";
File userDir = new File(savePath);
if (!userDir.exists()) {
    userDir.mkdirs();
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
int countImage = 1;

try {
    // 데이터베이스 연결
    Class.forName("org.h2.Driver");
    conn = DriverManager.getConnection("jdbc:h2:tcp://localhost/~/webProject", "root", "1234");

    // 현재 count_image 값 조회
    String selectQuery = "SELECT count_image FROM users WHERE username = ?";
    pstmt = conn.prepareStatement(selectQuery);
    pstmt.setString(1, username);
    rs = pstmt.executeQuery();
    if (rs.next()) {
        countImage = rs.getInt("count_image") + 1;
    }
    rs.close();
    pstmt.close();

    // 파일 이름 설정
    String fileName = countImage + ".jpeg";
    String filePath = savePath + fileName;

    // Stability AI API 호출
    URL stabilityUrl = new URL(stabilityApiUrl);
    HttpURLConnection stabilityConn = (HttpURLConnection) stabilityUrl.openConnection();
    stabilityConn.setRequestMethod("POST");
    stabilityConn.setRequestProperty("Authorization", "Bearer " + stabilityApiKey);
    stabilityConn.setRequestProperty("Content-Type", "multipart/form-data; boundary=----Boundary12345");
    stabilityConn.setRequestProperty("Accept", "image/*");
    stabilityConn.setDoOutput(true);

    // Stability 요청 본문
    String boundary = "----Boundary12345";
    OutputStream os = stabilityConn.getOutputStream();
    PrintWriter writer = new PrintWriter(new OutputStreamWriter(os, "UTF-8"), true);

    writer.append("--" + boundary).append("\r\n");
    writer.append("Content-Disposition: form-data; name=\"prompt\"").append("\r\n");
    writer.append("\r\n");
    writer.append(translatedDescription).append("\r\n");

    writer.append("--" + boundary).append("\r\n");
    writer.append("Content-Disposition: form-data; name=\"cfg_scale\"").append("\r\n\r\n");
    writer.append("7").append("\r\n");

    writer.append("--" + boundary).append("\r\n");
    writer.append("Content-Disposition: form-data; name=\"height\"").append("\r\n\r\n");
    writer.append("512").append("\r\n");

    writer.append("--" + boundary).append("\r\n");
    writer.append("Content-Disposition: form-data; name=\"width\"").append("\r\n\r\n");
    writer.append("512").append("\r\n");

    writer.append("--" + boundary).append("\r\n");
    writer.append("Content-Disposition: form-data; name=\"steps\"").append("\r\n\r\n");
    writer.append("50").append("\r\n");

    writer.append("--" + boundary + "--").append("\r\n");
    writer.flush();
    writer.close();

    // Stability API 응답 처리
    int stabilityResponseCode = stabilityConn.getResponseCode();
    if (stabilityResponseCode == 200) {
        InputStream in = stabilityConn.getInputStream();
        FileOutputStream fos = new FileOutputStream(filePath);

        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = in.read(buffer)) != -1) {
            fos.write(buffer, 0, bytesRead);
        }

        fos.close();
        in.close();

        // count_image 값 업데이트
        String updateQuery = "UPDATE users SET count_image = ? WHERE username = ?";
        pstmt = conn.prepareStatement(updateQuery);
        pstmt.setInt(1, countImage);
        pstmt.setString(2, username);
        pstmt.executeUpdate();
        pstmt.close();

        // 세션에 이미지 경로 저장
        session.setAttribute("generatedImagePath", "img/" + username + "/" + fileName);

        // summarize.jsp로 리다이렉트
        response.sendRedirect("summarize.jsp");
    } else {
        BufferedReader errorReader = new BufferedReader(new InputStreamReader(stabilityConn.getErrorStream(), "UTF-8"));
        StringBuilder stabilityResponse = new StringBuilder();
        String errorLine;
        while ((errorLine = errorReader.readLine()) != null) {
            stabilityResponse.append(errorLine);
        }
        errorReader.close();

        out.println("<p>Stability API 호출 실패: " + stabilityResponseCode + "</p>");
        out.println("<pre>" + stabilityResponse.toString() + "</pre>");
    }
} catch (Exception e) {
    e.printStackTrace();
    out.println("<p>이미지 생성 중 오류가 발생했습니다: " + e.getMessage() + "</p>");
} finally {
    try {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>
