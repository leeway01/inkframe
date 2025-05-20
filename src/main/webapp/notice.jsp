<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("username");
%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // DB 연결 정보
    String dbURL = "jdbc:h2:tcp://localhost/~/webProject";
    String dbUser = "root";
    String dbPassword = "1234";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    List<Map<String, String>> postList = new ArrayList<>();

    try {
        Class.forName("org.h2.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        String sql = "SELECT post_id, title, create_time FROM POST ORDER BY post_id DESC";
        stmt = conn.prepareStatement(sql);
        rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, String> post = new HashMap<>();
            post.put("post_id", String.valueOf(rs.getInt("post_id")));
            post.put("title", rs.getString("title"));
            post.put("create_time", rs.getString("create_time"));
            postList.add(post);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
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

table {
	border-collapse: collapse;
	border-spacing: 0;
}

section.notice {
	padding: 80px 0;
}

.page-title {
	margin-bottom: 60px;
}

.page-title h3 {
	font-size: 28px;
	color: #333333;
	font-weight: 400;
	text-align: center;
}

#board-search .search-window {
	padding: 15px 0;
	background-color: #f9f7f9;
}

#board-search .search-window .search-wrap {
	position: relative;
	/*   padding-right: 124px; */
	margin: 0 auto;
	width: 80%;
	max-width: 564px;
}

#board-search .search-window .search-wrap input {
	height: 40px;
	width: 100%;
	font-size: 14px;
	padding: 7px 14px;
	border: 1px solid #ccc;
}

#board-search .search-window .search-wrap input:focus {
	border-color: #333;
	outline: 0;
	border-width: 1px;
}

#board-search .search-window .search-wrap .btn {
	position: absolute;
	right: 0;
	top: 0;
	bottom: 0;
	width: 108px;
	padding: 0;
	font-size: 16px;
}

.board-table {
	font-size: 13px;
	width: 100%;
	border-top: 1px solid #ccc;
	border-bottom: 1px solid #ccc;
}

.board-table a {
	color: #333;
	display: inline-block;
	line-height: 1.4;
	word-break: break-all;
	vertical-align: middle;
}

.board-table a:hover {
	text-decoration: underline;
}

.board-table th {
	text-align: center;
}

.board-table .th-num {
	width: 100px;
	text-align: center;
}

.board-table .th-date {
	width: 200px;
}

.board-table th, .board-table td {
	padding: 14px 0;
}

.board-table tbody td {
	border-top: 1px solid #e7e7e7;
	text-align: center;
}

.board-table tbody th {
	padding-left: 28px;
	padding-right: 14px;
	border-top: 1px solid #e7e7e7;
	text-align: left;
}

.board-table tbody th p {
	display: none;
}

.btn {
	display: inline-block;
	padding: 0 30px;
	font-size: 15px;
	font-weight: 400;
	background: transparent;
	text-align: center;
	white-space: nowrap;
	vertical-align: middle;
	-ms-touch-action: manipulation;
	touch-action: manipulation;
	cursor: pointer;
	-webkit-user-select: none;
	-moz-user-select: none;
	-ms-user-select: none;
	user-select: none;
	border: 1px solid transparent;
	text-transform: uppercase;
	-webkit-border-radius: 0;
	-moz-border-radius: 0;
	border-radius: 0;
	-webkit-transition: all 0.3s;
	-moz-transition: all 0.3s;
	-ms-transition: all 0.3s;
	-o-transition: all 0.3s;
	transition: all 0.3s;
}

.btn-dark {
	background: #555;
	color: #fff;
}

.btn-dark:hover, .btn-dark:focus {
	background: #373737;
	border-color: #373737;
	color: #fff;
}

.btn-dark {
	background: #555;
	color: #fff;
}

.btn-dark:hover, .btn-dark:focus {
	background: #373737;
	border-color: #373737;
	color: #fff;
}

/* reset */
* {
	list-style: none;
	text-decoration: none;
	padding: 0;
	margin: 0;
	box-sizing: border-box;
}

.clearfix:after {
	content: '';
	display: block;
	clear: both;
}

.container {
	width: 1100px;
	margin: 0 auto;
}

.blind {
	position: absolute;
	overflow: hidden;
	clip: rect(0, 0, 0, 0);
	margin: -1px;
	width: 1px;
	height: 1px;
}
.write-fixed-btn {
    position: fixed; /* 화면에 고정 */
    bottom: 30px; /* 하단에서 30px 위 */
    right: 30px; /* 오른쪽에서 30px 왼쪽 */
    padding: 12px 20px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 5px;
    font-size: 14px;
    cursor: pointer;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    transition: background-color 0.3s ease, transform 0.2s ease;
}

.write-fixed-btn:hover {
    background-color: #0056b3; /* 호버 시 색상 변경 */
    transform: scale(1.05); /* 버튼 확대 효과 */
}
a { text-decoration: none; color: black; }    
a:visited { text-decoration: none; }    
a:hover { text-decoration: none; }    
a:focus { text-decoration: none; }    
a:hover, a:active { text-decoration: none; }
</style>
</head>
<body>
	<header>
		<div class="container">
			<div class="logo"><a
						href="main.jsp">INKFRAME</a></div>
			<nav>
				<ul>
					<li>
						<% if (username != null) {%> <a href="logout.jsp">🚪</a> <% } %>
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

		<section class="notice">
            <div class="page-title">
                <div class="container">
                    <h3>만화 게시판</h3>
                </div>
            </div>

            <!-- 게시판 리스트 -->
            <div id="board-list">
                <div class="container">
                    <table class="board-table">
                        <thead>
                            <tr>
                                <th scope="col" class="th-num">번호</th>
                                <th scope="col" class="th-title">제목</th>
                                <th scope="col" class="th-date">등록일</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, String> post : postList) { %>
                                <tr>
                                    <td><%= post.get("post_id") %></td>
                                    <td>
                                        <a href="post_view.jsp?post_id=<%= post.get("post_id") %>">
                                            <%= post.get("title") %>
                                        </a>
                                    </td>
                                    <td><%= post.get("create_time") %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
		<!-- 글작성 버튼 추가 -->
<button class="write-fixed-btn" onclick="location.href='toon_craft.jsp'">글 작성</button>
	</main>
	<script>
	
    </script>
</body>
</html>
