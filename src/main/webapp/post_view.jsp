<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
String username = (String) session.getAttribute("username");
String userRole = "";
// DB 연결 정보
String dbURL = "jdbc:h2:tcp://localhost/~/webProject";
String dbUser = "root";
String dbPassword = "1234";

// 요청 파라미터로 전달된 post_id 가져오기
String postIdParam = request.getParameter("post_id");
int postId = (postIdParam != null) ? Integer.parseInt(postIdParam) : -1;

String title = "";
String createTime = "";
String author = "";
int pageCount = 0;

if (username != null) {
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.h2.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        // 사용자 역할(role) 조회
        String roleQuery = "SELECT role FROM USERS WHERE username = ?";
        stmt = conn.prepareStatement(roleQuery);
        stmt.setString(1, username);
        rs = stmt.executeQuery();

        if (rs.next()) {
            userRole = rs.getString("role");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
}

// 게시글 정보 조회
if (postId != -1) {
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;

	try {
		Class.forName("org.h2.Driver");
		conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

		String sql = "SELECT p.title, p.create_time, p.page_count, u.username "
		+ "FROM POST p JOIN USERS u ON p.author_id = u.user_id WHERE p.post_id = ?";
		stmt = conn.prepareStatement(sql);
		stmt.setInt(1, postId);
		rs = stmt.executeQuery();

		if (rs.next()) {
	title = rs.getString("title");
	createTime = rs.getString("create_time");
	pageCount = rs.getInt("page_count");
	author = rs.getString("username");
		}
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		if (rs != null)
	try {
		rs.close();
	} catch (SQLException ignored) {
	}
		if (stmt != null)
	try {
		stmt.close();
	} catch (SQLException ignored) {
	}
		if (conn != null)
	try {
		conn.close();
	} catch (SQLException ignored) {
	}
	}
}

// **좋아요 수 조회 코드 추가 (위치 중요!)**
int totalLikes = 0;
Connection likeConn = null;
PreparedStatement likeStmt = null;
ResultSet likeRs = null;

try {
	likeConn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
	String likeCountQuery = "SELECT COUNT(*) AS total_likes FROM LIKES WHERE post_id = ?";
	likeStmt = likeConn.prepareStatement(likeCountQuery);
	likeStmt.setInt(1, postId);
	likeRs = likeStmt.executeQuery();

	if (likeRs.next()) {
		totalLikes = likeRs.getInt("total_likes");
	}
} catch (Exception e) {
	e.printStackTrace();
} finally {
	if (likeRs != null)
		try {
	likeRs.close();
		} catch (SQLException ignored) {
		}
	if (likeStmt != null)
		try {
	likeStmt.close();
		} catch (SQLException ignored) {
		}
	if (likeConn != null)
		try {
	likeConn.close();
		} catch (SQLException ignored) {
		}
}
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>게시글 상세 보기</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/slick-carousel/1.8.1/slick.min.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/slick-carousel/1.8.1/slick-theme.min.css">
<style>
/* 공통 스타일 */
body {
	font-family: 'Arial', sans-serif;
	color: #333;
	margin: 0;
	padding: 0;
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
	padding: 10px 20px;
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

.main-container {
	width: 80%;
	max-width: 800px;
	margin: 20px auto;
	padding: 20px;
	background: #f9f9f9;
	border: 1px solid #ddd;
	border-radius: 8px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.post-title {
	font-size: 24px;
	font-weight: bold;
	margin-bottom: 10px;
}

.post-meta {
	font-size: 14px;
	color: #777;
	margin-bottom: 20px;
}

.slick-slider {
	margin: 20px auto;
	width: 100%;
	max-width: 300px;
}

.slick-slide img {
	display: block;
	width: 100%;
	height: 482px;
	object-fit: cover;
	border-radius: 8px;
	border-radius: 0; /* 모서리가 굽지 않도록 설정 */
}

.button-container {
	display: flex;
	justify-content: flex-end; /* 우측 정렬 */
	margin-top: 20px;
	gap: 10px;
}

.button {
	padding: 10px 20px;
	font-size: 14px;
	color: white;
	background-color: #007bff;
	border: none;
	border-radius: 5px;
	cursor: pointer;
	text-align: center;
	transition: background-color 0.3s ease, transform 0.2s ease;
	text-decoration: none;
}

.button:hover {
	background-color: #0056b3;
	transform: scale(1.05);
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

.comment-section {
	margin-top: 30px;
	padding: 20px;
	background-color: #f9f9f9;
	border: 1px solid #ddd;
	border-radius: 8px;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.comment-form {
	margin-bottom: 20px;
}

.comment-input {
	width: 100%;
	height: 80px;
	border: 1px solid #ccc;
	border-radius: 5px;
	padding: 10px;
	font-size: 14px;
	box-sizing: border-box;
}

.comment-button {
	float: right;
	margin-top: 10px;
	background-color: #28a745;
	color: white;
}

.comment-list {
	margin-top: 20px;
}

.comment {
	padding: 10px 0;
	border-bottom: 1px solid #ddd;
}

.comment p {
	margin: 5px 0;
}

.comment p strong {
	font-weight: bold;
	color: #007bff;
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
						if (session.getAttribute("username") != null) {
						%> <a href="logout.jsp">🚪</a> <%
 }
 %>
					</li>
					<li>
						<%
						if (session.getAttribute("username") != null) {
						%> <%=session.getAttribute("username")%>님 <%
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
		<h1 class="post-title"><%=title%></h1>
		<p class="post-meta">
			작성자:
			<%=author%>
			| 등록일:
			<%=createTime%>
			<span id="like-section">
				<button id="like-button" onclick="likePost()"
					style="background: none; border: none; cursor: pointer;">
					❤️</button> <span id="like-count"><%=totalLikes%></span>
			</span>
		</p>
		<% if ("admin".equals(userRole)) { %>
    <form action="delete_post.jsp" method="post" style="text-align: right;">
        <input type="hidden" name="post_id" value="<%=postId%>">
        <button type="submit" class="button" style="background-color: red;">게시글 삭제</button>
    </form>
<% } %>



		<div class="slick-slider">
			<!-- 표지 이미지 -->
			<div>
				<img src="image?path=<%=postId%>/cover.png" alt="표지 이미지">
			</div>
			<!-- 컷 이미지 -->
			<%
			for (int i = 1; i <= pageCount; i++) {
			%>
			<div>
				<img src="image?path=<%=postId%>/<%=i%>.png"
					alt="컷 이미지 <%=i%>">
			</div>
			<%
			}
			%>
		</div>

		<!-- 댓글 작성 폼 -->
		<div class="comment-section">
			<h2>댓글</h2>
			<form class="comment-form" action="add_comment.jsp" method="post">
				<input type="hidden" name="post_id" value="<%=postId%>">
				<textarea name="content" class="comment-input"
					placeholder="댓글을 입력하세요..." required></textarea>
				<button type="submit" class="button comment-button">댓글 작성</button>
			</form>

			<!-- 댓글 목록 -->
			<div class="comment-list">
    <%
    Connection conn2 = null;
    PreparedStatement stmt2 = null;
    ResultSet rs2 = null;
    try {
        conn2 = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        String commentQuery = "SELECT c.comment_id, c.content, c.create_time, u.username " +
                              "FROM COMMENT c " +
                              "JOIN USERS u ON c.author_id = u.user_id " +
                              "WHERE c.post_id = ? ORDER BY c.create_time DESC";
        stmt2 = conn2.prepareStatement(commentQuery);
        stmt2.setInt(1, postId);
        rs2 = stmt2.executeQuery();

        while (rs2.next()) {
            String commentContent = rs2.getString("content");
            String commentTime = rs2.getString("create_time");
            String commentAuthor = rs2.getString("username");
            int commentId = rs2.getInt("comment_id");
    %>
    <div class="comment">
        <p>
            <strong><%=commentAuthor%></strong> <span>(<%=commentTime%>)</span>
        </p>
        <p><%=commentContent%></p>
    </div>
    <%
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs2 != null) try { rs2.close(); } catch (SQLException ignored) {}
        if (stmt2 != null) try { stmt2.close(); } catch (SQLException ignored) {}
        if (conn2 != null) try { conn2.close(); } catch (SQLException ignored) {}
    }
    %>
</div>

		<!-- 버튼 추가 -->
		<div class="button-container">
			<a href="notice.jsp" class="button">목록으로</a>
		</div>
	</div>

	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
	<script
		src="https://cdnjs.cloudflare.com/ajax/libs/slick-carousel/1.8.1/slick.min.js"></script>
	<script>
		$(document).ready(function() {
			$('.slick-slider').slick({
				dots : true,
				infinite : true,
				speed : 500,
				slidesToShow : 1,
				adaptiveHeight : true
			});
		});
		function likePost() {
		    fetch("like_post.jsp", {
		        method: "POST",
		        headers: { "Content-Type": "application/x-www-form-urlencoded" },
		        body: "post_id=<%=postId%>"
		    })
		    .then(response => response.json())
		    .then(data => {
		        if (data.success) {
		            alert(data.message);
		            let likeCount = parseInt(document.getElementById("like-count").innerText);
		            document.getElementById("like-count").innerText = likeCount + 1;
		        } else {
		            alert(data.message);
		        }
		    })
		    .catch(error => console.error("Error:", error));
		}
	</script>
</body>
</html>
