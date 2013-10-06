<?php

$conn = pg_connect("dbname=tape host=192.168.1.5 user=Administrator");
if ( ! $conn )
{
	echo "An error occurred connecting to the database";
}

if ( $_REQUEST['releasejob'] != "" )
{
	$sql = "update jobs set status = 1 where id = " . $_REQUEST['releasejob'];
	pg_query($conn,$sql);
}

if ( $_REQUEST['deletejob'] != "" )
{
	$sql = "delete from jobs where id = " . $_REQUEST['deletejob'];
	pg_query($conn,$sql);
}

?>
<html>
  <head>
    <title>Current Pending And Active Jobs</title>
  </head>
  <body>

	 <table border="0" cellpadding="6" cellspacing="1" bgcolor=#000000>
	 <tr><td colspan="9" bgcolor="#0099CC" align=center><font face="Verdana" size="4"><strong>Jobs On Hold</strong></font></td></tr>
	 <tr>
		<td bgcolor="#00CCCC" align="center"><strong>Date</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Title</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Minister</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Copies</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Create<br>Time</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Last<br>Update</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Print<br>Only</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>&nbsp;</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>&nbsp;</strong></td>
	 </tr>

	<?php

	 	$sql = "select a.\"Month\" || '-' || a.\"Date\" || '-' || a.\"Year\" || '  ' || a.\"Day\" as date, ";
	 	$sql .= "a.\"Sermon Title\", a.\"Minister\", b.copies, to_char(b.createtime,'MM/DD/YY HH24:MI') as createtime, ";
	 	$sql .= "to_char(b.lastupdate,'MM/DD/YY HH24:MI') as lastupdate, upper(b.printonly) || case b.dvd when 'y' then ' (DVD)' else case b.master when 'y' then ' (Master)' else case b.pulpit when 'y' then ' (Pastor''s Pulpit)' else '' end end end as printonly, b.id";
	 	$sql .= " from \"Tapes\" a inner join jobs b on  (a.\"ID\" = b.tapeid) where b.status = 0 ";

		$rst = pg_query($conn, $sql);

		if ( pg_num_rows($rst) > 0 )
		{
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

		    echo "<tr>";
		    echo "<td " . $color. ">" . $row['date']. "</td>";
		    echo "<td " . $color. ">" . $row['Sermon Title'] . "</td>";
		    echo "<td " . $color. ">" . $row['Minister'] . "</td>";
		    echo "<td " . $color. " align=center >" . $row['copies'] . "</td>";
		    echo "<td " . $color. ">" . $row['createtime'] . "</td>";
		    echo "<td " . $color. ">" . $row['lastupdate'] . "</td>";
		    echo "<td " . $color. " align=center >" . $row['printonly'] . "</td>";
		    echo "<form action=\"view_jobs.php\" method = \"POST\"><input type=hidden name=releasejob value=" . $row['id'] . " ><td " . $color. "><input type=submit value=Release></td></form>";
			echo "<form action=\"view_jobs.php\" method = \"POST\"><input type=hidden name=deletejob value=" . $row['id'] . " ><td " . $color. "><input type=submit value=Delete></td></form>";
		    echo "</tr>";

		  }
		}
		else
		{
			echo "<tr><td bgcolor=#FFFFFF colspan=9>No jobs are currently on hold.</td></tr>";
		}
	?>
	</table>
	<br><br><br>

	 <table border="0" cellpadding="6" cellspacing="1" bgcolor=#000000>
	 <tr><td colspan="11" bgcolor="#0099CC" align=center><font face="Verdana" size="4"><strong>Active Jobs</strong></font></td></tr>
	 <tr>
		<td bgcolor="#00CCCC" align="center"><strong>Date</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Title</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Minister</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Copies</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Good<br.Discs</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Bad<br>Discs</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Remaining<br>Discs</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Create<br>Time</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Last<br>Update</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Print<br>Only</strong></td>
		<td bgcolor="#00CCCC" align="center"><strong>Status</strong></td>
	 </tr>

	<?php

	 	$sql = "select a.\"Month\" || '-' || a.\"Date\" || '-' || a.\"Year\" || '  ' || a.\"Day\" as date, ";
	 	$sql .= "a.\"Sermon Title\", a.\"Minister\", b.copies, b.gooddiscs, b.baddiscs, b.remainingdiscs, ";
	 	$sql .= " to_char(b.createtime,'MM/DD/YY HH24:MI') as createtime, ";
	 	$sql .= "to_char(b.lastupdate,'MM/DD/YY HH24:MI') as lastupdate, upper(b.printonly)|| case b.dvd when 'y' then ' (DVD)' else case b.master when 'y' then ' (Master)' else case b.pulpit when 'y' then ' (Pastor''s Pulpit)' else '' end end  end  as printonly, b.status";
	 	$sql .= " from \"Tapes\" a inner join jobs b on  (a.\"ID\" = b.tapeid) where b.status > 0 and b.lastupdate > (now() - interval '2 week') order by b.status ";

		$rst = pg_query($conn, $sql);

		if ( pg_num_rows($rst) > 0 )
		{
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

		    echo "<tr><td " . $color. ">" . $row['date']. "</td>";
		    echo "<td " . $color. ">" . $row['Sermon Title'] . "</td>";
		    echo "<td " . $color. ">" . $row['Minister'] . "</td>";
		    echo "<td " . $color. " align=center >" . $row['copies'] . "</td>";
		    echo "<td " . $color. " align=center >" . $row['gooddiscs'] . "</td>";
		    echo "<td " . $color. " align=center >" . $row['baddiscs'] . "</td>";
		    echo "<td " . $color. " align=center >" . $row['remainingdiscs'] . "</td>";
		    echo "<td " . $color. ">" . $row['createtime'] . "</td>";
		    echo "<td " . $color. ">" . $row['lastupdate'] . "</td>";
		    echo "<td " . $color. " align=center >" . $row['printonly'] . "</td>";
		    echo "<td ";
		    switch ($row['status'])
		    {
		    	case 1:
		    		echo "bgcolor=#FFFFCC align=center>SUBMITTED</td></tr>";
		    		break;
		    	case 2:
		    		echo "bgcolor=#FFFF33 align=center>RECEIVED</td></tr>";
		    		break;
		    	case 3:
		    		echo "bgcolor=#99FF99 align=center>PROCESSING</td></tr>";
		    		break;
		    	case 4:
		    		echo "bgcolor=#00FF00 align=center>COMPLETED</td></tr>";
		    		break;
		    	case 5:
		    		echo "bgcolor=#FF0000 align=center>FAILED</td></tr>";
		    		break;
		    }

		  }
		}
		else
		{
			echo "<tr><td bgcolor=#FFFFFF colspan=11>No jobs are currently active.</td></tr>";
		}
	?>




    </body>
</html>
