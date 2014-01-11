#!/bin/bash

#for ((i=31; i<=31; i++));
for ((i=0; i<=196; i++));
do
   I=$(printf "%03d" $i)
   author=$(sed -ne "s%^.upapertitle{$i}{.*}{\(.*\)}{p$i}$%\1%p" tex/paper-titles.tex | sed -e "s/}//g")
   auth=$(sed -ne "s%^.author{\(.*\)}$%\1%p" tex/p${I}.tex)
   if [ "$author" != "$auth" ] ; then
      echo "Author mismatch in Paper $i!"
      echo "auth=\"$auth\""
      echo "author=\"$author\""
   fi
done
