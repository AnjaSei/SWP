<?php
//move uploaded files from temp folder to $storefolder
 
$storefolder = 'uploads';   
 
if (!empty($_FILES)) {
     
    $tempfiles = $_FILES['file']['tmp_name'];                    
    $targetpath = $storefolder."/";  
    $targetfiles =  $targetpath.$_FILES['file']['name'];  

    move_uploaded_file($tempfiles, $targetfiles); 
     
}
?> 

