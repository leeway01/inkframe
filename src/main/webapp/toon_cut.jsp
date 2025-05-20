<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>만화 컷 편집 및 이미지 삽입</title>
<style>
/* 전체 페이지의 기본 스타일 설정 */
body {
	font-family: Arial, sans-serif; /* 기본 폰트 설정 */
	background-color: #f4f4f4; /* 배경 색상 */
	display: flex; /* 플렉스 레이아웃 사용 */
	flex-direction: column; /* 수직 방향으로 정렬 */
	align-items: center; /* 가로 정렬 중앙 */
	justify-content: flex-start; /* 세로 정렬 시작점 */
	min-height: 100vh; /* 최소 높이를 뷰포트 높이로 설정 */
	margin: 0; /* 기본 마진 제거 */
	padding: 20px; /* 내부 여백 설정 */
	box-sizing: border-box; /* 박스 사이징을 border-box로 설정 */
}

/* 메인 컨테이너 스타일 */
.main-container {
	display: flex; /* 플렉스 레이아웃 사용 */
	flex-direction: row; /* 가로 방향으로 정렬 */
	align-items: flex-start; /* 상단 정렬 */
	justify-content: center; /* 중앙 정렬 */
	gap: 20px; /* 요소 간 간격 */
	width: 100%; /* 너비 100% */
	max-width: 1200px; /* 최대 너비 설정 */
}

/* 컷 모양 선택 영역 스타일 */
.cut-selection {
	background: #ffffff; /* 배경 색상 흰색 */
	padding: 20px; /* 내부 여백 */
	border-radius: 10px; /* 테두리 둥글게 */
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* 그림자 효과 */
	display: flex; /* 플렉스 레이아웃 사용 */
	max-height: 640px; /* 컨테이너 높이 제한 */
	flex-direction: column; /* 수직 방향으로 정렬 */
	overflow-y: auto; /* 세로 스크롤 활성화 */
	gap: 20px; /* 요소 간 간격 */
	align-items: center; /* 가로 정렬 중앙 */
	min-width: 220px; /* 최소 너비 설정 */
}

/* 이미지 삽입 뷰 스타일 */
.image-insertion-view {
	display: grid; /* 그리드 레이아웃 사용 */
	grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
	/* 자동 크기 조정 */
	gap: 10px; /* 이미지 간의 간격 */
	max-height: 527px; /* 컨테이너 높이 제한 */
	overflow-y: auto; /* 세로 스크롤 활성화 */
	padding: 10px; /* 내부 여백 */
	border: 1px solid #ddd; /* 테두리 설정 */
	background-color: #f9f9f9; /* 배경 색상 */
	border-radius: 10px; /* 테두리 둥글게 */
}

/* 컷 선택 및 이미지 삽입 뷰의 제목 스타일 */
.cut-selection h3, .image-insertion-view h3 {
	text-align: center; /* 텍스트 중앙 정렬 */
	margin: 0; /* 마진 제거 */
	font-size: 18px; /* 폰트 크기 설정 */
	color: #333; /* 텍스트 색상 */
}

/* 컷 옵션 스타일 */
.cut-option1 {
	display: flex; /* Flexbox 레이아웃 활성화 */
	width: 100%; /* 너비 100% */
	flex-direction: row;
}

.cut-option2 {
	display: flex; /* Flexbox 레이아웃 활성화 */
	width: 100%; /* 너비 100% */
	flex-direction: row;
}

.cut-option3 {
	display: flex; /* Flexbox 레이아웃 활성화 */
	width: 100%; /* 너비 100% */
	flex-direction: row;
	justify-content: center; /* 가로축 가운데 정렬 */
}

.cut-option4 {
	display: flex; /* Flexbox 레이아웃 활성화 */
	width: 100%; /* 너비 100% */
	flex-direction: row;
	justify-content: center; /* 가로축 가운데 정렬 */
}

.cut-option5 {
	display: flex; /* Flexbox 레이아웃 활성화 */
	width: 100%; /* 너비 100% */
	flex-direction: row;
	justify-content: center; /* 가로축 가운데 정렬 */
}

/* 이미지 옵션 스타일 */
.image-option {
	display: grid; /* 그리드 레이아웃 사용 */
	grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
	/* 자동 크기 조정 */
	grid-gap: 15px; /* 그리드 간 간격 */
	width: 100%; /* 너비 100% */
	justify-items: center; /* 그리드 아이템 가로 중앙 정렬 */
}

/* 컷 모양 미리보기 스타일 */
.cut-shape-preview {
	width: 128px; /* 너비 설정 */
	height: 128px; /* 높이 설정 */
	border: 2px dashed #aaa; /* 대시 테두리 */
	background-color: #ccc; /* 배경 색상 */
	cursor: pointer; /* 커서 포인터로 변경 */
	transition: border-color 0.3s ease; /* 테두리 색상 전환 효과 */
}

