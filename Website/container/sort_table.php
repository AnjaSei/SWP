<!DOCTYPE html>
<html lang="en">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Softwarepraktikum: Gruppe1</title>
	<link rel="stylesheet" type="text/css" href="css/my_style.css" />
	
	<div id="topmenue">Softwarepraktikum GRUPPE1</div>
</head>

<body>
	<br/><br/><br/>
	<form method="get"> 
		<label for="row_number">Wie viele Zeilen sollen ausgeben werden? </label>
		<input id="row_number" name=row_number type="number" value=5 /><br/>
		<input type="submit" name="submit" value="Submit">

	 </form>

<?php
//IF THE FLAG HASN'T BEEN SET YET, SET THE DEFAULT
if(!isset($_GET['orderBy'])) {
     $_GET['orderBy'] = 'PROBEID_desc';
	echo "Hier";
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
 
//FIGURE OUT HOW TO SORT THE TABLE
/*switch($_GET['orderBy']) {
     case 'city':
     case 'name':
     case 'ID':
          $sql_orderBy = $_GET['orderBy'].' ASC ';
          break;
 
     case 'city_desc':
     case 'name_desc':
     case 'ID_desc':
          $sql_orderBy = substr($_GET['orderBy'], 0, -5) . ' DESC';
          break;
 
     default:
          $_GET['orderBy'] = 'city_desc';
          $sql_orderBy     = 'city DESC';
}
*/

if (!isset($_GET['row_number'])){
	$rows = 5;		//default value
}
else{
	$rows=$_GET['row_number'];
}

//database connection details
$connect = mysql_connect('localhost','anja', "123") or die('Could not connect to MySQL: '. mysql_error());

//database name
mysql_select_db('anja', $connect);
//GET THE LIST OF REGISTRANTS
$print = '';

$sql = "SELECT * FROM rma ORDER BY $sql_orderBy"." LIMIT ".$rows;
echo $sql;
$result = mysql_query($sql);
while($row = mysql_fetch_array($result)) {
	$print.='<tr>';
	
	for ($i = 0; $i <mysql_num_fields($result); $i++) {
  		$print.='<td>' . htmlentities($row[$i]) . '</td>';

	}
	$print.='</tr>';
    // $print .= '<tr><td>' . htmlentities($row['name']) . '</td><td>' . htmlentities($row['ID']) . '</td><td>' . $row['city'] . '</td></tr>';
	
}
 


print '<table cellpadding="3" cellspacing="1" border="1">';
print '<tr>';

for ($i = 0; $i <mysql_num_fields($result); $i++) {
	print '<th scope="col">';
	if($_GET['orderBy'] == mysql_field_name($result, $i)){ 
		print '<a href="sort_table.php?orderBy='.mysql_field_name($result, $i).'_desc&row_number='.$rows.'">'.mysql_field_name($result, $i).'<img src="../images/arrowUp.gif" " /></a>'; 
	}
	elseif($_GET['orderBy'] == mysql_field_name($result, $i).'_desc'){
		 print '<a href="sort_table.php?orderBy='.mysql_field_name($result, $i).'&row_number='.$rows.'">'.mysql_field_name($result, $i).'<img src="../images/arrowDown.gif" " /></a>'; 
	}
	else{ 
		print '<a href="sort_table.php?orderBy='.mysql_field_name($result, $i).'&row_number='.$rows.'">'.mysql_field_name($result, $i).'</a>'; 
	}
	print '</th>';


}

print '</tr>';
print $print;
print '</table>';


/*
print '<table cellpadding="3" cellspacing="1" border="1">';
print '<tr>';
print '<th scope="col">';
if($_GET['orderBy'] == 'name')          { print '<a href="sort_table.php?orderBy=name_desc&row_number='.$rows.'">First Name<img src="images/arrowUp.gif" " /></a>'; }
elseif($_GET['orderBy'] == 'name_desc') { print '<a href="sort_table.php?orderBy=name&row_number='.$rows.'">First Name<img src="images/arrowDown.gif" " /></a>'; }
else                                          { print '<a href="sort.php?orderBy=name&row_number='.$rows.'">First Name</a>'; }
print '</th>';
print '<th scope="col">';
if($_GET['orderBy'] == 'ID')           { print '<a href="test.php?orderBy=ID_desc&row_number='.$rows.'">Last Name<img src="images/arrowUp.gif" " /></a>'; }
elseif($_GET['orderBy'] == 'ID_desc')  { print '<a href="test.php?orderBy=ID&row_number='.$rows.'">Last Name<img src="images/arrowDown.gif" " /></a>'; }
else                                          { print '<a href="test.php?orderBy=ID&row_number='.$rows.'">Last Name</a>'; }
print '</th>';
print '<th scope="col">';
if($_GET['orderBy'] == 'city')                { print '<a href="test.php?orderBy=city_desc&row_number='.$rows.'">City Registered<img src="images/arrowUp.gif" " /></a>'; }
elseif($_GET['orderBy'] == 'city_desc')       { print '<a href="test.php?orderBy=city&row_number='.$rows.'">City Registered<img src="images/arrowDown.gif" " /></a>'; }
else                                          { print '<a href="test.php?orderBy=city_desc&row_number='.$rows.'">City Registered</a>'; }
print '</th>';
print '</tr>';
print $print;
print '</table>';
*/
?>
</body>
</html>
