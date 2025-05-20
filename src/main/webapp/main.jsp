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
	max-width: 500px;
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

/* 슬라이더 스타일 */
.slider-container {
	position: relative;
	overflow: hidden;
	width: 70%;
	max-width: 800px;
	margin: 0px auto;
}

.slides {
	display: flex; /* 가로로 나열 */
	transition: transform 0.5s ease-in-out; /* 부드러운 전환 효과 */
	width: 100%; /* 슬라이드들이 부모 크기에 맞게 정렬 */
	height: 350px;
}

.slide {
	flex-shrink: 0; /* 슬라이드 크기가 줄어들지 않도록 설정 */
	width: 100%; /* 슬라이드 너비를 부모 너비와 동일하게 설정 */
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 20px;
	background: linear-gradient(45deg, #7f00ff, #e100ff);
	color: black;
	text-align: left;
	box-sizing: border-box; /* 패딩 포함 크기 설정 */
}

.hero .container {
	display: flex; /* Flexbox로 정렬 */
	justify-content: space-between; /* 요소 간 공간 분배 */
	align-items: center; /* 수직 중앙 정렬 */
}

.hero-content {
	display: flex; /* Flexbox 활성화 */
	flex-direction: column; /* 요소를 위에서 아래로 정렬 */
	justify-content: center; /* 수직 중앙 정렬 */
	align-items: flex-start; /* 수평 왼쪽 정렬 */
	height: 100%; /* 부모 요소의 높이에 맞춤 */
	text-align: left; /* 텍스트 왼쪽 정렬 */
}

.hero {
	display: flex; /* 부모 요소도 Flexbox */
	align-items: center; /* 수직 중앙 정렬 */
	height: 400px; /* 섹션 높이 (필요에 따라 변경) */
	padding: 20px; /* 섹션 내부 여백 */
}

.hero-content h1 {
	font-size: 35px;
	margin-bottom: 10px;
}

.hero-content p {
	font-size: 18px;
}

.hero-logo img {
	width: 100%; /* 부모 요소의 너비에 맞춤 */
	height: 100%; /* 부모 요소의 높이에 맞춤 */
	object-fit: cover; /* 이미지 비율을 유지하며 영역 채우기 */
}

/* 부모 요소의 크기 고정 */
.hero-logo {
	width: 200px; /* 너비 */
	height: 200px; /* 높이 */
	display: flex;
	align-items: center; /* 수직 중앙 정렬 */
	justify-content: center; /* 가로 중앙 정렬 */
	overflow: hidden; /* 부모 요소 밖으로 넘치는 부분 숨기기 */
	background-color: #f4f4f400; /* 선택사항: 틀의 배경색 */
	box-sizing: border-box; /* 패딩과 테두리를 포함한 크기 설정 */
}

button {
	position: absolute;
	top: 50%;
	transform: translateY(-50%);
	background-color: rgba(0, 0, 0, 0.5);
	color: white;
	border: none;
	padding: 10px;
	cursor: pointer;
	z-index: 10;
}

button.prev {
	left: 10px;
}

button.next {
	right: 10px;
}

/* Features 스타일 */
.features {
	background-color: #f9f9f9;
	padding: 50px 0;
}

.features .container {
	display: flex;
	justify-content: center;
	gap: 20px;
}

.feature-item .feature-box {
	background: linear-gradient(45deg, #7f00ff, #e100ff);
	color: white;
	text-align: center;
	padding: 30px;
	border-radius: 10px;
	font-size: 30px;
	font-weight: bold;
	width: 150px;
	height: 150px;
	display: flex;
	align-items: center;
	justify-content: center;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
}

#webtoon {
	background: #e1af8a;
	background-image: url('image/logo2.png'); /* 배경 이미지 경로 */
	background-repeat: no-repeat; /* 이미지 반복 없음 */
	background-size: contain; /* 이미지 축소 (비율 유지) */
	background-position: center; /* 이미지 중심 배치 */
	font-weight: bold; /* 두꺼운 글씨 */
	text-shadow: -2px -2px 0 #00dc64, /* 위 왼쪽 */ 2px -2px 0 #00dc64,
		/* 위 오른쪽 */ -2px 2px 0 #00dc64, /* 아래 왼쪽 */ 2px 2px 0 #00dc64,
		/* 아래 오른쪽 */ 0px -2px 0 #00dc64, /* 위 */ 0px 2px 0 #00dc64, /* 아래 */
		  
		 -2px 0px 0 #00dc64, /* 왼쪽 */ 2px 0px 0 #00dc64; /* 오른쪽 */
	font-size: 20px;
}

#webtoon2 {
	background: #00dc64;
	background-image: url('image/logo3.png'); /* 배경 이미지 경로 */
	background-repeat: no-repeat; /* 이미지 반복 없음 */
	background-size: contain; /* 이미지 축소 (비율 유지) */
	background-position: center; /* 이미지 중심 배치 */
	font-weight: bold; /* 두꺼운 글씨 */
	text-shadow: -2px -2px 0 #00dc64, /* 위 왼쪽 */ 2px -2px 0 #00dc64,
		/* 위 오른쪽 */ -2px 2px 0 #00dc64, /* 아래 왼쪽 */ 2px 2px 0 #00dc64,
		/* 아래 오른쪽 */ 0px -2px 0 #00dc64, /* 위 */ 0px 2px 0 #00dc64, /* 아래 */
		  
		 -2px 0px 0 #00dc64, /* 왼쪽 */ 2px 0px 0 #00dc64; /* 오른쪽 */
	font-size: 20px;
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
 %> <a
						href="login.jsp">LOGIN</a> <%
 }
 %>
					</li>
				</ul>
			</nav>

		</div>

	</header>
	<main>
		<section class="hero">
			<div class="slider-container">
				<div class="slides">
					<!-- 슬라이드 1 -->
					<div class="slide">
						<div class="hero-content">
							<h1>
								No 그림, <br />누구나 할 수 있는 만화 제작
							</h1>
							<p>INKFRAME, 지금부터 시작합니다.</p>
						</div>
						<div class="hero-logo">
							<img src="image/logo1.png" alt="Framer Logo" />
						</div>
					</div>

					<!-- 슬라이드 2 -->
					<div class="slide" id="webtoon">
						<div class="hero-content">
							<h1>추천 수요 웹툰</h1>
							어느 마법사의 식당
						</div>
					</div>

					<!-- 슬라이드 3 -->
					<div class="slide" id="webtoon2">
						<div class="hero-content">
							<h1>오늘의 신작</h1>
							<p>모두가 기다려온 바로 그 이야기! 놓치면 후회할 완벽한 재미 보장!</p>
						</div>
					</div>
				</div>

				<!-- 네비게이션 버튼 -->
				<button class="prev">←</button>
				<button class="next">→</button>
			</div>
		</section>

		<!-- Features 영역 -->
		<section class="features">
			<div class="container">
				<div class="feature-item">
					<div class="feature-box" id="image_craft">
						AI 이미지<br />제작
					</div>
				</div>
				<div class="feature-item">
					<div class="feature-box" id="toon_cut">컷 제작</div>
				</div>
				<div class="feature-item">
					<div class="feature-box" id="notice">게시판</div>
				</div>
			</div>
		</section>
	</main>


	<script>
	const username = "<%= (username != null) ? username : "" %>";
    const slides = document.querySelector('.slides');
    const slideCount = document.querySelectorAll('.slide').length;
    const prevButton = document.querySelector('.prev');
    const nextButton = document.querySelector('.next');

    let currentIndex = 0;

    function updateSlider() {
      const offset = -currentIndex * 100; /* 슬라이드 이동 (100% 단위) */
      slides.style.transform = `translateX(${offset}%)`;
    }

    prevButton.addEventListener('click', () => {
      currentIndex = currentIndex > 0 ? currentIndex - 1 : slideCount - 1;
      updateSlider();
    });

    nextButton.addEventListener('click', () => {
      currentIndex = currentIndex < slideCount - 1 ? currentIndex + 1 : 0;
      updateSlider();
    });
	
    document.querySelectorAll('.feature-box').forEach((box) => {
        box.addEventListener('click', () => {
        	if (username === "null" || username === "") { // username이 null인 경우
                alert("로그인 후 이용 가능합니다."); // 경고창 표시
            } else {
                const targetPage = box.id + ".jsp"; // id명에 ".jsp"를 추가하여 파일 경로 생성
                window.location.href = targetPage; // 해당 경로로 이동
            }
        });
    });
    
    // 초기 슬라이더 상태 설정
    updateSlider();
    
 // 로그인 모달 열기
    document.getElementById('login').addEventListener('click', () => {
        document.getElementById('login-modal').style.display = 'flex';
    });

    // 로그인 모달 닫기
    document.querySelector('.close-btn').addEventListener('click', () => {
        document.getElementById('login-modal').style.display = 'none';
    });

    // 모달 외부 클릭 시 닫기
    window.addEventListener('click', (event) => {
        const modal = document.getElementById('login-modal');
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });

    </script>
</body>
</html>
