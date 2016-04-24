<?php

//database connection details
$connect = mysql_connect('localhost','anja', "123") or die('Could not connect to MySQL: '. mysql_error());

//database name
mysql_select_db('anja', $connect);


// path where CSV file is located
define('CSV_PATH','output/');

//create tables in database
for ($i = 0; $i <=1; $i++) {
   	if ($i==0){
		$dataset='rma';
	}
	else{
		$dataset='mas5';
	}

	$checktable = mysql_query("SHOW TABLES LIKE '$dataset'");

	if(mysql_num_rows($checktable) > 0){
		echo "Table $dataset already exists!<br />\n";
		mysql_query("TRUNCATE TABLE $dataset", $connect) or die('Could not delete table content: '.mysql_error());
		echo "Deleted old table $dataset content.<br />\n";

	}
	else{
	$sql = "CREATE TABLE $dataset (PROBEID VARCHAR(100) NOT NULL, SYMBOL VARCHAR(100) NOT NULL, ND_11_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_13_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_51_CD14_133Plus_2 DOUBLE NOT NULL, ND_52_CD14_133Plus_2 DOUBLE NOT NULL, ND_53_CD14_133Plus_2 DOUBLE NOT NULL, ND_5_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_6_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_7_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, ND_8_CD14_IFNa2a_90_133Plus_2 DOUBLE NOT NULL, MEAN_ALL DOUBLE NOT NULL, gesund_median DOUBLE NOT NULL, krank_median DOUBLE NOT NULL, gesund_mean DOUBLE NOT NULL, krank_mean DOUBLE NOT NULL, gesund_sd DOUBLE NOT NULL, krank_sd DOUBLE NOT NULL, gesund_min DOUBLE NOT NULL, krank_min DOUBLE NOT NULL, gesund_max DOUBLE NOT NULL, krank_max DOUBLE NOT NULL, p_value DOUBLE NOT NULL, SLR DOUBLE NOT NULL, FC DOUBLE NOT NULL, PRIMARY KEY(PROBEID));";
  
	$retval = mysql_query( $sql, $connect ) or die('Could not create table: '.mysql_error());

	echo "Table $dataset created successfully!<br />\n";
	}

	// Name of CSV file
	$csv_file = CSV_PATH."table_$dataset.csv"; 

	if (($handle = fopen($csv_file, "r")) !== FALSE) {
  		fgetcsv($handle);   
   		while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
	
  		//$import="INSERT into test2 (PROBEID, SYMBOL, ND_11_CD14_IFNa2a_90_133Plus_2.CEL, ND_13_CD14_IFNa2a_90_133Plus_2.CEL, ND_51_CD14_133Plus_2.CEL, ND_52_CD14_133Plus_2.CEL, ND_53_CD14_133Plus_2.CEL, ND_5_CD14_IFNa2a_90_133Plus_2.CEL, ND_6_CD14_IFNa2a_90_133Plus_2.CEL, ND_7_CD14_IFNa2a_90_133Plus_2.CEL, ND_8_CD14_IFNa2a_90_133Plus_2.CEL, MEAN_ALL, gesund_median, krank_median, gesund_mean, krank_mean, gesund_sd, krank_sd, gesund_min, krank_min, gesund_max, krank_max, p_value, SLR, FC) VALUES('$data[0]', '$data[1]', $data[2], $data[3], $data[4], $data[5], $data[6], $data[7], $data[8], $data[9], $data[10], $data[11], $data[12], $data[13], $data[14], $data[15], $data[16], $data[17], $data[18], $data[19], $data[20], $data[21], $data[22], $data[23], $data[24])";
		$import="INSERT into $dataset VALUES('$data[0]', '$data[1]', $data[2], $data[3], $data[4], $data[5], $data[6], $data[7], $data[8], $data[9], $data[10], $data[11], $data[12], $data[13], $data[14], $data[15], $data[16], $data[17], $data[18], $data[19], $data[20], $data[21], $data[22], $data[23], $data[24] )";

  		mysql_query($import) or die(mysql_error());
	

 		}
    		fclose($handle);
	}

	echo "File data successfully imported to database $dataset!!<br />\n";
}
mysql_close($connect);
?>
