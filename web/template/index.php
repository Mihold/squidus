<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title><?php echo $template['title'] ?></title>
		<meta name="description" content="<?php echo $template['h_descr'] ?>">
		<link href="template/main.css" rel="stylesheet" type="text/css">
	</head>
	<body>
		<div class="header">
			<h1>Squidus</h1>
		</div>
		<div class="nav"></div>
		<div class="report">
			<h2><?php echo $template['report_title'] ?><h2>
			<?php echo $template['report_body'] ?>
		</div>
		<div class="footer">
			<p><?php echo $template['info_version'] ?></p>
		</div>
	</body>
</html>