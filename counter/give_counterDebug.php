<?php
header('Access-Control-Allow-Origin:*');
header('Access-Control-Allow-Methods:GET, POST, OPTIONS, PUT, PATCH, DELETE');
header('Access-Control-Allow-Headers:X-Requested-With,content-type');
header('Access-Control-Allow-Credentials:true');

$assignmentID = $_POST['assignmentID'];
$workerID = $_POST['workerID'];
$hitID = $_POST['hitID'];

#$postdata = file_get_contents("php://input");
#$request = json_decode($postdata);

#@$assignmentID = $request->assignmentID;
#@$workerID = $request->workerID;
#@$hitID = $request->hitID;
if (isset($assignmentID) && isset($workerID) && isset($hitID)){
  #if (strcmp($assignmentID, "1") !== 0 or strcmp($workerID, "2") !== 0 or strcmp($hitID, "3") !== 0){
    #header('HTTP/1.1 400 InvalidID');
    #exit('Fail to get counter because of invalid ID.');
  #}

  $counter_file = fopen('counterDebug.txt', 'r');
  $aLine = fread($counter_file, filesize("counterDebug.txt"));
  if (strlen($aLine) > 1){
    $aLineArray = explode(" ", $aLine);
    $counter = $aLineArray[0];
  }
  else{
    $counter = $aLine;
  }
  fclose($counter_file);

  header("HTTP/1.1 200 SuccefullyGetCounter");
  exit("Current counter is " . (string)$counter);
}
?>
HAHA
