<!DOCTYPE html>
<html lang="en">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Softwarepraktikum: Gruppe1</title>
	<link rel="stylesheet" type="text/css" href="css/dropzone.css" />
	<link rel="stylesheet" type="text/css" href="css/my_style.css" />
	<div id="image"><img src="images/startseite1.png" width=1200 height=100 ></div>
	<div id="topmenue">Softwarepraktikum GRUPPE1</div>
</head>

<body>
	
	<div id="content">
		<h1> Willkommen auf der Bioinformatik-Homepage </h1><br>
	</div>

	<!--load dropzone library to upload .CEL files-->
	<script src="js/dropzone.min.js"></script>
	<form action="upload.php" class="dropzone" id="mydz"></form> 
	<button id="submit_all" class="myButton" disabled>Submit all .CEL files</button><br>
	<!--set dropzone options-->
	<script>
	Dropzone.options.mydz = {
	    	dictDefaultMessage: "Put your CEL.files here.",
		parallelUploads: 30,  
		acceptedFiles:'.cel',
		//prevents Dropzone from uploading dropped files immediately
	  	autoProcessQueue: false,

	  	init: function() {
	    		var submitButton = document.querySelector("#submit_all")
			myDropzone = this; 
		
			//if submit_all-button is clicked do ...
	    		submitButton.addEventListener("click", function() {
				//process all queued files
	      			myDropzone.processQueue(); 
				//enable the RScript options checkboxes
				document.getElementById("all").disabled=false;
				document.getElementById("rscript_options").disabled=false;
			});

	 		//if .CEL files are choosen enable submit_all .Cel-files button 
			this.on("addedfile", function() {
				document.getElementById("submit_all").disabled=false;      
	   	 	});
	 	 }
	};

	</script><br>

	<!--build form for the user to select RScript options and call run_R.php-->
	<form action="run_R.php" method="post">
		<fieldset id="rscript_options" disabled>
		<script>
		//show description for each RScript option
		function show_description(element){
			if(document.getElementById(element).style.display == 'none'){
				document.getElementById(element).style.display = 'block';
			}
			else{
				document.getElementById(element).style.display = 'none';
			}
		}
		</script>
		<legend><input type="checkbox" , name="all", id="all" disabled>Generiere alle Daten </legend>
		<script src="js/jquery-1.12.3.js"></script>
		<script>
		//if all-checkbox is clicked check all other checkboxes too
		$('#all').click(function() {   
	    		if(this.checked) {
				$(':checkbox').each(function() {
		    			this.checked = true;                        
	       			 });
	   	 	}
	   	 	else { 
				$(":checkbox").each(function() { 
		   	 		this.checked = false; 
				});
	    		}
		});
		</script>

		<!--RScript options with description-->
		<p><input type="checkbox" name="boxplot" id="boxplot" /><a href="javascript:show_description('boxpot_description');">Boxplots </a></p>
		<div id="boxpot_description" style="display:none;">Kreiere Boxplots der Intensitätsverteilung der Rohdaten und der RMA und Mas5 normalisierten Daten.</div>

		<p><input type="checkbox" name="hist" id="hist" /><a href="javascript:show_description('hist_description');">Histogramme und Density Plots</a> </p>
		<div id="hist_description" style="display:none;">Kreiere Histogramme und Density Plots der Signalverteilung von Rohdaten, RMA und Mas5 normalisierten Daten, sowie Density Plots der Verteilung von perfect matches und mismatches. </div>
		
		<p><input type="checkbox" name="microarray_img" id="microarray_img"/><a href="javascript:show_description('img_description');">Microarraybilder</a> </p>
		<div id="img_description" style="display:none;">Kreiere Microarraybilder der Rohdaten. </div>
			
		<p><input type="checkbox" name="plm" id="plm"/><a href="javascript:show_description('plm_description');">PLM images</a></p>
		<div id="plm_description" style="display:none;">Kreiere für jeden Microarray ein Probe Level Model Image um Artefakte zu erkennen.</div>	    
		<p><input type="checkbox" name="heatmap" id="heatmap"/><a href="javascript:show_description('heatmap_description');">Heatmaps</a></p>
		<div id="heatmap_description" style="display:none;">Kreiere für jeden Microarray eine Heatmap.</div>	

		<p><input type="checkbox" name="topo" id="topo"/><a href="javascript:show_description('topo_description');">Topographische Bilder</a></p>
		<div id="topo_description" style="display:none;">Kreiere für jeden Microarray ein topographisches Bild.</div>

		<p><input type="checkbox" name="rnadeg" id="rnadeg"/><a href="javascript:show_description('rnadeg_description');">RNA Degradierungsplot</a></p>
		<div id="rnadeg_description" style="display:none;">Überprüfe die RNA-Qualität auf jedem Array mit Hilfe eines RNA Degradierungsplots.</div>

		<p><input type="checkbox" name="qcplot" id="qcplot"/><a href="javascript:show_description('qcplot_description');">Qualitätskontrollplot</a></p>
		<div id="qcplot_description" style="display:none;">Kreiere einen Qualitätskontrollplot um die Qualität der einzelnen Arrays zu vergleichen.</div>

		<p><input type="checkbox" name="table" id="table"/><a href="javascript:show_description('table_description');">Signalintensitätstabellen </a></p>
		<div id="table_description" style="display:none;">Kreiere für die RMA und Mas5 normalisierte Daten je eine Tabelle mit folgendem Inhalt: <br/> AffyID, Gensymbol, Intensitätswerte für jeden CEL.file, Gesamtintensitätsmittelwert sowie Median, Mittelwert, Standardabweichung, Minimum und Maximum pro Kontroll- und Experimentalgruppe zudem p-Wert, Fold Change und Signal Log Ratio zwischen diesen Gruppen.</div>
		<p><input type="checkbox" name="scatter" id="scatter"/><a href="javascript:show_description('scatter_description');">Scatter Plots</a></p>
		<div id="scatter_description" style="display:none;">Kreiere Scatter Plots für jedes Microarraypaar.</div>


		<p><input type="checkbox" name="topgenes" id="topgenes"/><a href="javascript:show_description('topgenes_description');">Venn Diagramme </a>&emsp;&emsp;&emsp;&emsp;&emsp;Anzahl der Gene: <input id="gen_numb" name="gen_numb" type="number" min="5" max="5000" step="1" value="50"></p>
		<div id="topgenes_description" style="display:none;">Erzeuge Venn Diagramme der top differenziell exprimierten Gene zwischen Kontroll- und Experimentalgruppe für RMA und Mas5 normalisierte Daten. Sortiert wird nach p-Wert, Fold Change und Signal Log Ratio.</div>
		
		</fieldset>
		<input type="submit" name="run_R" id="run_R" value="Run RScript and wait for results..." class="myButton">
		
	</form><br>


</body>
</html>