/* 컷 모양 미리보기 호버 효과 */
.cut-shape-preview:hover {
	border-color: #007bff; /* 호버 시 테두리 색상 변경 */
}

/* 다양한 컷 모양 클래스 정의 */
.cut-shape-preview.rectangle1 {
	width: 89px;
	clip-path: polygon(0% 0%, 90% 0%, 90% 100%, 0% 100%); /* 트라페조이드 모양 */
}

.cut-shape-preview.rectangle2 {
	width: 165px;
}

.cut-shape-preview.rectangle3 {
	width: 165px;
}

.cut-shape-preview.rectangle4 {
	width: 89px;
	clip-path: polygon(10% 0%, 100% 0%, 100% 100%, 10% 100%);
	/* 트라페조이드 모양 */
}

.cut-shape-preview.rectangle7 {
	width: 266px; /* 너비 설정 */
	height: 128px; /* 높이 설정 */
	grid-column: span 2; /* 그리드 열을 2칸 차지 */
}

.cut-shape-preview.rectangle5 {
	clip-path: polygon(0% 0%, 93% 0%, 93% 100%, 0% 100%); /* 직사각형 모양 */
}

.cut-shape-preview.rectangle6 {
	clip-path: polygon(7% 0%, 100% 0%, 100% 100%, 7% 100%); /* 직사각형 모양 */
}

.cut-shape-preview.trapezoid-left1 {
	width: 128px;
	clip-path: polygon(0% 0%, 85% 0%, 100% 100%, 0% 100%);
}

.cut-shape-preview.trapezoid-right1 {
	width: 128px;
	clip-path: polygon(0% 0%, 100% 0%, 100% 100%, 15% 100%);
}

.cut-shape-preview.trapezoid-left2 {
	width: 128px;
	clip-path: polygon(0% 0%, 100% 0%, 85% 100%, 0% 100%);
}

.cut-shape-preview.trapezoid-right2 {
	width: 128px;
	clip-path: polygon(15% 0%, 100% 0%, 100% 100%, 0% 100%);
}

/* 이미지 미리보기 스타일 */
.image-preview {
	width: 100px; /* 너비 설정 */
	height: 100px; /* 높이 설정 */
	border: 2px solid #aaa; /* 테두리 설정 */
	background-size: cover; /* 배경 이미지 크기 조절 */
	background-position: center; /* 배경 이미지 위치 설정 */
	cursor: pointer; /* 커서 포인터로 변경 */
	transition: transform 0.2s ease, border-color 0.3s ease;
	/* 변환 및 테두리 색상 전환 효과 */
}

/* 이미지 미리보기 호버 효과 */
.image-preview:hover {
	border-color: #007bff; /* 호버 시 테두리 색상 변경 */
	transform: scale(1.05); /* 약간 확대 */
}

/* 코믹 컷 컨테이너 스타일 */
.comic-cut-container {
	display: flex; /* 플렉스 레이아웃 사용 */
	align-items: flex-start; /* 상단 정렬 */
	gap: 10px; /* 요소 간 간격 */
	flex-direction: column; /* 수직 방향으로 정렬 */
}

/* 삭제 버튼 및 전체 삭제 버튼 컨테이너 스타일 */
.delete-buttons, .delete-all-button {
	display: flex; /* 플렉스 레이아웃 사용 */
	flex-direction: column; /* 수직 방향으로 정렬 */
	gap: 10px; /* 요소 간 간격 */
}

/* 레이아웃 버튼 스타일 */
.layout-buttons {
	display: flex; /* 플렉스 레이아웃 사용 */
	flex-direction: row; /* 가로 방향으로 정렬 */
	gap: 10px; /* 요소 간 간격 */
	padding: 10px; /* 내부 여백 */
	border: 1px solid #ddd; /* 테두리 설정 */
	background-color: #f9f9f9; /* 배경 색상 */
	border-radius: 10px; /* 테두리 둥글게 */
}

.button-container {
	flex-direction: row; /* 가로 방향으로 정렬 */
}

/* 전체 삭제 버튼 스타일 */
.delete-all-button {
	padding: 5px 10px; /* 내부 여백 */
	background-color: #dc4f5d; /* 배경 색상 */
	color: white; /* 텍스트 색상 */
	border: none; /* 테두리 제거 */
	cursor: pointer; /* 커서 포인터로 변경 */
	border-radius: 3px; /* 테두리 둥글게 */
	font-size: 14px; /* 폰트 크기 설정 */
	transition: background-color 0.3s ease, transform 0.2s ease;
	/* 배경 색상 및 변환 효과 */
	margin: auto;
}

