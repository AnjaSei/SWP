<!DOCTYPE html>
<html lang="en">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Softwarepraktikum: Gruppe1</title>
	<link rel="stylesheet" type="text/css" href="css/my_style.css" />
	<div id="image"><img src="images/startseite1.png" width=1200 height=100 ></div>
	<div id="topmenue">Softwarepraktikum GRUPPE1</div>

	<script language="javascript" type="text/javascript">
	//filter/search slide box
	function show_filter_options(className, obj) {
		var $input = $(obj);
		//show filter/search options
	    	if ($input.prop('checked')){
		 	$(className).show();
		}
		//hide and delete old filter/search options
	    	else {
			$(className).hide();
			$('#search').val('');
			$('#number').val('');
		}
	}
	</script>

</head>

<body>
	<div id="content">
		<h1> Willkommen auf der Bioinformatik-Homepage </h1>
	</div>
	
 	<a href="index.php" style="float: left" class="myButton">Neue Anfrage</a>
	<?php
	//set default row number
	$_GET['row_number'] = isset($_GET['row_number']) ? $_GET['row_number'] : 100; 

	//set default table name
	$_GET['table_name'] = isset($_GET['table_name']) ? $_GET['table_name'] : "rma";

	//set default sorting criterion 
	$_GET['orderBy'] = isset($_GET['orderBy']) ? $_GET['orderBy'] : "SYMBOL";

	//initialize search field
	$_GET['search'] = isset($_GET['search']) ? $_GET['search'] : "";

	//initialize filter column
	$_GET['column'] = isset($_GET['column']) ? $_GET['column'] : "";

	//initialize filter operation
	$_GET['operation'] = isset($_GET['operation']) ? $_GET['operation'] : "";

	//initialize filter value
	$_GET['number'] = isset($_GET['number']) ? $_GET['number'] : "";	
	?>
	
	<!--export table as .csv/.text file-->
	<script src="js/jquery-1.10.2.min.js" type="text/javascript" charset="utf-8"></script>
	<script src="js/jquery.TableCSVExport.js"></script>
	<a href="#" id="export" style="float: right" class="myButton">Exportiere Tabelle</a>
	<script>
            $("#export").click(function(){
                $('#my_table').TableCSVExport({
  		separator: '\t',   	//or choose ',' for csv. file 
 		header: [], 		//set individual header (if desired)
  		columns: [],		//take only specific colums (if desired)
  		delivery: 'download' /* popup, value, download */,
  		filename: "<?php echo $_GET['table_name']; ?>"+"_table.csv"
		});

            });
    	</script><br><br><br>
	
	<?php

	//database connection details
	$connect = mysql_connect('localhost','anja', "123") or die('Could not connect to MySQL: '.mysql_error());

	//database name
	mysql_select_db('anja', $connect);

	//sql command
	$sql = "SELECT * FROM ".$_GET['table_name'];

	//build WHERE clause	
	if($_GET['search']!="" | $_GET['number']!="" ){
		$sql.=" WHERE ";
		if($_GET['search']!=""){
			$sql.=" (PROBEID LIKE '%".$_GET['search']."%' OR SYMBOL LIKE '%".$_GET['search']."%') ";
		}	
		if ($_GET['number']!="" ){
			if($_GET['search']!=""){
				$sql.=" AND ";
			}
			$sql.=$_GET['column']." ".$_GET['operation']." ".$_GET['number']." ";
			
		}
	}

	//build ORDER BY clause
	if(substr($_GET['orderBy'], -4, 4)=='desc'){
		if(substr($_GET['orderBy'], 0, -5) === 'SLR' | substr($_GET['orderBy'], 0, -5) === 'FC'){
			$sql.=" ORDER BY "."abs(".substr($_GET["orderBy"], 0, -5) . ") DESC";
		}
		else{
			$sql.=" ORDER BY ".substr($_GET["orderBy"], 0, -5) . " DESC";
		}
	}
	else{
		if(substr($_GET['orderBy'], 0, 3) === 'SLR' | substr($_GET['orderBy'], 0, 2) === 'FC'){
			$sql.=" ORDER BY "."abs(".$_GET["orderBy"]. ") ASC";
		}
		else{
			$sql.=" ORDER BY ".$_GET["orderBy"]." ASC ";
		}
	}
	
	//build LIMIT clause
	$sql.=" LIMIT ".$_GET['row_number'];
	//echo 'Abfrage: '.$sql.'<br></br>';
	
	//execute SQL command
	$result = mysql_query($sql);

	//stores data in table format
	$content = '';
	//fetch the selected data
	while($data = mysql_fetch_array($result)) {
	
		$content.='<tr>'; 
		for ($i = 0; $i <mysql_num_fields($result); $i++) {
  			$content.='<td>' . htmlentities($data[$i]) . '</td>'; 

		}
		$content.='</tr>'; 
	}

	?>

	<!--build form for the user-->
	<form method="get" id="form"> 
		<fieldset>
		
		<!--build drop-down list for the tables (rma and mas5)-->
		<label for="table_name">Welche Daten sollen angezeigt werden? </label>
		<select id="table_name" name="table_name" size="1" >
		<?php 
		if($_GET['table_name']=='mas5') { ?>
			<option>rma</option>
			<option selected>mas5</option>
		<?php }
		//$_GET['table_name']=='rma'
		else{ ?>
			<option selected>rma</option>
			<option>mas5</option>
		<?php }	?>	
		</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		
		<!--create input field for the desired row number-->
		<label for="row_number">Wie viele Zeilen sollen ausgeben werden? </label>
		<input id="row_number" name=row_number type="number" value=<?php echo $_GET['row_number'] ?> />
		<br><br>
	
		<!--create slide box to select search/filter criteria (optional)-->
    		Suchen/Filtern: &nbsp;&nbsp;&nbsp;
		<div class="slideThree" style=" display:inline"> 
		<?php if ($_GET['number']!="" | $_GET['search']!="" ){?>
			<input type="checkbox"  name="filter" id="slideThree" onclick="show_filter_options('.search_filter_class', filter )" checked><label for="slideThree"></label></div><br>
			<span class='search_filter_class' ><br>
		<?php }
		else{ ?>
			<input type="checkbox"  name="filter" id="slideThree" onclick="show_filter_options('.search_filter_class', filter )"><label for="slideThree"></label></div><br>
			<span class='search_filter_class' hidden><br>
		<?php } ?>
		

		<!--create search field-->
		<label for="search">Suche: Gensymbol oder AffyID: </label>
		<input type="text" id="search" name="search" value="<?php echo $_GET['search'] ?>" placeholder="z.B. A1BG"><br>
		
		<!--build drop-down list with the table columns (for filter criteria)-->
		<label for="column">Filtern: Spalte: </label>
		<select name="column" id="column" size="1">
		<?php for ($i = 0; $i <mysql_num_fields($result); $i++) {
			if(mysql_field_name($result, $i)!="PROBEID" & mysql_field_name($result, $i)!="SYMBOL"){
				if(mysql_field_name($result, $i)==$_GET['column']){
					print '<option selected>'.mysql_field_name($result, $i).'</option>';
				}
				else{
					print '<option>'.mysql_field_name($result, $i).'</option>';
				}
			}
		}?>
		</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

		<!--build drop-down list with operations (for filter criteria)-->
		<label for="operation">Operation: </label>
		<select name="operation" id="operation" size="1">
		<?php $operations= array("=", ">", "<", ">=", "<=");
				
		foreach($operations as $op){	
			if ($op==$_GET['operation']){
				print '<option value="'.$op.'" selected>'.$op.'</option>';
			}
			else{
				print '<option value="'.$op.'">'.$op.'</option>';
			}
		} ?>
		</select>

		<!--create input field for the filter value-->		
		<input type="number" step="any" id="number" name="number" value=<?php echo $_GET['number'] ?>>
		
		</span><br><br>
		</fieldset>
		<input type="submit" name="submit" value="Submit" style="float: left" class="myButton">
		<br><br><br>	
	</form>
	

	
	<!--display table-->
	<table id="my_table" cellpadding="3" cellspacing="1" border="1">
	<tr>
	
	<!--build table header (display a link for each column)-->
	<?php for ($i = 0; $i <mysql_num_fields($result); $i++) {
		print '<th scope="col">';
		if($_GET['orderBy'] == mysql_field_name($result, $i)){ 
			print '<a href="mysql_query.php?table_name='.$_GET['table_name'].'&orderBy='.mysql_field_name($result, $i).'_desc&row_number='.$_GET['row_number'].'&column='.$_GET['column'].'&operation='.$_GET['operation'].'&number='.$_GET['number'].'&search='.$_GET['search'].'">'.mysql_field_name($result, $i).'<br><img src="images/arrowUp.gif" " /></a>'; 
		}
		elseif($_GET['orderBy'] == mysql_field_name($result, $i).'_desc'){
			print '<a href="mysql_query.php?table_name='.$_GET['table_name'].'&orderBy='.mysql_field_name($result, $i).'&row_number='.$_GET['row_number'].'&column='.$_GET['column'].'&operation='.$_GET['operation'].'&number='.$_GET['number'].'&search='.$_GET['search'].'">'.mysql_field_name($result, $i).'<br><img src="images/arrowDown.gif" " /></a>'; 
		}
		else{ 
			print '<a href="mysql_query.php?table_name='.$_GET['table_name'].'&orderBy='.mysql_field_name($result, $i).'&row_number='.$_GET['row_number'].'&column='.$_GET['column'].'&operation='.$_GET['operation'].'&number='.$_GET['number'].'&search='.$_GET['search'].'">'.mysql_field_name($result, $i).'</a>'; 
		}
		print '</th>';

	}

	print '</tr>';
	//display table content
	print $content;
	print '</table>';
	print '<br><br><br><br><br><br><br>';

	//close connection
	mysql_close($connect);

	?>
</body>
</html>

