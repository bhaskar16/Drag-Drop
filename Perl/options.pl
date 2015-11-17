#!"C:\xampp\perl\bin\perl.exe"
# Script to parse Form data

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
  print "<!DOCTYPE HTML>\n";
  print "<html>\n";
  print "<head>\n";
  print "<meta charset='UTF-8'/>\n";
  print "<title>View Person</title>\n";
  print "<style>\n";
  print "H1 {font-size:40px;color:#00F;text-align:center;}\n";
  print "td {padding:10px 20px;font-size:20px;float:center;}\n";
  print "</style>\n";
  print "<script type='text/javascript'>\n";
  print "function parseXML(xmlStr) {";
  print "return ( new window.DOMParser() ).parseFromString(xmlStr, 'text/xml');";
  print "} function loadData() {";
  print "var tab = document.getElementById('personData');";
  print "var uname = (tab.getElementsByTagName('tr')[0]).getElementsByTagName('td')[1];\n";
  print "var stream = (tab.getElementsByTagName('tr')[1]).getElementsByTagName('td')[1];";
  print "var year = (tab.getElementsByTagName('tr')[2]).getElementsByTagName('td')[1];";
  print "var roll = (tab.getElementsByTagName('tr')[3]).getElementsByTagName('td')[1];\n";
  print ("var xml = parseXML('",$xmlStr,"');\n");
  print "uname.innerHTML = xml.querySelector('name').innerHTML;";
  print "stream.innerHTML = xml.querySelector('stream').innerHTML;";
  print "year.innerHTML = xml.querySelector('year').innerHTML;";
  print "roll.innerHTML = xml.querySelector('roll').innerHTML;}\n";
  print "</script>\n";
  print "</head>\n";
  print "<body onload='loadData()'>\n";
  print "<H1>This is IT Lab</H1><hr><br><br>\n";
  print "<table id='personData'>\n";
  print "<tr><td>Name</td><td></td></tr>\n";
  print "<tr><td>Stream</td><td></td></tr>\n";
  print "<tr><td>Year</td><td></td></tr>\n";
  print "<tr><td>Roll</td><td></td></tr>\n";
  print "</table>";
  print "</body>\n";
  print "</html>";
} else {
  print "Content-Type: text/html\n\n";
  print "<!DOCTYPE HTML>\n";
  print "<html>\n";
  print "<head>\n";
  print "<meta charset='UTF-8'/>\n";
  print "<title>Invalid ID</title>\n";
  print "</head>\n";
  print "<body onload='loadData()'>\n";
  print "<script type='text/javascript'>\n";
  print "alert('Invalid ID. Please Enter Proper ID.');\n";
  print "window.close();\n";
  print "</script>\n";
  print "</body>\n";
  print "</html>";  
}