/* 개별 삭제 버튼 스타일 */
.delete-button {
	padding: 5px 10px; /* 내부 여백 */
	background-color: #cc9ba0; /* 배경 색상 */
	color: white; /* 텍스트 색상 */
	border: none; /* 테두리 제거 */
	cursor: pointer; /* 커서 포인터로 변경 */
	border-radius: 3px; /* 테두리 둥글게 */
	font-size: 14px; /* 폰트 크기 설정 */
	transition: background-color 0.3s ease, transform 0.2s ease;
	/* 배경 색상 및 변환 효과 */
	margin-right: 5px; /* 오른쪽 마진 */
}

/* 삭제 버튼 호버 및 활성화 효과 */
.delete-button:hover, .delete-all-button:hover {
	background-color: #d73445; /* 호버 시 배경 색상 변경 */
	transform: scale(1.05); /* 약간 확대 */
}

.delete-button:active, .delete-all-button:active {
	background-color: #bd2130; /* 클릭 시 배경 색상 변경 */
}

/* 행 편집 버튼 스타일 */
.edit-row-button {
	padding: 5px 10px; /* 내부 여백 */
	background-color: #95c28c; /* 배경 색상 */
	color: white; /* 텍스트 색상 */
	border: none; /* 테두리 제거 */
	cursor: pointer; /* 커서 포인터로 변경 */
	border-radius: 3px; /* 테두리 둥글게 */
	font-size: 14px; /* 폰트 크기 설정 */
	transition: background-color 0.3s ease, transform 0.2s ease;
	/* 배경 색상 및 변환 효과 */
	margin-right: 5px; /* 오른쪽 마진 */
}

/* 행 편집 버튼 호버 및 활성화 효과 */
.edit-row-button:hover {
	background-color: #6ad056; /* 호버 시 배경 색상 변경 */
	transform: scale(1.05); /* 약간 확대 */
}

.edit-row-button:active {
	background-color: #43d626; /* 클릭 시 배경 색상 변경 */
}

/* 코믹 컷 뷰 스타일 */
.comic-cut-view {
	background-color: #ffffff; /* 배경 색상 흰색 */
	border: 2px solid #000; /* 테두리 설정 */
	width: 400px; /* 너비 설정 */
	height: 646px; /* 높이 설정 */
	display: grid; /* 그리드 레이아웃 사용 */
	grid-template-columns: repeat(1, 1fr); /* 1열로 설정 */
	grid-template-rows: repeat(3, 1fr); /* 3행으로 설정 */
	grid-gap: 0px; /* 그리드 간 간격 */
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* 그림자 효과 */
	justify-items: center; /* 그리드 아이템 가로 중앙 정렬 */
	justify-content: center; /* 그리드 전체를 중앙 정렬 */
	align-items: center; /* 그리드 아이템 세로 중앙 정렬 */
}

.cut-pair-container {
	display: flex; /* 가로 배치 */
	gap: 10px; /* 두 컷 사이 여백 */
	width: 100%; /* 부모 너비를 최대 설정 */
	justify-content: center; /* 중앙 정렬 */
}
/* 컷 모양 스타일 */
.cut-shape {
	width: 192px; /* 너비 설정 */
	height: 192px; /* 높이 설정 */
	border: 2px solid #000; /* 테두리 설정 */
	border-radius: 5px; /* 테두리 둥글게 */
	background-color: #f9f9f9; /* 기본 배경 색상 */
	background-size: cover; /* 이미지 비율 유지하며 요소를 채움 */
	background-position: center; /* 중앙 배치 */
	background-repeat: no-repeat; /* 이미지 반복 제거 */
}

/* 컷 내 이미지 스타일 */
.cut-shape img {
	width: 100%; /* 너비 100% */
	height: 100%; /* 높이 100% */
	object-fit: cover; /* 비율을 무시하고 셀을 완전히 채움 */
}

.cut-shape.rectangle1 {
	width: 89px;
}

.cut-shape.rectangle2 {
	width: 250px;
}

.cut-shape.rectangle3 {
	width: 250px;
}

.cut-shape.rectangle4 {
	width: 89px;
}

.cut-shape.rectangle7 {
	width: 355px; /* 너비 설정 */
	height: 192px; /* 높이 설정 */
	grid-column: span 2; /* 그리드 열을 2칸 차지 */
}

.cut-shape.rectangle5 {
	width: 170px;
	/*clip-path: polygon(0% 0%, 93% 0%, 93% 100%, 0% 100%);  직사각형 모양 */
}

.cut-shape.rectangle6 {
	width: 170px;
	/*clip-path: polygon(7% 0%, 100% 0%, 100% 100%, 7% 100%); /* 직사각형 모양 */
}

