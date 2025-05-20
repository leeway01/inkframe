<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.io.*, java.net.*, org.json.JSONArray, org.json.JSONObject"%>
<%
String username = (String) session.getAttribute("username");
String imagePath = (String) session.getAttribute("generatedImagePath");
String summary = (String) session.getAttribute("summary"); // 세션에서 요약 결과 가져오기

if (summary == null || summary.isEmpty()) {
    // 새 요청일 경우 요약 처리
    String story = request.getParameter("story");
    String linesParam = request.getParameter("lines");
    int summaryLines = (linesParam != null) ? Integer.parseInt(linesParam) : 6; // 기본값: 6줄
    String apiUrl = "https://api.openai.com/v1/chat/completions";
    String apiKey = "gpt-key";

    try {
        if (story != null && !story.trim().isEmpty()) {
            HttpURLConnection conn = null;
            URL url = new URL(apiUrl);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + apiKey);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            JSONObject requestBody = new JSONObject();
            requestBody.put("model", "gpt-4");
            JSONArray messages = new JSONArray();
            StringBuilder promptBuilder = new StringBuilder();
            promptBuilder.append("다음 줄거리를 번호를 붙여 요약하세요. ");
            promptBuilder.append("각 번호는 줄바꿈하여 작성하세요. ");
            promptBuilder.append("문장은 ").append(summaryLines).append("개로 만들어줘.");
            String prompt = promptBuilder.toString();
            messages.put(new JSONObject().put("role", "system").put("content", prompt));
            messages.put(new JSONObject().put("role", "user").put("content", story)); // 입력 줄거리
            requestBody.put("messages", messages);
            requestBody.put("max_tokens", 4096); // 토큰 수 증가

            OutputStream os = conn.getOutputStream();
            os.write(requestBody.toString().getBytes("UTF-8"));
            os.close();

            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
                StringBuilder apiResponse = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    apiResponse.append(line);
                }
                br.close();

                // JSON 파싱 및 요약 결과 저장
                JSONObject responseJson = new JSONObject(apiResponse.toString());
                summary = responseJson.getJSONArray("choices").getJSONObject(0).getJSONObject("message")
                        .getString("content").trim();

                // 세션에 요약 결과 저장
                session.setAttribute("summary", summary);
            } else {
                out.println("<p>요약 요청에 실패했습니다. 오류 코드: " + responseCode + "</p>");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>요약 처리 중 오류가 발생했습니다: " + e.getMessage() + "</p>");
    }
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>INKFRAME 요약 결과</title>
<style>
/* 기본 스타일 */
body {
	margin: 0;
	font-family: 'Arial', sans-serif;
	color: #333;
	box-sizing: border-box;
}

.container {
	width: 70%;
	max-width: 800px;
	margin: 0 auto;
	padding: 20px;
}

header {
	background-color: white;
	box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

header .container {
	display: flex;
	justify-content: space-between;
	align-items: center;
}

header .logo {
	font-size: 20px;
	font-weight: bold;
}

header nav ul {
	list-style: none;
	display: flex;
	gap: 15px;
	padding: 0;
	margin: 0;
}

header nav ul li a {
	text-decoration: none;
	color: #333;
	font-size: 18px;
}

form {
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 15px;
	margin-top: 20px;
	padding: 20px;
	background-color: #f9f9f9;
	border: 1px solid #ddd;
	border-radius: 8px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

textarea {
	width: 100%;
	max-width: 800px;
	height: 300px;
	padding: 15px;
	font-size: 16px;
	border: 1px solid #ccc;
	border-radius: 8px;
	resize: none;
	box-sizing: border-box;
	background-color: #fff;
	color: #333;
}

button {
	padding: 15px 25px;
	font-size: 16px;
	font-weight: bold;
	color: white;
	background-color: #7f00ff;
	border: none;
	border-radius: 8px;
	cursor: pointer;
	transition: background-color 0.3s ease, transform 0.2s ease;
}

button:hover {
	background-color: #e100ff;
	transform: scale(1.05);
}

#summary-result {
	margin-top: 20px;
	padding: 20px;
	background-color: #fff;
	border: 1px solid #ddd;
	border-radius: 8px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
	text-align: left;
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
}

#summary-result p {
	font-size: 18px;
	color: #333;
	line-height: 1.5;
	text-align: left; /* 텍스트는 여전히 왼쪽 정렬 */
	width: 100%; /* 텍스트 영역 너비를 설정 */
	max-width: 800px; /* 텍스트 최대 너비 */
}

