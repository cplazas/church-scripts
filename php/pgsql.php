<html>
  <head>
    <title>CD Search</title>
  </head>
  <body>
  	<font face="Verdana" size="4">CD Search</font><br>
    <form name="frm" method="GET" action="cd_list.php">
    <table bgcolor="#000000" cellpadding="0" cellspacing="0"><tr><td>
    <table border="0" cellpadding="4" cellspacing="1">
      <tr>
        <td bgcolor="#2244CC" align="center">
          <font face="Verdana" size="2" color="#FFFFFF"><b>Month</b></font></td>
        <td bgcolor="#FFFFFF"><select name="month"><option></option>

    	<?php
    	   $conn = pg_connect("dbname=tape host=192.168.1.5 user=Administrator");
    	   if ( $conn )
    	   {
    	     $rst = pg_query($conn, "SELECT DISTINCT \"Month\" FROM \"Tapes\" WHERE \"Month\" IS NOT NULL ORDER BY 1");
    	     while($row = pg_fetch_array($rst))
			 {
			   echo "<option value=\"" . $row['Month'] . "\">" . $row['Month'] . "</option>\n";
			 }

    	   }
    	   else
    	   {
    	     echo "An error occurred connecting to the database";
    	   }

    	?></select>
		</td>
	  </tr>
	  <tr>
	    <td bgcolor="#2244CC" align="center">
	      <font face="Verdana" size="2" color="#FFFFFF"><b>Year</b></font></td>
	    <td bgcolor="#FFFFFF"><select name="year" ><option></option>

	    <?php
	       $rst = pg_query($conn, "SELECT DISTINCT \"Year\" FROM \"Tapes\" WHERE \"Year\" IS NOT NULL ORDER BY 1 DESC");
	       while($row = pg_fetch_array($rst))
		   {
		     echo "<option value=\"" . $row['Year'] . "\">" . $row['Year'] . "</option>\n";
		   }


	    ?></select>
	    </td>
	  </tr>
	  <tr>
	    <td bgcolor="#2244CC" align="center">
	      <font face="Verdana" size="2" color="#FFFFFF"><b>Minister</b></font></td>
	    <td bgcolor="#FFFFFF"><input type="text" name="minister"></td>
	  </tr>
	  <tr>
	    <td bgcolor="#2244CC" align="center">
	      <font face="Verdana" size="2" color="#FFFFFF"><b>Sermon Title</b></font></td>
	    <td bgcolor="#FFFFFF"><input type="text" name="title"></td>
	  </tr>
	</table></td></tr></table><br>
	<input type="submit" value="search"> <input type="reset" value="reset">
    </form>
  </body>
</html>
