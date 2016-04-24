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
		margin:10px 10px 0  0;
		font-family:Arial, Helvetica, sans-serif;	
	}
	div.galerie:hover{
		border:1px solid #333;
	}
	div.galerie span{
		display:block;
		text-align:center;
		font-size:10px;
	}
	div.galerie a img{
		border:none;
	}
	div.file {
		padding:4px 4px 4px 30px;
	}
	div.file.even{
		background-color: #ebebeb;
	}
	div.file a {
		text-decoration:none;
	}
	div.file:hover {
		background-color:#CCC;
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
				
				} // wenn keine Bildendung dann normale Liste für Dateien ausgeben (log Files verwerfen)
				else { 
					if(!in_array($dateiinfo['extension'], array("log"))){?>
					
            					<div class="file">
            					<a href="<?php echo $dateiinfo['dirname']."/".$dateiinfo['basename'];?>">&raquo <?php echo $dateiinfo['filename'].".".$dateiinfo['extension']; ?></a> <!--(<?php echo $dateiinfo['extension']; ?> | <?php echo $size ; ?>kb)-->
            					</div>
            			<?php } ?> 
				<?php
				};
			};
		};
 	};
}

//exec("Rscript update2_short.R uploads");
//folder with R results
$output_folder="output";

listFolderFiles($output_folder);
?> 
</body>
</html>