.cut-shape.trapezoid-left1 {
	width: 170px;
	clip-path: polygon(0% 0%, 85% 0%, 100% 100%, 0% 100%);
}

.cut-shape.trapezoid-right1 {
	width: 170px;
	clip-path: polygon(0% 0%, 100% 0%, 100% 100%, 15% 100%);
}

.cut-shape.trapezoid-left2 {
	width: 170px;
	clip-path: polygon(0% 0%, 100% 0%, 85% 100%, 0% 100%);
}

.cut-shape.trapezoid-right2 {
	width: 170px;
	clip-path: polygon(15% 0%, 100% 0%, 100% 100%, 0% 100%);
}

/* 컷 모양 호버 효과 */
.cut-shape:hover {
	border-color: #007bff; /* 호버 시 테두리 색상 변경 */
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15); /* 호버 시 그림자 효과 */
}

/* 뒤로가기 버튼 및 저장 버튼 스타일 */
.back-button, .save-button {
	padding: 10px; /* 내부 여백 */
	margin: 10px; /* 외부 여백 */
	background-color: #007bff; /* 배경 색상 */
	color: #fff; /* 텍스트 색상 */
	border: none; /* 테두리 제거 */
	border-radius: 5px; /* 테두리 둥글게 */
	cursor: pointer; /* 커서 포인터로 변경 */
	text-align: center; /* 텍스트 중앙 정렬 */
	transition: background-color 0.3s ease; /* 배경 색상 전환 효과 */
}

/* 뒤로가기 버튼 및 저장 버튼 호버 효과 */
.back-button:hover, .save-button:hover {
	background-color: #0562c4; /* 호버 시 배경 색상 변경 */
}

/* 모달 스타일 */
.modal {
	display: none; /* 기본적으로 숨김 */
	position: fixed; /* 고정 위치 */
	z-index: 100; /* z-인덱스 설정 */
	left: 0; /* 왼쪽 정렬 */
	top: 0; /* 위쪽 정렬 */
	width: 100%; /* 너비 100% */
	height: 100%; /* 높이 100% */
	overflow: auto; /* 스크롤 활성화 */
	background-color: rgba(0, 0, 0, 0.5); /* 반투명 배경 */
}

/* 모달 콘텐츠 스타일 */
.modal-content {
	background-color: #fefefe; /* 배경 색상 */
	margin: 10% auto; /* 위쪽 여백 및 중앙 정렬 */
	padding: 20px; /* 내부 여백 */
	border: 1px solid #888; /* 테두리 설정 */
	width: 300px; /* 너비 설정 */
	border-radius: 10px; /* 테두리 둥글게 */
	text-align: center; /* 텍스트 중앙 정렬 */
}

/* 모달 닫기 버튼 스타일 */
.close-modal {
	color: #aaa; /* 텍스트 색상 */
	float: right; /* 오른쪽 정렬 */
	font-size: 24px; /* 폰트 크기 설정 */
	font-weight: bold; /* 폰트 두께 설정 */
	cursor: pointer; /* 커서 포인터로 변경 */
}

/* 모달 닫기 버튼 호버 및 포커스 효과 */
.close-modal:hover, .close-modal:focus {
	color: #000; /* 호버 시 텍스트 색상 변경 */
	text-decoration: none; /* 텍스트 장식 제거 */
	cursor: pointer; /* 커서 포인터로 변경 */
}

/* 모달 내 모양 옵션 컨테이너 스타일 */
.modal-shape-option {
	display: grid; /* 그리드 레이아웃 사용 */
	grid-template-columns: 1fr; /* 1열로 설정 */
	gap: 10px; /* 요소 간 간격 */
	margin-top: 20px; /* 상단 여백 */
}

/* 모달 내 페어 옵션 스타일 */
.modal-pair-option {
	display: flex; /* 플렉스 레이아웃 사용 */
	flex-direction: row; /* 가로 방향으로 정렬 */
	justify-content: space-around; /* 공간 분배 */
	align-items: center; /* 세로 정렬 중앙 */
	cursor: pointer; /* 커서 포인터로 변경 */
	border: 2px dashed #aaa; /* 대시 테두리 */
	padding: 10px; /* 내부 여백 */
	transition: border-color 0.3s ease; /* 테두리 색상 전환 효과 */
}

/* 모달 내 페어 옵션 호버 효과 */
.modal-pair-option:hover {
	border-color: #007bff; /* 호버 시 테두리 색상 변경 */
}

/* 페어 미리보기 스타일 */
.pair-preview {
	width: 60px; /* 너비 설정 */
	height: 60px; /* 높이 설정 */
	background-color: #ccc; /* 배경 색상 */
}

