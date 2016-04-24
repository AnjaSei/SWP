 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--
/*
 * blueimp Gallery Demo
 * https://github.com/blueimp/Gallery
 *
 * Copyright 2013, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */
-->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Softwarepraktikum: Gruppe1</title>
	<link rel="stylesheet" type="text/css" href="css/my_style.css" />
	<div id="bild"><img src="images/startseite1.png" width=1100 height=100 >
	<link rel="stylesheet" href="css/blueimp-gallery.min.css">
</head>

<body>

<?php
//collect settings (selected by the user) to run the R script 
$commando="";

if (isset($_POST['run_R'])){

      	if (isset($_POST['boxplot'])){
		$commando.=" --boxplot ";	
      	}

      	if (isset($_POST['hist'])){
       		$commando.=" --hist ";
      	}

	if (isset($_POST['microarray_img'])){
        	$commando.=" --microarray_img ";	
      	}

      	if (isset($_POST['plm'])){
       		$commando.=" --plm ";
      	}

	if (isset($_POST['heatmap'])){
         	$commando.=" --heatmap ";	
      	}

      	if (isset($_POST['topo'])){
        	$commando.=" --topo ";
      	}

	if (isset($_POST['rnadeg'])){
       		$commando.=" --rnadeg ";
      	}

      	if (isset($_POST['qcplot'])){
      		$commando.=" --qcplot ";
      	}

	if (isset($_POST['table'])){
     		$commando.=" --table ";
      	}

	if (isset($_POST['scatter'])){
      		$commando.=" --scatter ";
      	}

	if (isset($_POST['topgenes'])){
		if(isset($_POST["gen_numb"])){
			$gene_number = $_POST['gen_numb'];
       			$commando.=" --topgenes ".$gene_number." ";
		}

      	}

}

//run R Script
//folder with the R Script results
$output_folder="output";
exec("Rscript update2_param.R --input uploads --output $output_folder ".$commando);


//traverse the directory (inclusive subfolders) and view the images with the blueimp gallery
function listFolderFiles($ordner){

	$alledateien = scandir($ordner);          				

	foreach ($alledateien as $datei) {
		$dateiinfo = pathinfo($ordner."/".$datei); 
		$size = ceil(filesize($ordner."/".$datei)/1024); 
	
		if ($datei != "." && $datei != "..") { 
			//echo $datei."<br />\n";		
			if(is_dir($ordner.'/'.$datei)){
				//echo '$ordner.'/'.$datei';
				//echo $dateiinfo['basename']."<br />\n";
				listFolderFiles($ordner.'/'.$datei);
			
			}
			else{
				//echo '$ordner.'/'.$datei';
				//gueltige Bildtypen
				$bildtypen= array("jpg", "jpeg", "gif", "png");
				//Bild
				if(in_array($dateiinfo['extension'], $bildtypen)){
				?>	
    					<a href="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>">
        					<img src="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>" alt="Vorschau" width="250" height="250">
    					</a>
    					
    				<?php 
				
				}
			};
		};
 	};
}


