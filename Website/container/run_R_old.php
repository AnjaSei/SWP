 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Softwarepraktikum: Gruppe1</title>
	<link rel="stylesheet" type="text/css" href="css/my_style.css" />
	<div id="bild"><img src="images/startseite1.png" width=1100 height=100 >
	<style type="text/css">
	div.galerie{
		padding: 3px;
		background-color:#ebebeb;
		border:1px solid #CCC;
		float:left;
		margin:10px 0px 10px  0px;
		font-family:Arial, Helvetica, sans-serif;	
		text-align:center;
	}
	div.galerie:hover{
		border:1px solid #333;
	}
	div.galerie span{
		display:block;
		text-align:center;
		font-size:7px;
	}
	div.galerie a img{
		border:none;
	}

	</style>

</head>

<body>

	<div id="topmenue">Softwarepraktikum GRUPPE1</div>
	</div><div id="content">
		<h1> Willkommen auf der Bioinformatik-Homepage </h1>
		<h2></h2>
		<h4><br>Folgende Signaldateien wurden für die eingegebenen CEL.Files erstellt:<br></h4>
	</div>
<?php
 //mit isset wird geprüft ob einer Variablen bereits 
  //ein Wert zugewiesen wurde
$commando="";
$mysql_tables=FALSE;
if (isset($_POST['run_R'])){

      if (isset($_POST['all'])){
	$commando=" --all";
      }
      else{
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
		$mysql_tables=TRUE;
      	}
	if (isset($_POST['scatter'])){
      		$commando.=" --scatter ";
      	}
	if (isset($_POST['topgenes'])){
       		$commando.=" --topgenes ";
      	}

    }


}

//exec("Rscript update2_param.R --input uploads ".$commando);



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
				if(in_array($dateiinfo['extension'],$bildtypen)){
				?>
            				<div class="galerie">
                			<a href="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>">
               				<img src="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>" width="200" height="200" alt="Vorschau" /></a> 					
                			<!--<span><?php echo $dateiinfo['filename']; ?> (<?php echo $size."<br />\n" ; ?>kb)</span>-->
            				</div>
			
    				<?php 
				
				}
			};
		};
 	};
}



$output_folder="output";
listFolderFiles($output_folder);

/* 

if (mysql_table){
	rufe  cvimport auf (speichert Tabellen in der Datenbank)
	rufe abfrage_datenbank auf (Buttons zur Auswahl der Einträge & Spalten der Tabellen in der Datenbank + anzeigen der Tabelle )
}


*/

?>
</body>
</html>