/* 다양한 페어 미리보기 클래스 정의 */
.pair-preview.rectangle1 {
	width: 43px;
}

.pair-preview.rectangle2 {
	transform: translateX(-30px);
	width: 77px;
}

.pair-preview.rectangle3 {
	transform: translateX(30px);
	width: 77px;
}

.pair-preview.rectangle4 {
	width: 43px;
}

.pair-preview.rectangle7 {
	width: 150px; /* 너비 설정 */
}

.pair-preview.rectangle5 {
	clip-path: polygon(0% 0%, 93% 0%, 93% 100%, 0% 100%); /* 직사각형 모양 */
}

.pair-preview.rectangle6 {
	clip-path: polygon(7% 0%, 100% 0%, 100% 100%, 7% 100%); /* 직사각형 모양 */
}

/* 반응형 디자인을 위한 미디어 쿼리 */
@media ( max-width : 768px) {
	.main-container {
		flex-direction: column; /* 수직 방향으로 변경 */
		align-items: center; /* 중앙 정렬 */
	}
	.comic-cut-container {
		flex-direction: column; /* 수직 방향으로 변경 */
		align-items: center; /* 중앙 정렬 */
	}
	.delete-buttons {
		flex-direction: row; /* 가로 방향으로 변경 */
	}
	.comic-cut-view {
		grid-template-columns: 1fr; /* 그리드 열을 1개로 변경 */
	}
}

header {
	background-color: white;
	box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
	padding: 10px 20px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	width: 1050px; /* 전체 너비를 사용 */
}

header .logo {
	font-size: 24px;
	font-weight: bold;
}

header nav ul {
	list-style: none;
	display: flex;
	gap: 15px;
	padding: 0;
	margin: 0;
}

header nav ul li {
	display: inline-block;
}

header nav ul li a {
	text-decoration: none;
	color: #333;
	font-size: 16px;
}

.container {
	width: 70%;
	max-width: 800px;
	margin: 0 auto;
	padding: 20px;
}

