<html>
  <head>
    <title>CD Search Results</title>
  </head>
  <body>
    <font face="Verdana" size="4">CD Search Results</font><br>

    <?php

	 $all = TRUE;
	 $sql = "SELECT * FROM \"Tapes\"";
	 $filter = "";
     if ( $_GET['month'] != "" )
     {
     	$filter .= "\"Month\" = " . "'" . $_GET['month'] . "'" ;
     	$all = FALSE;
     }

     if ( $_GET['year'] != "" )
     {
     	if ( $filter != "" )
     	{
     		$filter .= " AND ";
     	}
     	$filter .= "\"Year\" = " . "'" . $_GET['year'] . "'";
     	$all = FALSE;

     }

     if ( $_GET['minister'] != "" )
     {
		if ( $filter != "" )
		{
			$filter .= " AND ";
		}
     	$filter .= "lower(\"Minister\") like " . "lower('%" . $_GET['minister'] . "%')";
     	$all = FALSE;

     }

     if ( $_GET['title'] != "" )
     {
		if ( $filter != "" )
		{
			$filter .= " AND ";
		}
     	$filter .= "lower(\"Sermon Title\") like " . "lower('%" . $_GET['title'] . "%')";
     	$all = FALSE;

     }

     if ( ! $all )
     {
     	$sql.= " WHERE " . $filter;
     }

	 $sql .= " ORDER BY \"Year\",\"Month\",\"Date\",\"Day\",\"Service#\"";
     $conn = pg_connect("dbname=tape host=192.168.1.5 user=Administrator");
	   if ( $conn )
	   {
		 $rst = pg_query($conn, $sql);

		 if ( pg_num_rows($rst) > 0 )
		 {
		 ?>
		  <form name="frm" action="new_jobs.php" method="POST">
		  <table border="0" cellpadding="6" cellspacing="1" bgcolor=#000000>
		  <tr>
		    <td bgcolor="#00CC00" align="center"><strong>Date</strong></td>
		  	<td bgcolor="#00CC00" align="center"><strong>Title</strong></td>
		  	<td bgcolor="#00CC00" align="center"><strong>Minister</strong></td>
		  	<td bgcolor="#00CC00" align="center"><strong>Copies</strong></td>
		  	<td bgcolor="#00CC00" align="center"><strong>Hold</strong></td>
		  	<td bgcolor="#00CC00" align="center"><strong>Print Only</strong></td>
		  	<td bgcolor="#00CC00" align="center"><strong>DVD</strong></td>
		  	<td bgcolor="#00CC00" align="center"><strong>Master</strong></td>
                  <td bgcolor="#00CC00" align="center"><strong>Pastor's<br>Pulpit</strong></td>
		  </tr>
		 <?php
		   $counter = 0;
		   while($row = pg_fetch_array($rst))
		   {
		     $counter++;
			 if ( ( $counter % 2 ) == 0 )
			 {
			   $color = "bgcolor=#CCCCCC";
			 }
			 else
			 {
			   $color = "bgcolor=#FFFFFF";
		     }
		     echo "<tr><td " . $color. ">" . $row['Month'] . "-" . $row['Date'] . "-" . $row['Year'] . " " . $row['Day'] . "</td>";
		     echo "<td " . $color. ">" . $row['Sermon Title'] . "</td>";
		     echo "<td " . $color. ">" . $row['Minister'] . "</td>";
		     echo "<td " . $color. " align=\"center\"><input type=\"text\" size=\"2\" value=\"0\" name=\"qty" . $counter . "\">";
		     echo "<input type=\"hidden\" name=\"id" . $counter . "\" value=\"" . $row['ID'] . "\"></td>";
		     echo "<td " . $color. " align=\"center\"><input type=\"checkbox\" name=\"hold" . $counter . "\" value=\"y\">";
		     echo "<td " . $color. " align=\"center\"><input type=\"checkbox\" name=\"ponly" . $counter . "\" value=\"y\">";
		     echo "<td " . $color. " align=\"center\"><input type=\"checkbox\" name=\"dvd" . $counter . "\" value=\"y\">";
		     echo "<td " . $color. " align=\"center\"><input type=\"checkbox\" name=\"master" . $counter . "\" value=\"y\">";
                 echo "<td " . $color. " align=\"center\"><input type=\"checkbox\" name=\"pulpit" . $counter . "\" value=\"y\">";
		     echo "</tr>";

		   } ?>

		  </table>
		  <?php echo "<input type=\"hidden\" name=\"records\" value=\"" . $counter . "\">"; ?>
          <br><input type="submit" value="submit"><input type="reset" value="reset">
		  </form>
		 <?php } else { ?> <br>No records found.<br>
		 <?php }

	   }
	   else
	   {
		 echo "An error occurred connecting to the database";
	   }


    ?>

    </body>
</html>
