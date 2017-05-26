<?php
ini_set('memory_limit','300M');
$metrics = [];
$textpp = '/<p><a class="U\d{1,3}_(\d{1,2})_(\d{1,3})" href="\.U\d{1,3}_\d{1,2}_\d{1,3}"><sup>\d{1,3}:\d{1,2}\.\d{1,3}<\/sup><\/a> §§ /u';
$textp = '/<p><a class="U\d{1,3}_(\d{1,2})_(\d{1,3})" href="\.U\d{1,3}_\d{1,2}_\d{1,3}"><sup>\d{1,3}:\d{1,2}\.\d{1,3}<\/sup><\/a> /u';
$headp = '/<h4><a class="U\d{1,3}_(\d{1,2})_(\d{1,3})" href=".U\d{1,3}_\d{1,2}_\d{1,3}">.*<\/a><\/h4>/u';

for ($i = 0; $i <= 196; $i++) {
   $filename = sprintf("1/p%03d.html", $i);
   $lines = file($filename);
   $pmetrics = [];
   foreach($lines as $linenum => $line) {
      if (preg_match($textpp, $line, $matches)) { // text line with paragraph cluster sign
         $type = 'TEXTP';
      } elseif (preg_match($textp, $line, $matches)) { // text line
         $type = 'TEXT';
      } elseif (preg_match($headp, $line, $matches)) { // header line
         $type = 'HEADER';
      } else {
         printf("DATA CORRUPTION! filename: %s, line=%d\n", $filename, $linenum); 
         exit(1);
      }
      $pmetrics[$linenum] = [$matches[1], $matches[2], $type];
   }
   $metrics[$i] = $pmetrics;
}

file_put_contents("metrics-short.json", json_encode($metrics));
?>
