<?php
ini_set('memory_limit','300M');

$metrics = [];

$textp = '/<p><a class="U\d{1,3}_(\d{1,2})_(\d{1,3})" href="\.U\d{1,3}_\d{1,2}_\d{1,3}"><sup>\d{1,3}:\d{1,2}\.\d{1,3}<\/sup><\/a> /u';

$headp = '/<h4><a class="U\d{1,3}_(\d{1,2})_(\d{1,3})" href=".U\d{1,3}_\d{1,2}_\d{1,3}">(.*)<\/a><\/h4>/u';

for ($i = 0; $i <= 196; $i++) {
   $filename = sprintf("1/p%03d.html", $i);
   $lines = file($filename);
   $pmetrics = [];
   $linenum = 0;
   foreach($lines as $line) {
      if (preg_match($textp, $line, $matches)) { // text line
         $pmetrics[$linenum] = [$matches[1], $matches[2], 'TEXT'];
         $linenum++;
      } elseif (preg_match($headp, $line, $matches)) { // header line
         $text = $matches[3]; 
         $countbr = substr_count($text, '<br>');
         if ($countbr == 0) {
            $pmetrics[$linenum] = [$matches[1], $matches[2], 'HEADER'];
            $linenum++;
         } elseif ($countbr == 1) {
            $pmetrics[$linenum] = [$matches[1], $matches[2], 'XHEADER'];
            $pmetrics[$linenum+1] = [$matches[1], $matches[2], 'SUBTITLE'];
            $linenum += 2;
         } elseif ($countbr == 2) {
            $pmetrics[$linenum] = [$matches[1], $matches[2], 'XHEADER'];
            $pmetrics[$linenum+1] = [$matches[1], $matches[2], 'MIDTITLE'];
            $pmetrics[$linenum+2] = [$matches[1], $matches[2], 'SUBTITLE'];
            $linenum += 3;
         } else {
            printf("TOO MANY LINE BREAKS! filename: %s, SECTION sec=%d, par=%d\n", $filename, $sec, $par); 
            exit(1);
         }
      } else {
         printf("DATA CORRUPTION! filename: %s, line=%d\n", $filename, $linenum); 
         exit(1);
      }
   }
   $metrics[$i] = $pmetrics;
}

file_put_contents("metrics.json", json_encode($metrics));
?>
