<?php

# Without access control settings, this script can not be accessed from outside.
header('Access-Control-Allow-Origin:*');
header('Access-Control-Allow-Methods:GET, POST, OPTIONS, PUT, PATCH, DELETE');
header('Access-Control-Allow-Headers:X-Requested-With,content-type');
header('Access-Control-Allow-Credentials:true');

# Obtain fields that are sent from client side via POST (you can see "method: 'POST'" on my JavaScript code. Linjie's original readTxtFile() methods uses GET request, since GET is a default value of method of $.ajax.
$assignmentID = $_POST['assignmentID'];
$workerID = $_POST['workerID'];
$hitID = $_POST['hitID'];

# These three issets' checks if the three fields exist in the received POST form
if (isset($assignmentID) && isset($workerID) && isset($hitID)){

  # These three strcmps' checks if assigment ID equals 1, worker Id equals 2, and hit ID equals 3. If so , then go on. This is for showing how you can validate data in PHP. You can adjust or delete this code however you like.
  #if (strcmp($assignmentID, "1") !== 0 or strcmp($workerID, "2") !== 0 or strcmp($hitID, "3") !== 0){
    
    # These two lines define how the server will return data to the client.
    #header('HTTP/1.1 400 InvalidID');
    #exit('Fail to get counter because of invalid ID.');
  #}

  # These three lines read the counter.txt (stored in this folder)
  $counter_file = fopen('counterDebug.txt', 'r');
  $aLine = fread($counter_file, filesize("counterDebug.txt"));
  if (strlen($aLine) > 1){
    $aLineArray = explode(" ", $aLine);
    $counter = $aLineArray[0];
    $workerID_old = $aLineArray[1];
  }
  else{
    $counter = $aLine;
  }
  
  fclose($counter_file);

  if (strcmp($workerID_old,$workerID)!== 0 or strlen($aLine)<= 1){
    # These four lines increments the counter by 1, then overwrite it to counter.txt
    $counter = ((int)$counter + 1);
    if ($counter > 235){
      $counter = 0;
    }
    $writing_data = ( (string)$counter).' '.$workerID;
    $counter_file = fopen('counterDebug.txt', 'w');
    $write_file = fwrite($counter_file, $writing_data);
    fclose($counter_file);
  }

  header("HTTP/1.1 200 UpdateComplete");
  exit("Update Complete. The new counter is " . (string)$counter);
}
?>

HAHA
<form method="POST" action="update_counter.php">
  <input name="assignmentID"/>
  <input name="workerID"/>
  <input name="hitID"/>
  <button type="submit">Submit</button>
  </form>
