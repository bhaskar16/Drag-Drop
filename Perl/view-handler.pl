#!"C:\xampp\perl\bin\perl.exe"

use DBI;

local ($buffer, @pairs, $pair, $name, $value, $xmlStr, $cnt, %FORM);
# Read in text
$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
if ($ENV{'REQUEST_METHOD'} eq "POST") {
  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
} else {
  $buffer = $ENV{'QUERY_STRING'};
} # Split information into name/value pairs
@pairs = split(/&/, $buffer);
foreach $pair (@pairs) {
  ($name, $value) = split(/=/, $pair);
  $value =~ tr/+/ /;
  $value =~ s/%(..)/pack("C", hex($1))/eg;
  $FORM{$name} = $value;
}

# Connect to database
$dbh = DBI->connect('dbi:mysql:sampleit','root','') 
       or die "Connection Error: $DBI::errstr\n";

# Find User and disconnect;
$sql = "select * from users where id = ?";$stmt = $dbh->prepare($sql);
$stmt->execute($FORM{'userID'}) or die "SQL Error: $DBI::errstr\n";$cnt = 0;
while (@row = $stmt->fetchrow_array) { 
  $xmlStr = $row[1];$cnt++;
} $stmt->finish();$dbh->disconnect();

# Send Confirmation or Rejection
if($cnt == 1) {
  print "Content-Type: text/html\n\n";
  print "<!DOCTYPE html>\n";
  print "<html lang='en'>\n";
  print "<head>\n";
  print "<meta charset='utf-8'>\n";
  print "<meta http-equiv='X-UA-Compatible' content='IE=edge'>\n";
  print "<meta name='viewport' content='width=device-width, initial-scale=1'>\n";
  print "<title>My Canvas</title>\n";
  print "<link href='http://code.jquery.com/ui/1.10.4/themes/ui-lightness/jquery-ui.css' rel='stylesheet' />\n";
  print "<script src='http://code.jquery.com/jquery-1.10.2.js'></script>\n";
  print "<script src='http://code.jquery.com/ui/1.10.4/jquery-ui.js'></script>\n";
  print "<script src='http://localhost/IT-Lab-Project/js/bootstrap.min.js'></script>\n";
  print "<link href='http://localhost/IT-Lab-Project/css/bootstrap.min.css' rel='stylesheet'>\n";
  print "<link href='http://localhost/IT-Lab-Project/css/simple-sidebar.css' rel='stylesheet'>\n";
  print "</head><body><script>\n";
  print "var type = new Array();var top_pos = new Array();var left_pos = new Array();\n";
  print "function StringtoXML(oString) {\n";
  print "if (window.ActiveXObject) { var oXML = new ActiveXObject('Microsoft.XMLDOM');oXML.loadXML(oString);return oXML; }\n";
  print "else { return (new DOMParser()).parseFromString(oString, 'text/xml'); }\n";
  print "} function loadArr(str) {\n";
  print "var xml = StringtoXML(str);var elements = xml.documentElement.childNodes;\n";
  print "var id, top, left, i;for(i=0;i<elements.length;i++) {\n";
  print "id = elements[i].nodeName + '_' + elements[i].getAttribute('type');\n";
  print "top = ((elements[i].childNodes[0]).childNodes[0]).nodeValue;\n";
  print "left = ((elements[i].childNodes[1]).childNodes[0]).nodeValue;\n";
  print "type.push(id);top_pos.push(top);left_pos.push(left);}}\n";
  print "function render(){\n";
  print ("var str = '",$xmlStr,"';\n");
  print "loadArr(str);for (var i = 0 ;i <type.length;i++){\n";
  print "document.getElementById(type[i]).style.left=left_pos[i]+'px';\n";
  print "document.getElementById(type[i]).style.top=top_pos[i]+'px'; }}\n";
  print "</script><style>\n";
  print ".image{ width: 50px; height: 50px;postion:absolute; }\n";
  print "#droppable { z-index:-1;  }\n";
  print "body { overflow-y:scroll }\n";
  print "</style><div id='wrapper'><div id='sidebar-wrapper'><ul class='sidebar-nav'>\n";
  print "<li class='sidebar-brand'><a href='#'>My Island</a></li><li>\n";
    print "<button type='button' class='btn btn-danger btn-lg' onclick='render()' >Render My Design</button>\n"; 
  print "<button type='button' class='btn btn-info' data-toggle='collapse' data-target='#type1'>Watchtowers</button><br/>\n";
  print "<img id='watchtower_1' style='position:absolute; left: 5; top: 10; width: 50px;height: 50px;' src='http://localhost/IT-Lab-Project/images/LH1.jpe'   />\n";
  print "<img style='position:absolute; left: 56px; top: 10; width: 50px;height: 50px;' src='http://localhost/IT-Lab-Project/images/LH2.jpeg'  id='watchtower_2'/>\n";
  print "<br/><br/></li><li><br/>\n";
  print "<button type='button' class='btn btn-info' data-toggle='collapse' data-target='#type2'>cannons</button><br/>\n";				
  print "<img style='position:absolute; left: 5; top: 90; width: 50px;height: 50px;' src='http://localhost/IT-Lab-Project/images/canon1.png' id='cannon_1' />\n";
  print "<img style='position:absolute; left: 56px; top: 90; width: 50px;height: 50px;' src='http://localhost/IT-Lab-Project/images/canon2.jpg' id='cannon_2' />\n";
  print "<br/></li><li><br/>\n";				
  print "<button type='button' class='btn btn-info' data-toggle='collapse' data-target='#type3'>Boats</button><br/>\n";
  print "<img  style='position:absolute; left: 5; top: 170; width: 50px;height: 50px;' src='http://localhost/IT-Lab-Project/images/Boat1.jpg' id='boat_1'/>\n";
  print "<img  style='position:absolute; left: 56px; top: 170; width: 50px;height: 50px;' src='http://localhost/IT-Lab-Project/images/Boat2.jpg' id='boat_2'/>\n";
  print "<br/><br/></li><hr><li>\n";

  print "</li></ul></div><div class='container-fluid'><div class='row'><div class='col-lg-12'><br/>\n";                      
  print "<img  id='island' src='http://localhost/IT-Lab-Project/images/island.jpg' style='width:875px;height:600px;position:absolute;z-index:0;' />\n";
  print "</div></div></div></div></body></html>\n";
} else {
  print "Content-Type: text/html\n\n";
  print "<!DOCTYPE HTML>\n";
  print "<html>\n";
  print "<head>\n";
  print "<meta charset='UTF-8'/>\n";
  print "<title>Invalid ID</title>\n";
  print "</head>\n";
  print "<body>\n";
  print "<script type='text/javascript'>\n";
  print "alert('Invalid ID. Please Enter Proper ID.');\n";
  print "window.close();\n";
  print "</script>\n";
  print "</body>\n";
  print "</html>";  
}