<?php
ini_set('memory_limit','300M');

system("rm -rf 1 ; mkdir 1");

$toclines = [];

for ($i = 0; $i <= 196; $i++) {
   $ifilename = sprintf("tex/p%03d.tex", $i);
   $ofilename = sprintf("1/p%03d.html", $i);
   $ilines = file($ifilename);
   $olines = [];
   foreach($ilines as $iline) {
      if (preg_match('/^\\\\vs p\d* (\d{1,2}):(\d{1,3}) (.*)$/u', $iline, $matches)) { // text line
         $chap = $matches[1];
         $verse = $matches[2];
         $text = convert_text($matches[3]);
         $fn = preg_match('/\\\\fn[cs]t?{([^}]*)}/u', $text, $fnotes);
         $olines[] = '<p><a class="U'.$i.'_'.$chap.'_'.$verse.'" href=".U'.$i.'_'.$chap.'_'.$verse.'">' .
                          '<sup>'.$i.':'.$chap.'.'.$verse.'</sup></a> ' .  $text . PHP_EOL;
      } elseif (preg_match('/^\\\\author{(.*)}/u', $iline, $matches)) { // Extract author
         $author = $matches[1];
      } elseif (preg_match('/^\\\\upaper{\d+}{(.*)}/u', $iline, $matches)) { // Extract paper title
         $paper = $matches[1];
      } elseif (preg_match('/^\\\\usection{(.*)}/u', $iline, $matches)) { // Extract section title
         $section = convert_section($matches[1]);
         if ($i == 0 && $chap == 12) { // Acknowledgment "section" in the Foreword
            $verse = 10;
            $section = '<em>'.$section.'</em>';
         } else {
            $chap++;
            $verse = 0;
         }
         $olines[] = '<h4><a class="U'.$i.'_'.$chap.'_'.$verse.'" href=".U'.$i.'_'.$chap.'_'.$verse.'">'.$section.'</a></h4>'.PHP_EOL;
      }
   }
   file_put_contents($ofilename, $olines);
}

function convert_section($text) {
   $search = ['/\\\\bibnobreakspace/u', '/\\\\\\\\/u', '/\\\hyp{}/u', '/---/u'];
   $replace = ['', ' ', '-', '—'];
   return preg_replace($search, $replace, $text);
}

function convert_text($text) {
   $search = ['/\\\\pc /u',
              '/\\\\bibnobreakspace/u',
              '/\\\\times /u',
              '/\$/u',
              '/\\\\hyp{}/u',
              '/\\\\\'(.)/u',
              '/---/u',
              '/--/u',
              '/``/u',
              '/`/u',
              '/\'\'/u',
              '/\'/u',
              '/\\\\,/u',
              '/\\\\ldots\\\\/u',
              '/\\\\ldots{}/u',
              '/\\\\bibref\[([^]]*)\]{p0*(\d{1,3}) (\d{1,2}):(\d{1,3})}/u',
              '/\\\\(?:bibemph|textit|bibexpl){([^}]*)}/u',
              '/\\\\(?:textbf|bibtextul){([^}]*)}/u',
              '/\\\\ts{([^}]*)}/u',
              '/\\\\(?:ublistelem|textheb|textgreek|textcolour{ubdarkred}){([^}]*)}/u',
              '/\\\\fn[cs]t?{([^}]*)}/u',
              '/\\\\tunemarkup{(?:private|pictures)}{.*}/u'];
   $replace = ['¶ ',
               '',
               '×',
               '',
               '-',
               '<b>$1</b>',
               '—',
               '–',
               '“',
               '‘',
               '”',
               '’',
               ' ',
               '...',
               '...',
               '<a href=".U$2_$3_$4">$1</a>',
               '<em>$1</em>',
               '<b>$1</b>',
               '<sup>$1</sup>',
               '$1',
               '<a href="notes.html">*</a>',
               '<a href="notes.html">*</a>'];
   return preg_replace($search, $replace, $text);
}
?>
