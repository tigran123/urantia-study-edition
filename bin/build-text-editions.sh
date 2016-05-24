#!/bin/bash

MOD=urantia-study-edition
STYFILE=${MOD}.sty
OUT=pdf/text-edition

function set_tag()
{
    local tag=$1
	ed -s ${STYFILE} <<-EOF
	%s/^%\\\tunemarkuptag{${tag}}/\\\tunemarkuptag{${tag}}/
	wq
	EOF
}

function unset_tag()
{
    local tag=$1
	ed -s ${STYFILE} <<-EOF
	%s/^\\\tunemarkuptag{${tag}}/%\\\tunemarkuptag{${tag}}/
	wq
	EOF
}

function set_pgkoboaurahd()
{
	echo -n "Building Kobo Aura HD PDFs: "
	unset_tag pgkobomini
	unset_tag pgkindledx
	unset_tag pgnexus7
	unset_tag pghanlin
	unset_tag pgcrownq
	unset_tag pgafour
	set_tag pgkoboaurahd
}

rm -rf $OUT ; mkdir -p $OUT

unset_tag private
unset_tag introinclude
unset_tag fancylettrine
unset_tag coverimage
set_tag nofancydecor
unset_tag pictures
set_tag nofnt
set_tag noquiz
set_pgkoboaurahd

fontlist="garamond goudy minionpro academy palatino oldstandard gentium bookman arno century cambria agora newton fedra cent adamant swift charter maiola"
for font in $fontlist
do
  unset_tag $font
done

for font in $fontlist
do
   set_tag $font
   make vclean ; make && mv -f ${MOD}.pdf ${OUT}/Revelation-Text-7in-${font}.pdf
   unset_tag $font
   echo -n "$font"
done
