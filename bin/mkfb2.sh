#!/bin/bash

#
# Convert bible-study/tex/p???.tex TeX sources to FB2 format
#

function generic_conv()
{
   sed -e "s%---%—%g" -e "s%\\\hyp{}%-%g" -e "s%\\\bibnobreakspace%%g" -e "s%\\\bibemph{\([^}]*\)}%<emphasis>\1</emphasis>%g"
}

TEXDIR=tex
OUTDIR=out

rm -rf $OUTDIR ; mkdir -p $OUTDIR

FILELIST=$(echo tex/p???.tex)
#FILELIST=tex/p066.tex
for file in $FILELIST
do
   base=$(basename $file | cut -d'.' -f1)
   while read -r line
   do
      if echo "$line" | grep -qE "^.usection{"
      then
        echo $line | generic_conv | tr '[:lower:]' '[:upper:]' | sed -e "s%.USECTION{\(.*\)}$%   </section>\n   <section><title><p>\1</p></title>%" >> ${OUTDIR}/${base}.fb2
      else
        echo "$line" | generic_conv | \
        sed -e "s%^\\\vs p0*\([0-9][0-9]*\) \([0-9][0-9]*\):\([0-9][0-9]*\) \(.*\)$%     <p><sup>\1:\2.\3</sup> \4</p>%" \
            -e "s% \\\pc % ¶ %g" \
            -e "s%\^\([0-9][0-9]*\)%<sup>\1</sup>%g" \
            -e "s%\\$%%g" \
            -e "s%--%-%g" \
            -e "s%\\\ldots\\\%...%g" \
            -e "s/\\\%\\\/\%/g" \
            -e "s%\\\vsetoff%     <empty-line/>%g" \
            -e "s% *\\\times *%·%g" \
            -e "s%^\\\upaper{\([0-9][0-9]*\)}{\(.*\)}$%   <section>\n    <title>\n     <p>PAPER № \1</p>\n     <p>\2</p>\n    </title>%g" \
            -e "s%^\\\author{\([^}]*\)}%   <annotation><p>\1</p></annotation>\n   <section>%g" \
            -e "s%\\\bibref\[\([^}]*\)\]{[^}]*}%\1%g" \
            -e "s%\\\textsc{\([^}]*\)}%\1%g" \
            -e "s%\\\textheb{\([^}]*\)}%\1%g" \
            -e "s%\\\textgreek{\([^}]*\)}%\1%g" \
            -e "s%\\\ts{\([^}]*\)}%<sup>\1</sup>%g" \
            -e "s%\\\ublistelem{\([^}]*\)}%\1%g" \
            -e "s%\\\textcolour{ubdarkred}{\([^}]*\)}%\1%g" \
            -e "s%\\\textbf{\([^}]*\)}%<strong>\1</strong>%g" \
            -e "s%\\\textit{\([^}]*\)}%<emphasis>\1</emphasis>%g" \
            -e "s%\`\`%“%g" -e "s%''%”%g" >> ${OUTDIR}/${base}.fb2
      fi
   done < $file
   echo -e "   </section>\n  </section>" >> ${OUTDIR}/${base}.fb2
done