if (isset($_POST['table'])){
		
	//Create and fill tables in the data base 

	//database connection details
	$connect = mysql_connect('localhost','anja', "123") or die('Could not connect to MySQL: '. mysql_error());

	//database name
	mysql_select_db('anja', $connect);
	
	//create tables in the database
	$arr=array("rma","mas5");
	
	foreach ($arr as $dataset) {

		$checktable = mysql_query("SHOW TABLES LIKE '$dataset'");
	
		if(mysql_num_rows($checktable) > 0){
			//echo "Table $dataset already exists!<br />\n";
			mysql_query("TRUNCATE TABLE $dataset", $connect) or die('Could not delete table content: '.mysql_error());
			//echo "Deleted old table $dataset content.<br />\n";
	
		}
		else{

			if($dataset=='rma'){
				$sql = "CREATE TABLE $dataset (PROBEID VARCHAR(100) NOT NULL, SYMBOL VARCHAR(100) NOT NULL, ND_11_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_13_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_51_CD14_133Plus_2 DOUBLE NOT NULL, ND_52_CD14_133Plus_2 DOUBLE NOT NULL, ND_53_CD14_133Plus_2 DOUBLE NOT NULL, ND_5_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_6_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_7_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_8_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, MEAN_ALL DOUBLE NOT NULL, gesund_median DOUBLE NOT NULL, krank_median DOUBLE NOT NULL, gesund_mean DOUBLE NOT NULL, krank_mean DOUBLE NOT NULL, gesund_sd DOUBLE NOT NULL, krank_sd DOUBLE NOT NULL, gesund_min DOUBLE NOT NULL, krank_min DOUBLE NOT NULL, gesund_max DOUBLE NOT NULL, krank_max DOUBLE NOT NULL, p_value DOUBLE NOT NULL, SLR DOUBLE NOT NULL, FC DOUBLE NOT NULL, PRIMARY KEY(PROBEID));";
  			}
			elseif($dataset=="mas5"){
				$sql = "CREATE TABLE $dataset (PROBEID VARCHAR(100) NOT NULL, SYMBOL VARCHAR(100) NOT NULL, ND_11_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_13_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_51_CD14_133Plus_2 DOUBLE NOT NULL, ND_52_CD14_133Plus_2 DOUBLE NOT NULL, ND_53_CD14_133Plus_2 DOUBLE NOT NULL, ND_5_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_6_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_7_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_8_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, MEAN_ALL DOUBLE NOT NULL, gesund_median DOUBLE NOT NULL, krank_median DOUBLE NOT NULL, gesund_mean DOUBLE NOT NULL, krank_mean DOUBLE NOT NULL, gesund_sd DOUBLE NOT NULL, krank_sd DOUBLE NOT NULL, gesund_min DOUBLE NOT NULL, krank_min DOUBLE NOT NULL, gesund_max DOUBLE NOT NULL, krank_max DOUBLE NOT NULL, p_value DOUBLE NOT NULL, SLR DOUBLE NOT NULL, FC DOUBLE NOT NULL, 
ND_11_CD14_IFNa2a_90_133Plus_2_pma VARCHAR(1) NOT NULL, ND_13_CD14_IFNa2a_90_133Plus_2_pma VARCHAR(1) NOT NULL, ND_51_CD14_133Plus_2_pma VARCHAR(1) NOT NULL, ND_52_CD14_133Plus_2_pma VARCHAR(1) NOT NULL, ND_53_CD14_133Plus_2_pma VARCHAR(1) NOT NULL, ND_5_CD14_IFNa2a_90_133Plus_2_pma VARCHAR(1) NOT NULL, ND_6_CD14_IFNa2a_90_133Plus_2_pma VARCHAR(1) NOT NULL, ND_7_CD14_IFNa2a_90_133Plus_2_pma VARCHAR(1) NOT NULL, ND_8_CD14_IFNa2a_90_133Plus_2_pma VARCHAR(1) NOT NULL, PRIMARY KEY(PROBEID));";

			}
		mysql_query( $sql, $connect ) or die('Could not create table: '.mysql_error());
	
		//echo "Table $dataset created successfully!<br />\n";
		}

		// Name of CSV file
		$csv_file = $output_folder."/table_$dataset.csv"; 
	
		if (($handle = fopen($csv_file, "r")) !== FALSE) {
  			fgetcsv($handle);   
			if($dataset=='rma'){
   				while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
		
					$import="INSERT into $dataset VALUES('$data[0]', '$data[1]', $data[2], $data[3], $data[4], $data[5], $data[6], $data[7], $data[8], $data[9], $data[10], $data[11], $data[12], $data[13], $data[14], $data[15], $data[16], $data[17], $data[18], $data[19], $data[20], $data[21], $data[22], $data[23], $data[24] )";

  				mysql_query($import) or die(mysql_error());
	
 				}
    			fclose($handle);
			}
			
			elseif($dataset=='mas5'){
   				while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
		
					$import="INSERT into $dataset VALUES('$data[0]', '$data[1]', $data[2], $data[3], $data[4], $data[5], $data[6], $data[7], $data[8], $data[9], $data[10], $data[11], $data[12], $data[13], $data[14], $data[15], $data[16], $data[17], $data[18], $data[19], $data[20], $data[21], $data[22], $data[23], $data[24], '$data[25]', '$data[26]', '$data[27]', '$data[28]', '$data[29]', '$data[30]', '$data[31]', '$data[32]', '$data[33]' )";

  				mysql_query($import) or die(mysql_error());
	
 				}
    			fclose($handle);
			}

		}

		//echo "File data successfully imported to database $dataset!!<br />\n";
	}
	mysql_close($connect);
	
	
}
?>
	<div id="topmenue">Softwarepraktikum GRUPPE1</div>
	</div><div id="content">
		<h1> Willkommen auf der Bioinformatik-Homepage </h1>
		<h2></h2>
		<h4><br>Folgende Signaldateien wurden für die eingegebenen CEL.Files erstellt:<br></h4>
	</div>

	<div>
 		<a href="index.php" style="float: left; color: blue">Neue Anfrage</a>
		<?php
		if (isset($_POST['table'])){
  			?><a href="mysql_query.php" style="float: right; color: blue">Signaltabellen anzeigen</a><br></br><?php
		}
		else{
			?><br></br> <?php
		}?>
	</div>

<div id="blueimp-gallery" class="blueimp-gallery  blueimp-gallery-controls">
    <div class="slides"></div>
    <h3 class="title"></h3>
    <a class="prev">‹</a>
    <a class="next">›</a>
    <a class="close">×</a>
    <a class="play-pause"></a>
    <ol class="indicator"></ol>
</div>



<div id="links">
<?php
	//view images inside the output folder on the webpage as an image gallery
	listFolderFiles($output_folder);
?>
</div>



<script src="js/blueimp-gallery.min.js"></script>
<script>
document.getElementById('links').onclick = function (event) {
    event = event || window.event;
    var target = event.target || event.srcElement,
        link = target.src ? target.parentNode : target,
        options = {index: link, event: event},
        links = this.getElementsByTagName('a');
    blueimp.Gallery(links, options);
};
</script>



</script>
</body>
</html>
