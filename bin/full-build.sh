#!/bin/bash

MOD=urantia-study-edition
STYFILE=${MOD}.sty
OUT=pdf

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

function set_pgkindledx()
{
	echo "Building Kindle DX PDF"
	unset_tag pgnexus7
	unset_tag pghanlin
	unset_tag pgkoboaurahd
	set_tag pgkindledx
}

function set_pghanlin()
{
	echo "Building Kindle PDF"
	unset_tag pgkindledx
	unset_tag pgnexus7
	unset_tag pgkoboaurahd
	set_tag pghanlin
}

function set_pgkoboaurahd()
{
	echo "Building Kobo Aura HD PDF"
	unset_tag pgkindledx
	unset_tag pgnexus7
	unset_tag pghanlin
	set_tag pgkoboaurahd
}

function set_pgnexus7()
{
	echo "Building Android PDF"
	unset_tag pgkindledx
	unset_tag pghanlin
	unset_tag pgkoboaurahd
	set_tag pgnexus7
}

rm -rf $OUT ; mkdir $OUT

set_pgkindledx
make vclean ; make && mv -f ${MOD}.pdf ${OUT}/${MOD}-KindleDX.pdf

set_pgnexus7
make vclean ; make && mv -f ${MOD}.pdf ${OUT}/${MOD}-Android.pdf

set_pghanlin
make vclean ; make && mv -f ${MOD}.pdf ${OUT}/${MOD}-Kindle.pdf

set_pgkoboaurahd
make vclean ; make && mv -f ${MOD}.pdf ${OUT}/${MOD}-KoboAuraHD.pdf

make vclean
