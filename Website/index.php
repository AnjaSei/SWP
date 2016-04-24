<!DOCTYPE html>
<html lang="en">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Softwarepraktikum: Gruppe1</title>
	<link rel="stylesheet" type="text/css" href="css/my_style.css" />
	<link href="css/dropzone.css" type="text/css" rel="stylesheet" />
	<div id="bild"><img src="images/startseite1.png" width=1200 height=100 >
	<div id="topmenue">Softwarepraktikum GRUPPE1</div>
</head>

<body>
	
	
	</div><div id="content">
		<h1> Willkommen auf der Bioinformatik-Homepage </h1>
		.....
	</div>
<script src="js/dropzone.min.js"></script>
<form action="upload.php" class="dropzone" id="mydz"></form> 
<script type="text/javascript">

Dropzone.options.mydz = {
    dictDefaultMessage: "Put your CEL.files here."
};

</script>


<script src="http://code.jquery.com/jquery-1.9.1.js"></script>

<script language="JavaScript">
    
    /*function toggle(className, obj) {
    	var $input = $(obj);
    	if ($input.prop('checked')) $(className).hide();
    	else $(className).show();
    }*/
	
   function toggleDiv(element){
   if(document.getElementById(element).style.display == 'none')
       document.getElementById(element).style.display = 'block';
   else
       document.getElementById(element).style.display = 'none';
   }


</script>

<form action="run_R.php" method="post">
	<br/>
	<fieldset>
	<!--<legend><input type="checkbox" , name="all", onclick="toggle('.myClass', all )">Generiere alle Daten </legend>-->
	<legend><input type="checkbox" , name="all", id="all">Generiere alle Daten </legend>
	<script language="JavaScript">
	$('#all').click(function(event) {   
    		if(this.checked) {
        		$(':checkbox').each(function() {
            			this.checked = true;                        
       			 });
   	 	}
   	 	else { $(":checkbox").each(function() { 
	   	 		this.checked = false; 
			});
    		}
	});
	</script>
    	<span class="myClass">
		<p><input type="checkbox" name="boxplot"/><a href="javascript:toggleDiv('boxpot_description');">Boxplots </a></p>
		<div id="boxpot_description" style="display:none;">Kreiere Boxplots der Intensitätsverteilung der Rohdaten und der RMA und Mas5 normalisierten Daten.</div>

	        <p><input type="checkbox" name="hist" /><a href="javascript:toggleDiv('hist_description');" color:black>Histogramme und Density Plots</a> </p>
		<div id="hist_description" style="display:none;">Kreiere Histogramme und Density Plots der Signalverteilung von Rohdaten, RMA und Mas5 normalisierten Daten, sowie Density Plots der Verteilung von perfect matches und mismatches. </div>
		
		<p><input type="checkbox" name="microarray_img"/><a href="javascript:toggleDiv('img_description');">Microarraybilder</a> </p>
		<div id="img_description" style="display:none;">Kreiere Microarraybilder der Rohdaten. </div>
	        
		<p><input type="checkbox" name="plm"/><a href="javascript:toggleDiv('plm_description');">PLM images</a></p>
		<div id="plm_description" style="display:none;">Kreiere für jeden Microarray ein Probe Level Model Image um Artefakte zu erkennen.</div>	    
    		
		<p><input type="checkbox" name="heatmap"/><a href="javascript:toggleDiv('heatmap_description');">Heatmaps</a></p>
		<div id="heatmap_description" style="display:none;">Kreiere für jeden Microarray eine Heatmap.</div>	

		<p><input type="checkbox" name="topo"/><a href="javascript:toggleDiv('topo_description');">Topographische Bilder</a></p>
		<div id="topo_description" style="display:none;">Kreiere für jeden Microarray ein topographisches Bild.</div>

	        <p><input type="checkbox" name="rnadeg"/><a href="javascript:toggleDiv('rnadeg_description');">RNA Degradierungsplot</a></p>
		<div id="rnadeg_description" style="display:none;">Überprüfe die RNA-Qualität auf jedem Array mit Hilfe eines RNA Degradierungsplots.</div>

		<p><input type="checkbox" name="qcplot"/><a href="javascript:toggleDiv('qcplot_description');">Qualitätskontrollplot</a></p>
	        <div id="qcplot_description" style="display:none;">Kreiere einen Qualitätskontrollplot um die Qualität der einzelnen Arrays zu vergleichen.</div>


		<p><input type="checkbox" name="table"/><a href="javascript:toggleDiv('table_description');">Signalintensitätstabellen </a></p>
	        <div id="table_description" style="display:none;">Kreiere für die RMA und Mas5 normalisierte Daten je eine Tabelle mit folgendem Inhalt: <br/> AffyID, Gensymbol, Intensitätswerte für jeden CEL.file, Gesamtintensitätsmittelwert sowie Median, Mittelwert, Standardabweichung, Minimum und Maximum pro Kontroll- und Experimentalgruppe zudem p-Wert, Fold Change und Signal Log Ratio zwischen diesen Gruppen.</div>

		<p><input type="checkbox" name="scatter"/><a href="javascript:toggleDiv('scatter_description');">Scatter Plots</a></p>
		<div id="scatter_description" style="display:none;">Kreiere Scatter Plots für jedes Microarraypaar.</div>


		<p><input type="checkbox" name="topgenes"/><a href="javascript:toggleDiv('topgenes_description');">Venn Diagramme </a>&emsp;&emsp;&emsp;&emsp;&emsp;Anzahl der Gene: <input id="gen_numb" name="gen_numb" type="number" min="5" max="5000" step="1" value="50"></p>
		<div id="topgenes_description" style="display:none;">Erzeuge Venn Diagramme der top differenziell exprimierten Gene zwischen Kontroll- und Experimentalgruppe für RMA und Mas5 normalisierte Daten. Sortiert wird nach p-Wert, Fold Change und Signal Log Ratio.</div>
     
	    </span>
	</fieldset>
 		
	<input type="submit" name="run_R" value="Run RScript and wait for results...">

</form>

<p><br></p>


</body>
</html>
