<!DOCTYPE html>
<html lang="en">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Softwarepraktikum: Gruppe1</title>
	<link rel="stylesheet" type="text/css" href="css/my_style.css" />
	<div id="bild"><img src="images/startseite1.png" width=1200 height=100 >
	<div id="topmenue">Softwarepraktikum GRUPPE1</div>
</head>

<body>

	
	</div><div id="content">
		<h1> Willkommen auf der Bioinformatik-Homepage </h1>
	</div>
	<br/><br/><br/>
	<form method="get"> 
		<label for="table_name">Welche Daten sollen angezeigt werden? </label>
		<select name="table_name" size="1" >
		<?php
			if(isset($_GET['table_name']) & $_GET['table_name']=='mas5') {
				?><option >rma</option>
				<option selected>mas5</option><?php
			}
			//!isset$_GET['table_name'] or $_GET['table_name']=='rma'
			else{
				 $_GET['table_name'] = 'rma';?>
				<option selected>rma</option>
				<option >mas5</option><?php
			}
		?>	
		</select>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<?php
			//default row number
			if (!isset($_GET['row_number'])){
			$rows = 100;		
			}
			//user specified row number
			else{
				$rows=$_GET['row_number'];
			}
		?>
		<label for="row_number">Wie viele Zeilen sollen ausgeben werden? </label>
		<input id="row_number" name=row_number type="number" value=<?php echo $rows ?> />
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="submit" value="Submit"><br><br/><br><br/>

	 </form>
<?php
	/*if(!isset($_GET['table_name'])) {
	     $_GET['table_name'] = 'rma';

	}
	*/
	//set default sorting criterion 
	if(!isset($_GET['orderBy'])) {
	     $_GET['orderBy'] = 'SYMBOL';

	}

	if(substr($_GET['orderBy'], -4, 4)=='desc'){
	
		if(substr($_GET['orderBy'], 0, 3) === 'SLR' | substr($_GET['orderBy'], 0, 2) === 'FC'){
			$sql_orderBy='abs('.substr($_GET['orderBy'], 0, -5) . ') DESC';
		}

		else{
			$sql_orderBy=substr($_GET['orderBy'], 0, -5) . ' DESC';
		}

	}
	else{
		
		if(substr($_GET['orderBy'], 0, 3) === 'SLR' | substr($_GET['orderBy'], 0, 2) === 'FC'){
			$sql_orderBy='abs('.$_GET['orderBy']. ') ASC';
		}

		else{
			$sql_orderBy = $_GET['orderBy'].' ASC ';
		}
	}



	//database connection details
	$connect = mysql_connect('localhost','anja', "123") or die('Could not connect to MySQL: '.mysql_error());

	//database name
	mysql_select_db('anja', $connect);
	
	$content = '';
	
	$sql = "SELECT * FROM ".$_GET['table_name']." ORDER BY $sql_orderBy"." LIMIT ".$rows;
	//echo 'Abfrage: '.$sql.'<br></br>';
	
	$result = mysql_query($sql);
	
	while($row = mysql_fetch_array($result)) {
		$content.='<tr>';
	
		for ($i = 0; $i <mysql_num_fields($result); $i++) {
  			$content.='<td>' . htmlentities($row[$i]) . '</td>';

		}
		$content.='</tr>';
		
	}
 

	print '<table cellpadding="3" cellspacing="1" border="1">';
	print '<tr>';

	//display a link for each column
	for ($i = 0; $i <mysql_num_fields($result); $i++) {
		print '<th scope="col">';
		if($_GET['orderBy'] == mysql_field_name($result, $i)){ 
			print '<a href="mysql_query.php?table_name='.$_GET['table_name'].'&orderBy='.mysql_field_name($result, $i).'_desc&row_number='.$rows.'">'.mysql_field_name($result, $i).'<img src="images/arrowUp.gif" " /></a>'; 
		}
		elseif($_GET['orderBy'] == mysql_field_name($result, $i).'_desc'){
			print '<a href="mysql_query.php?table_name='.$_GET['table_name'].'&orderBy='.mysql_field_name($result, $i).'&row_number='.$rows.'">'.mysql_field_name($result, $i).'<img src="images/arrowDown.gif" " /></a>'; 
		}
		else{ 
			print '<a href="mysql_query.php?table_name='.$_GET['table_name'].'&orderBy='.mysql_field_name($result, $i).'&row_number='.$rows.'">'.mysql_field_name($result, $i).'</a>'; 
		}
		print '</th>';

	}

	print '</tr>';
	print $content;
	print '</table>';

	mysql_close($connect);

?>

</body>
</html>

