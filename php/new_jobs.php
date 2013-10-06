<?php

 $cnt = $_REQUEST['records'];
 $conn = pg_connect("dbname=tape host=192.168.1.5 user=Administrator");
 if ( ! $conn )
 {
	echo "An error occurred connecting to the database";
 }

 $bInserted = 0;
 for ( $i = 1; $i <= $cnt; $i++ )
 {
      $qtykey = "qty" . $i;
      $idkey = "id" . $i;
      $holdkey = "hold" . $i;
      $ponlykey = "ponly" . $i;
      $dvdkey = "dvd" . $i;
      $masterkey = "master" . $i;
      $pulpitkey = "pulpit" . $i;
      $qty = $_REQUEST[$qtykey];
      if ( $qty > 0 )
      {
      	$sql = "insert into jobs (tapeid,copies,remainingdiscs,status,printonly,dvd,master,pulpit)";
      	$sql .= " values (" . $_REQUEST[$idkey] . "," . $_REQUEST[$qtykey];
      	$sql .= "," . $_REQUEST[$qtykey];

      	if($_REQUEST[$holdkey] == "y" )
      	{
      	  $sql .= ",0";
      	}
      	else
      	{
      	  $sql .= ",1";
      	}


		if ($_REQUEST[$dvdkey] == "y" )
		{
		  $sql .= ",'y','y','n','n')";
		}
		else
		{
		  if ($_REQUEST[$ponlykey] == "y" )
		  {
                if ( $_REQUEST[$pulpitkey] == "y" )
                {
                  $sql .= ",'y','n','n','y')";
                }
                else
                {
		      $sql .= ",'y','n','n','n')";
                }
		  }
		  else
		  {
                    if ( $_REQUEST[$masterkey] == "y" )
                    {
                      $sql .= ",'n','n','y','n')";
                    }
                    else
                    {
                       if ( $_REQUEST[$pulpitkey] == "y" )
                       {
                         $sql .= ",'n','n','n','y')";
                       }
                       else
                       { 
		             $sql .= ",'n','n','n','n')";
                       }
                    }
		  }

		  #$sql .= ",'n')";
		}

      	pg_query($conn,$sql);
      	$bInserted = 1;
        #echo $sql;
        #echo $_REQUEST[$idkey];
      }
 }

 if ( $bInserted )
 {
 	header("Location: view_jobs.php");
 }

?>