.main-container {
	margin-top: 20px;
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
	</header>
	<div class="main-container">
		<!-- 컷 모양 선택 섹션 -->
		<div class="cut-selection">
			<h3>컷 모양 선택</h3>
			<div class="cut-option1">
				<!-- 다양한 컷 모양 미리보기 버튼 -->
				<div class="cut-shape-preview rectangle1"
					onclick="addPairedCuts('rectangle1','rectangle2')"></div>
				<div class="cut-shape-preview rectangle2"
					onclick="addPairedCuts('rectangle1','rectangle2')"></div>
			</div>
			<div class="cut-option2">
				<div class="cut-shape-preview rectangle3"
					onclick="addPairedCuts('rectangle3','rectangle4')"></div>
				<div class="cut-shape-preview rectangle4"
					onclick="addPairedCuts('rectangle3','rectangle4')"></div>
			</div>
			<div class="cut-option3">
				<div class="cut-shape-preview rectangle5"
					onclick="addPairedCuts('rectangle5','rectangle6')"></div>
				<div class="cut-shape-preview rectangle6"
					onclick="addPairedCuts('rectangle5','rectangle6')"></div>
			</div>
			<div class="cut-option5">
				<div class="cut-shape-preview rectangle7"
					onclick="addPairedCuts('rectangle7')"></div>
			</div>
		</div>

		<!-- 코믹 컷 섹션 -->
		<div class="comic-cut-container">
			<!-- 코믹 컷 뷰 영역 -->
			<div class="comic-cut-view" id="cutView" ondrop="drop(event)"
				ondragover="allowDrop(event)"></div>
		</div>

		<div>
			<!-- 레이아웃 버튼 섹션 -->
			<div class="layout-buttons">
				<div class="delete-buttons">
					<!-- 1행 삭제 및 편집 버튼 -->
					<div>
						<button class="delete-button" onclick="confirmAndRemoveRow(0)">
							1행 삭제</button>
						<button class="edit-row-button" onclick="editRow(0)">1행
							편집</button>
					</div>
					<!-- 2행 삭제 및 편집 버튼 -->
					<div>
						<button class="delete-button" onclick="confirmAndRemoveRow(1)">
							2행 삭제</button>
						<button class="edit-row-button" onclick="editRow(1)">2행
							편집</button>
					</div>
					<!-- 3행 삭제 및 편집 버튼 -->
					<div>
						<button class="delete-button" onclick="confirmAndRemoveRow(2)">
							3행 삭제</button>
						<button class="edit-row-button" onclick="editRow(2)">3행
							편집</button>
					</div>
				</div>
				<div>
					<!-- 저장 및 뒤로가기 버튼 -->
					<div class="button-container">
						<button class="save-button" onclick="save()">저장하기</button>
						<button class="back-button" onclick="goBack()">뒤로가기</button>
					</div>
					<!-- 전체 삭제 버튼 -->
					<div>
						<button class="delete-all-button" onclick="deleteAllCuts()">
							******모든컷 삭제******</button>
					</div>
				</div>
			</div>
			<!-- 이미지 삽입 뷰 섹션 -->
			<div class="image-insertion-view">
				<h3>이미지 삽입 뷰</h3>
				<div class="image-option"></div>
			</div>
		</div>
	</div>

	<!-- 모양 변경 모달 (행 편집용) -->
	<div id="shapeModal" class="modal">
		<div class="modal-content">
			<!-- 모달 닫기 버튼 -->
			<span id="closeModal" class="close-modal">&times;</span>
			<!-- 모양 옵션 선택 섹션 -->
			<div class="modal-shape-option">
				<!-- 페어 1 선택 -->
				<div class="modal-pair-option" onclick="changeRowCutShapes('pair1')">
					<div class="pair-preview rectangle1"></div>
					<div class="pair-preview rectangle2"></div>
					<span>type1</span>
				</div>
				<!-- 페어 2 선택 -->
				<div class="modal-pair-option" onclick="changeRowCutShapes('pair2')">
					<div class="pair-preview rectangle3"></div>
					<div class="pair-preview rectangle4"></div>
					<span>type2</span>
				</div>
				<!-- 페어 3 선택 -->
				<div class="modal-pair-option" onclick="changeRowCutShapes('pair3')">
					<div class="pair-preview rectangle5"></div>
					<div class="pair-preview rectangle6"></div>
					<span>type3</span>
				</div>
				<!-- 페어 4 선택 -->
				<div class="modal-pair-option" onclick="changeRowCutShapes('pair4')">
					<div class="pair-preview rectangle7"></div>
					<span>type4</span>
				</div>
			</div>
		</div>
	</div>

	<!-- Shape Change Modal (Row Edit) -->
	<div id="shapeModal" class="modal">
		<div class="modal-content">
			<span id="closeModal" class="close-modal">&times;</span>
			<div class="modal-shape-option">
				<div class="modal-pair-option" onclick="changeRowCutShapes('pair1')">
					<div class="pair-preview trapezoid1"></div>
					<div class="pair-preview trapezoid2"></div>
					<span>type1</span>
				</div>
				<div class="modal-pair-option" onclick="changeRowCutShapes('pair2')">
					<div class="pair-preview trapezoid3"></div>
					<div class="pair-preview trapezoid4"></div>
					<span>type2</span>
				</div>
				<div class="modal-pair-option" onclick="changeRowCutShapes('pair3')">
					<div class="pair-preview rectangle2"></div>
					<div class="pair-preview rectangle3"></div>
					<span>type3</span>
				</div>
				<div class="modal-pair-option" onclick="changeRowCutShapes('pair4')">
					<div class="pair-preview rectangle1"></div>
					<span>type4</span>
				</div>
			</div>
		</div>
	</div>
	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
	<script>
	<% 
    Class.forName("org.h2.Driver");
    // H2 데이터베이스 연결
    String dbURL = "jdbc:h2:tcp://localhost/~/webProject"; // 데이터베이스 경로
    String dbUser = "root"; // 사용자 이름
    String dbPassword = "1234"; // 비밀번호

    Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

    int countImage = 0;

    if (username != null) {
        String sql = "SELECT COUNT_IMAGE FROM USERS WHERE USERNAME = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, username);
        ResultSet rs = pstmt.executeQuery();
        
        if (rs.next()) {
            countImage = rs.getInt("COUNT_IMAGE");
        }

        rs.close();
        pstmt.close();
    }
    conn.close();
	%>
	const imageFiles = [];
	  let count = 1;
	  const totalImages = <%= countImage %>; // DB에서 가져온 이미지 개수

	  // 이미지 파일 이름을 배열에 추가
	  while (count <= totalImages) {
	    imageFiles.push(`${count}.jpeg`);
	    count++;
	  }

	  const baseUrl = "image"; // ImageServlet 경로

	  let currentEditRow = null; // 현재 편집 중인 행 인덱스 저장

	  // 페이지 로드 시 실행되는 함수
	  window.onload = function () {
	    const imageOption = document.querySelector('.image-option'); // 이미지 옵션 컨테이너 선택

	    // 이미지 파일을 순회하며 이미지 요소 생성
	    imageFiles.forEach((fileName) => {
	      const fullPath = `${baseUrl}?path=img/<%= username %>/${fileName}`; // ImageServlet 요청 경로
	      const img = document.createElement('div'); // 이미지 미리보기 요소 생성
	      img.className = 'image-preview'; // 클래스 이름 설정
	      img.style.backgroundImage = `url('${fullPath}')`; // 배경 이미지 설정
	      img.draggable = true; // 드래그 가능하게 설정
	      img.ondragstart = (event) => {
	        event.dataTransfer.setData('text', fullPath); // 드래그 시 데이터 전송
	      };
	      imageOption.appendChild(img); // 이미지 옵션 컨테이너에 추가
	    });

	    const modal = document.getElementById('shapeModal'); // 모달 요소 선택
	    const closeModalBtn = document.getElementById('closeModal'); // 모달 닫기 버튼 선택

	    // 모달 닫기 버튼 클릭 시 모달 숨기기
	    closeModalBtn.onclick = function () {
	      modal.style.display = 'none';
	      currentEditRow = null; // 현재 편집 중인 행 초기화
	    };

	    // 모달 외부 클릭 시 모달 숨기기
	    window.onclick = function (event) {
	      if (event.target == modal) {
	        modal.style.display = 'none';
	        currentEditRow = null; // 현재 편집 중인 행 초기화
	      }
	    };
	  };

	  // 드래그 가능 영역 허용 함수
	  function allowDrop(event) {
	    event.preventDefault();
	  }

	  // 드롭 이벤트 처리 함수
	  function drop(event) {
	    event.preventDefault();
	    const imageSrc = event.dataTransfer.getData('text'); // 드래그된 이미지 경로 가져오기
	    let targetElement = event.target;

	    // 드롭 대상이 컷 모양이 아닐 경우 가장 가까운 컷 모양 요소 찾기
	    if (!targetElement.classList.contains('cut-shape')) {
	      targetElement = targetElement.closest('.cut-shape');
	    }

	    // 컷 모양 요소에 CSS 배경 이미지 적용
	    if (targetElement && targetElement.classList.contains('cut-shape')) {
	      targetElement.style.backgroundImage = `url('${imageSrc}')`;
	      targetElement.style.backgroundSize = 'cover'; // 비율 유지하며 요소에 맞게 채우기
	      targetElement.style.backgroundPosition = 'center'; // 중앙에 배치
	      targetElement.style.backgroundRepeat = 'no-repeat'; // 이미지 반복 제거
	    }
	  }
      function drop1(event) {
        event.preventDefault();
        const imageSrc = event.dataTransfer.getData('text');
        const targetElement = event.target;

        if (targetElement.tagName === 'image') {
          targetElement.setAttribute('href', imageSrc);
        }
      }

      // 행 편집 모달 열기 함수
      function editRow(rowIndex) {
        currentEditRow = rowIndex; // 현재 편집 중인 행 인덱스 저장
        const modal = document.getElementById('shapeModal'); // 모달 요소 선택
        modal.style.display = 'block'; // 모달 표시
      }

      // 선택한 커트 모양 쌍으로 행의 두 컷 모양 변경 함수
      function changeRowCutShapes(pair) {
        if (currentEditRow === null) return; // 현재 선택된 행이 없으면 종료

        const cutView = document.getElementById('cutView'); // 컷 뷰 요소 선택
        const cuts = cutView.querySelectorAll('.cut-shape'); // 모든 컷 가져오기
        const cutsPerRow = 2; // 한 행에 2개의 컷
        const start = currentEditRow * cutsPerRow; // 선택된 행의 시작 인덱스
        const rowCuts = Array.from(cuts).slice(start, start + cutsPerRow); // 해당 행의 컷만 가져오기

        // 기존 스타일 초기화
        rowCuts.forEach((cut) => {
          cut.classList.remove(
            'rectangle1',
            'rectangle2',
            'rectangle3',
            'rectangle4',
            'rectangle7',
            'rectangle5',
            'rectangle6',
            'trapezoid-left1',
            'trapezoid-right1',
            'trapezoid-left2',
            'trapezoid-right2'
          );
          cut.style.gridColumn = ''; // grid-column 초기화
          cut.style.display = ''; // display 초기화 (숨김 해제)
        });

        // 새로운 모양 적용 //행 편집
        if (pair === 'pair1') {
          // Type1: rectangle1 - rectangle2
          rowCuts[0].classList.add('rectangle1');
          rowCuts[1].classList.add('rectangle2');
        } else if (pair === 'pair2') {
          // Type2: rectangle3 - rectangle4
          rowCuts[0].classList.add('rectangle3');
          rowCuts[1].classList.add('rectangle4');
        } else if (pair === 'pair3') {
          // Type3: 직사각형 (rectangle5-rectangle6)
          rowCuts[0].classList.add('rectangle5');
          rowCuts[1].classList.add('rectangle6');
        } else if (pair === 'pair4') {
          // Type4: 직사각형 (rectangle7), 두 번째 셀 숨김
          rowCuts[0].classList.add('rectangle7');
          rowCuts[0].style.gridColumn = 'span 2'; // 두 칸 차지
          if (rowCuts[1]) {
            rowCuts[1].style.display = 'none'; // 두 번째 셀 숨김
          }
        }

        // 모달 닫기
        const modal = document.getElementById('shapeModal');
        modal.style.display = 'none';
        currentEditRow = null; // 현재 편집 중인 행 초기화
      }

      // 행 삭제 확인 및 제거 함수
      function confirmAndRemoveRow(rowIndex) {
        if (confirm('정말로 이 행을 삭제하시겠습니까?')) {
          const cutView = document.getElementById('cutView'); // 컷 뷰 요소 선택
          const cuts = cutView.querySelectorAll('.cut-shape'); // 모든 컷 가져오기

          const cutsPerRow = 2; // 한 행에 2개의 컷
          const start = rowIndex * cutsPerRow; // 선택된 행의 시작 인덱스
          const end = start + cutsPerRow; // 선택된 행의 끝 인덱스

          const cutsArray = Array.from(cuts); // NodeList를 배열로 변환
          const cutsToRemove = cutsArray.slice(start, end); // 제거할 컷들 선택

          // 선택된 행의 컷 요소를 완전히 제거
          cutsToRemove.forEach((cut) => {
            cutView.removeChild(cut);
          });
        }
      }

      // 페어된 컷 추가 함수
      function addPairedCuts(shape1, shape2 = null) {
        const cutView = document.getElementById('cutView');

        // 최대 3행 제한 검사
        if (cutView.childElementCount >= 3) {
          alert('컷은 최대 3행(6컷)까지 추가할 수 있습니다.');
          return;
        }

        const pairContainer = document.createElement('div');
        pairContainer.className = 'cut-pair-container';
        pairContainer.style.display = 'flex';
        pairContainer.style.gap = '10px';
        pairContainer.style.width = '100%';
        pairContainer.style.justifyContent = 'center';

        // rectangle7 처리 (2칸 차지 + 두 번째 셀 숨김)
        if (shape1 === 'rectangle7') {
          const cutElement = document.createElement('div');
          cutElement.className = `cut-shape ${shape1}`;
          cutElement.style.gridColumn = 'span 2';
          cutElement.ondrop = drop;
          cutElement.ondragover = allowDrop;

          const hiddenElement = document.createElement('div');
          hiddenElement.className = 'cut-shape';
          hiddenElement.style.display = 'none'; // 두 번째 셀 숨김

          pairContainer.appendChild(cutElement);
          pairContainer.appendChild(hiddenElement);
        }
        // 일반적인 두 컷 추가
        else if (shape2) {
          const cut1 = document.createElement('div');
          cut1.className = `cut-shape ${shape1}`;
          cut1.ondrop = drop;
          cut1.ondragover = allowDrop;

          const cut2 = document.createElement('div');
          cut2.className = `cut-shape ${shape2}`;
          cut2.ondrop = drop;
          cut2.ondragover = allowDrop;

          pairContainer.appendChild(cut1);
          pairContainer.appendChild(cut2);
        }

        cutView.appendChild(pairContainer);
      }

      // 모든 컷 삭제 함수
      function deleteAllCuts() {
        if (confirm('모든 컷을 삭제하시겠습니까?')) {
          const cutView = document.getElementById('cutView'); // 컷 뷰 요소 선택
          while (cutView.firstChild) {
            // 모든 자식 요소 제거
            cutView.removeChild(cutView.firstChild);
          }
        }
      }

      // 뒤로가기 함수
      function goBack() {
        alert('뒤로가기 버튼 클릭됨!');
        // 페이지 이동 로직 추가
        window.history.back();
      }

      // 저장 함수
      function save() {
        if (confirm('저장하시겠습니까? 한번 저장하면 수정불가')) {
          //페이지 이동 및 저장 로직 추가
          const cutView = document.getElementById('cutView'); // 캡처할 영역 선택
          html2canvas(cutView)
            .then((canvas) => {
              // 캡처한 내용을 이미지로 변환
              const image = canvas.toDataURL('image/png');

              // 다운로드 링크 생성
              const link = document.createElement('a');
              link.href = image;
              link.download = 'cutView_capture.png'; // 저장될 파일 이름
              link.click(); // 다운로드 실행
              alert('다운로드 완료');
            })
            .catch((error) => {
              console.error('캡처 실패:', error);
              alert('캡처 중 오류가 발생했습니다.');
            });
        }
      }
    </script>
</body>
</html>