#summary-result h2 {
	font-size: 24px;
	margin-bottom: 15px;
	color: #7f00ff;
}

a {
	text-decoration: none;
	color: black;
}

a:hover {
	text-decoration: none;
}

#image-creation {
	margin-top: 40px;
	padding: 20px;
	background-color: #f9f9f9;
	border: 1px solid #ddd;
	border-radius: 8px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
	display: flex; /* 가로 배치 */
	gap: 20px; /* 두 영역 간 간격 */
	justify-content: space-between; /* 영역 사이 간격 */
	max-width: 1200px; /* 전체 UI 최대 너비 */
	margin: 0 auto; /* 가운데 정렬 */
}

.image-input, .image-output {
	flex: 1; /* 동일한 비율로 크기를 나눔 */
	padding: 20px;
	background-color: #fff;
	border: 1px solid #ddd;
	border-radius: 8px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
	display: flex;
	flex-direction: column; /* 내부 요소는 세로 배치 */
	justify-content: space-between; /* 버튼과 텍스트 박스 간격 확보 */
}

.image-input h2, .image-output h2 {
	font-size: 20px;
	color: #7f00ff;
	margin-bottom: 15px;
}

textarea#image-text {
	width: 100%;
	height: 150px;
	padding: 10px;
	font-size: 14px;
	border: 1px solid #ccc;
	border-radius: 8px;
	resize: none;
	box-sizing: border-box;
	background-color: #fff;
	color: #333;
	margin-bottom: 15px;
}

button#create-image, button#save-image {
	padding: 10px 20px;
	font-size: 14px;
	font-weight: bold;
	color: white;
	background-color: #7f00ff;
	border: none;
	border-radius: 8px;
	cursor: pointer;
	transition: background-color 0.3s ease, transform 0.2s ease;
	margin-right: 10px; /* 버튼 간 간격 */
}

button#create-image:hover, button#save-image:hover {
	background-color: #e100ff;
	transform: scale(1.05);
}

#image-display {
	width: 100%;
	height: 300px;
	background-color: #f0f0f0;
	border: 1px dashed #ccc;
	display: flex;
	justify-content: center;
	align-items: center;
	border-radius: 8px;
	font-size: 16px;
	color: #888;
}

#image-display img {
	max-width: 100%;
	max-height: 100%;
	border-radius: 8px;
}
</style>
</head>
<body>
	<header>
		<div class="container">
			<div class="logo">
				<a href="main.jsp">INKFRAME</a>
			</div>
			<nav>
				<ul>
					<li>
						<% if (username != null) { %> <a href="logout.jsp">🚪</a> <% } %>
					</li>
					<li>
						<% if (username != null) { %> <%= username %>님 <% } else { %> <a
						href="login.jsp">LOGIN</a> <% } %>
					</li>
				</ul>
			</nav>
		</div>
	</header>
	<main>
		<div id="summary-result">
			<h2>요약 결과</h2>
			<div>
				<% if (summary != null) { %>
				<p><%= summary.replace("\n", "<br>") %></p>
				<% } else { %>
				<p>요약 내용이 없습니다.</p>
				<% } %>
			</div>
		</div>
		<section id="image-creation">
			<div class="image-input">
				<h2>이미지 제작</h2>
				<form action="generateImage.jsp" method="post">
					<textarea name="imageDescription" id="image-text"
						placeholder="이미지 설명을 입력하세요..." required></textarea>
					<button type="submit">이미지 제작</button>
				</form>
			</div>
			<div class="image-output">
				<h2>이미지 결과물</h2>
				<div id="image-display">
					<% if (imagePath != null) { %>
					<img src="image?path=<%= imagePath %>" alt="생성된 이미지" />
					<% } else { %>
					<p>생성된 이미지가 없습니다.</p>
					<% } %>
				</div>
			</div>
		</section>
	</main>
</body>
</html>
