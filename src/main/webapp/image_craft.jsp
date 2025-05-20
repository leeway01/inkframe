<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>INKFRAME</title>
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

#story-input {
	width: 800px; /* 가로 크기 */
	height: 300px; /* 세로 크기 */
	padding: 10px;
	font-size: 16px;
	border: 1px solid #ccc;
	border-radius: 5px;
	resize: none; /* 크기 조절 방지 */
	box-sizing: border-box; /* 패딩 포함 크기 계산 */
}

.summary-button {
	margin: 10px;
	padding: 15px;
	font-size: 16px;
	background-color: #7f00ff;
	color: white;
	border: none;
	border-radius: 5px;
	cursor: pointer;
}

.summary-button:hover {
	background-color: #e100ff;
}

/* 기본 form 스타일 */
form {
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 15px; /* 입력 요소 간 간격 */
	margin-top: 20px;
	padding: 20px;
	background-color: #f9f9f9; /* 연한 배경 */
	border: 1px solid #ddd; /* 얇은 테두리 */
	border-radius: 8px; /* 둥근 테두리 */
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 그림자 효과 */
}

/* 입력 텍스트박스 스타일 */
textarea {
	width: 100%;
	max-width: 800px; /* 최대 너비 */
	height: 300px; /* 고정된 높이 */
	padding: 15px;
	font-size: 16px;
	border: 1px solid #ccc; /* 얇은 테두리 */
	border-radius: 8px; /* 둥근 테두리 */
	resize: none; /* 크기 조절 비활성화 */
	box-sizing: border-box;
	background-color: #fff; /* 흰 배경 */
	color: #333; /* 글씨 색상 */
}

/* 버튼 스타일 */
button {
	padding: 15px 25px;
	font-size: 16px;
	font-weight: bold;
	color: white;
	background-color: #7f00ff;
	border: none;
	border-radius: 8px; /* 둥근 버튼 */
	cursor: pointer;
	transition: background-color 0.3s ease, transform 0.2s ease;
}

button:hover {
	background-color: #e100ff; /* 호버 시 색상 변화 */
	transform: scale(1.05); /* 호버 시 크기 살짝 확대 */
}

/* 요약 결과 섹션 스타일 */
#summary-result {
	margin-top: 20px;
	padding: 20px;
	background-color: #fff;
	border: 1px solid #ddd;
	border-radius: 8px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
	text-align: center;
}

#summary-result h2 {
	font-size: 24px;
	margin-bottom: 15px;
	color: #7f00ff; /* 강조된 제목 색상 */
}

#summary-result p {
	font-size: 18px;
	color: #333;
	line-height: 1.5;
}

a {
	text-decoration: none;
	color: black;
}

    
a:visited {
	text-decoration: none;
}

    
a:hover {
	text-decoration: none;
}

    
a:focus {
	text-decoration: none;
}

    
a:hover, a:active {
	text-decoration: none;
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
						<%
						if (username != null) {
						%> <a href="logout.jsp">🚪</a> <%
 }
 %>
					</li>
					<li>
						<%
						if (username != null) {
						%> <%=username%>님 <%
 } else {
 %> <a href="login.jsp">LOGIN</a> <%
 }
 %>
					</li>
				</ul>
			</nav>

		</div>

	</header>

	<main>
		<form id="story-form" action="summarize.jsp" method="post">
			<textarea id="story-input" name="story"
				placeholder="원하시는 만화의 줄거리를 작성해주세요!" required></textarea>
			<input type="number" id="summary-lines" name="lines" min="1"
				placeholder="요약할 줄 수" required>
			<button type="submit" id="summary-check-button">요약 확인하기</button>
		</form>


		<section id="summary-result" style="display: none;">
			<h2>요약 결과</h2>
			<p id="summary-output"></p>
		</section>

	</main>

	<script>
    
    </script>
</body>
</html>
