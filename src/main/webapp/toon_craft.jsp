<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.io.*, java.sql.*, java.util.*, java.text.SimpleDateFormat"%>
<%@ page import="jakarta.servlet.annotation.MultipartConfig"%>
<%@ page import="jakarta.servlet.http.Part"%>


<%@ page session="true"%>
<%
// DB 연결 정보
String dbURL = "jdbc:h2:tcp://localhost/~/webProject";
String dbUser = "root";
String dbPassword = "1234";
String username = (String) session.getAttribute("username");

int postId = 1; // 초기값 설정
Connection conn = null;
// 데이터베이스 연결
Class.forName("org.h2.Driver");
conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

// page 테이블에서 데이터 개수 + 1 조회
String countSql = "SELECT COUNT(*) AS total FROM POST";
PreparedStatement countStmt = conn.prepareStatement(countSql);
ResultSet rs = countStmt.executeQuery();
if (rs.next()) {
	postId = rs.getInt("total") + 1;
}
rs.close();
countStmt.close();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>만화 제작 툴</title>
<style>
/* 스타일 동일 */
body {
	font-family: Arial, sans-serif;
	background-color: #f4f4f4;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: flex-start;
	min-height: 100vh;
	margin: 0;
	padding: 20px;
	box-sizing: border-box;
}

.container {
	width: 70%;
	height: 10px;
	max-width: 800px;
	margin: 0 auto;
	padding: 20px;
}

.main-container {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	justify-content: center;
	gap: 20px;
	width: 100%;
	max-width: 1200px;
}

.form-container {
	background: #ffffff;
	padding: 20px;
	border-radius: 10px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
	width: 400px;
}

.preview-container {
	display: flex;
	flex-wrap: wrap;
	gap: 10px;
	justify-content: center;
	max-height: 900px;
	overflow-y: auto;
	width: 1000px;
	border: 1px solid #ccc;
	padding: 10px;
	background: #ffffff;
}

.comic-cut, .cover {
	background-color: #ffffff;
	border: 2px solid #000;
	display: flex;
	align-items: center;
	justify-content: center;
	text-align: center;
	font-weight: bold;
	width: 297px;
	height: 478px;
	cursor: pointer;
	overflow: hidden;
	position: relative;
}

.comic-cut img, .cover img {
	max-width: 100%;
	max-height: 100%;
	object-fit: cover;
}

.remove-image {
	position: absolute;
	top: 5px;
	right: 5px;
	background-color: rgba(255, 255, 255, 0.7);
	border: none;
	border-radius: 50%;
	width: 25px;
	height: 25px;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
}

.remove-image:hover {
	background-color: rgba(255, 0, 0, 0.7);
	color: #fff;
}

.back-button {
	padding: 10px;
	margin: 10px 5px 0 0;
	background-color: #007bff;
	color: #fff;
	border: none;
	border-radius: 5px;
	cursor: pointer;
	transition: background-color 0.3s ease;
}

.back-button:hover {
	background-color: #0562c4;
}

header {
	background-color: white;
	box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
	padding: 5px 10px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	width: 1200px; /* 전체 너비를 사용 */
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
		<div class="main-container">
			<div class="form-container">
				<h2>만화 제작 툴</h2>
				<div class="form-group">
					<label for="numberOfCuts">컷 개수:</label> <input type="number"
						id="numberOfCuts" value="3" min="1" max="20"
						onchange="updateCutCount()" />
				</div>
				<div class="form-group">
					<label>표지 설정:</label>
					<div id="coverPreview" class="cover" onclick="setCover()">표지를
						클릭하여 추가</div>
				</div>
				<div class="form-group">
					<label for="comicTitle">제목:</label> <input type="text"
						id="comicTitle" placeholder="제목을 입력하세요" />
				</div>
				<button class="back-button" onclick="saveComic()">저장하기</button>
			</div>
			<div id="previewContainer" class="preview-container"></div>
		</div>

	<script>
		
        let comicData = { title: '', cover: '', cuts: [] };

        function setCover() { uploadImage((dataURL) => { comicData.cover = dataURL; document.getElementById('coverPreview').innerHTML = `<img src="${dataURL}" />`; }); }

        function updateCutCount() { const cutCount = Math.max(1, Math.min(20, parseInt(document.getElementById('numberOfCuts').value))); updatePreview(cutCount); }

        function updatePreview(cutCount) {
            const container = document.getElementById('previewContainer'); container.innerHTML = '';
            comicData.cuts = Array.from({ length: cutCount }, (_, i) => null);
            for (let i = 0; i < cutCount; i++) {
                const cut = document.createElement('div'); cut.className = 'comic-cut'; cut.textContent = `컷 ${i + 1}`;
                cut.onclick = () => uploadImage((dataURL) => { comicData.cuts[i] = dataURL; cut.innerHTML = `<img src="${dataURL}" />`; }); container.appendChild(cut);
            }
        }

        function uploadImage(callback) {
            const input = document.createElement('input'); input.type = 'file'; input.accept = 'image/*';
            input.onchange = (e) => { const reader = new FileReader(); reader.onload = () => callback(reader.result); reader.readAsDataURL(e.target.files[0]); }; input.click();
        }

        function saveComic() {
            const title = document.getElementById('comicTitle').value.trim();
            const pageCount = comicData.cuts.filter(cut => cut !== null).length;
            const currentTime = new Date().toISOString().slice(0, 10);

            if (!title) {
                alert('제목을 입력해주세요.');
                return;
            }

            // FormData 객체 생성
            const formData = new FormData();
            formData.append("action", "saveComic");
            formData.append("title", title);
            formData.append("pageCount", pageCount);
            formData.append("createTime", currentTime);

            // cover 이미지 추가
            const coverFile = dataURLtoBlob(comicData.cover);
            formData.append("cover", coverFile, "cover.png");

            // 컷 이미지 추가
            comicData.cuts.forEach((cut, index) => {
                if (cut) {
                    const cutFile = dataURLtoBlob(cut);
                    formData.append(`cut${index + 1}`, cutFile, `${index + 1}.png`);
                }
            });

            fetch("ComicController", {
                method: "POST",
                body: formData
            })
            .then(response => response.json())
            .then(result => {
                if (result.success) {
                    alert("게시물이 성공적으로 저장되었습니다.");
                    window.location.href = "notice.jsp";
                } else {
                    alert("저장 실패: " + result.error);
                }
            })
            .catch(error => {
                console.error("저장 실패:", error);
                alert("저장에 실패했습니다.");
            });
        }
        
        function dataURLtoBlob(dataURL) {
            const [meta, base64] = dataURL.split(";base64,");
            const binary = atob(base64);
            const byteArray = Uint8Array.from(binary, c => c.charCodeAt(0));
            return new Blob([byteArray], { type: meta.split(":")[1] });
        }

        document.addEventListener("DOMContentLoaded", () => updateCutCount());
    </script>
</body>
</html>
