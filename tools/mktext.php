<?php
ini_set('memory_limit','300M');

system("rm -rf 1 ; mkdir 1");

$notelines = [];
$nfilename = "1/notes.html";

for ($i = 0; $i <= 196; $i++) {
   $ifilename = sprintf("tex/p%03d.tex", $i);
   $ofilename = sprintf("1/p%03d.html", $i);
   $ilines = file($ifilename);
   $olines = [];
   $nlines = [];
   foreach($ilines as $iline) {
      if (preg_match('/^\\\\vs p\d* (\d{1,2}):(\d{1,3}) (.*)$/u', $iline, $matches)) { // text line
         $chap = $matches[1];
         $verse = $matches[2];
         $text = convert_text($matches[3]);
         $fn_total = preg_match_all('/\\\\fn[cs]t?{([^}]*)}/u', $text, $fnotes);
         for ($fn = 0; $fn < $fn_total; $fn++) {
             $nlines[] = '<p><a name="U'.$i.'_'.$chap.'_'.$verse.'_'.$fn.'" href=".U'.$i.'_'.$chap.'_'.$verse.'"><sup>'.$i.':'.$chap.'.'.$verse.'['.$fn.']</sup></a> '.$fnotes[1][$fn].PHP_EOL;
             $text = preg_replace('/\\\\fn[cs]t?{([^}]*)}/u', '<a href="U'.$i.'_'.$chap.'_'.$verse.'_'.$fn.'"><sup>'.$fn.'</sup></a>', $text, 1);
         }
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
   file_put_contents($nfilename, $nlines, FILE_APPEND);
}

function convert_section($text) {
   $search = ['/\\\\bibnobreakspace/u', '/\\\\\\\\/u', '/\\\hyp{}/u', '/---/u'];
   $replace = ['', ' ', '-', '—'];
   return preg_replace($search, $replace, $text);
}

function convert_text($text) {
   $search = ['/\\\\pc /u',
              '/\\\\bibnobreakspace/u',
              '/ *\\\\times /u',
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
              '/~/u',
              '/ *\\\\pm\\\\* */u',
              '/\\\\%/u',
              '/\\\\bibfrac{(\d+)}{(\d+)}/u',
              '/\\\\ldots\\\\/u',
              '/\\\\tau/u',
              '/\\\\mu/u',
              '/\\\\ldots{}/u',
              '/\\\\textsc{([^}]*)}/u',
              '/\^{?(\d+)}?/u',
              '/\_({?\d+}?)/u',
              '/\\\\bibref\[([^]]*)\]{p0*(\d{1,3}) (\d{1,2}):(\d{1,3})}/u',
              '/\\\\(?:bibemph|textit|bibexpl){([^}]*)}/u',
              '/\\\\(?:mathbf|textbf|bibtextul){([^}]*)}/u',
              '/\\\\ts{([^}]*)}/u',
              '/\\\\(?:ublistelem|textgreek|textcolour{ubdarkred}){([^}]*)}/u'];
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
               ' ',
               '±',
               '%',
               '$1/$2',
               '...',
               'τ',
               'μ',
               '...',
               '<span class="sc">$1</span>',
               '<sup>$1</sup>',
               '<sub>$1</sub>',
               '<a href=".U$2_$3_$4">$1</a>',
               '<em>$1</em>',
               '<b>$1</b>',
               '<sup>$1</sup>',
               '$1'];

   $stage1 =  preg_replace($search, $replace, $text);

   return preg_replace_callback('/\\\\textheb{([^}]*)}/u', // reverse Hebrew for RTL
             function($match) {return implode(array_reverse(explode(" ",$match[1]))," ");},
             $stage1);
}
?>
