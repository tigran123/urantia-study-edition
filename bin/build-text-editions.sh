#!/bin/bash

MOD=urantia-study-edition
STYFILE=${MOD}.sty
OUT=pdf/text-edition

function set_tag()
{
    local tag=$1
	ed -s ${STYFILE} <<-EOF > /dev/null 2>&1
	%s/^%\\\tunemarkuptag{${tag}}/\\\tunemarkuptag{${tag}}/
	wq
	EOF
}

function unset_tag()
{
    local tag=$1
	ed -s ${STYFILE} <<-EOF > /dev/null 2>&1
	%s/^\\\tunemarkuptag{${tag}}/%\\\tunemarkuptag{${tag}}/
	wq
	EOF
}

function set_pgkoboaurahd()
{
	echo -n "Building Kobo Aura HD PDF: "
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

declare -a fontlabels=("garamond"    "goudy" "minionpro" "academy" "palatino" "oldstandard" "gentium"          "bookman" "arno"    "century"           "cambria" "agora"    "fedra" "cent"   "adamant" "swift" "charter"    "maiola")
declare -a fontnames=( "GaramondPro" "Goudy" "MinionPro" "Academy" "Palatino" "OldStandard" "GentiumBookBasic" "Bookman" "ArnoPro" "CenturySchoolBook" "Cambria" "AgoraPro" "Fedra" "21Cent" "Adamant" "Swift" "CharterITC" "MaiolaPro")

declare -i nfonts=${#fontlabels[@]}

for ((i=0; i<$nfonts; i++))
do
  unset_tag ${fontlabels[$i]}
done

for ((i=0; i<$nfonts; i++))
do
   set_tag ${fontlabels[$i]}
   make vclean ; make -s && mv -f ${MOD}.pdf ${OUT}/Revelation-Text-7in-${fontnames[$i]}.pdf
   echo -n "${fontnames[$i]} "
   unset_tag ${fontlabels[$i]}
done
echo
