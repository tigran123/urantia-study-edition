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
	unset_tag pgkobomini
	unset_tag pgnexus7
	unset_tag pghanlin
	unset_tag pgkoboaurahd
	set_tag pgkindledx
}

function set_pghanlin()
{
	echo "Building Kindle PDF"
	unset_tag pgkobomini
	unset_tag pgkindledx
	unset_tag pgnexus7
	unset_tag pgkoboaurahd
	set_tag pghanlin
}

function set_pgkobomini()
{
	echo "Building Kobo Mini PDF"
	unset_tag pgkindledx
	unset_tag pghanlin
	unset_tag pgnexus7
	unset_tag pgkoboaurahd
	set_tag pgkobomini
}

function set_pgkoboaurahd()
{
	echo "Building Kobo Aura HD PDF"
	unset_tag pgkobomini
	unset_tag pgkindledx
	unset_tag pgnexus7
	unset_tag pghanlin
	set_tag pgkoboaurahd
}

function set_pgnexus7()
{
	echo "Building Android PDF"
	unset_tag pgkobomini
	unset_tag pgkindledx
	unset_tag pghanlin
	unset_tag pgkoboaurahd
	set_tag pgnexus7
}

function build_all()
{
	local outdir=${OUT}/$1

	set_pgkindledx
	make vclean ; make && mv -f ${MOD}.pdf ${outdir}/${MOD}-KindleDX.pdf

	set_pgnexus7
	make vclean ; make && mv -f ${MOD}.pdf ${outdir}/${MOD}-Android.pdf

	set_pghanlin
	make vclean ; make && mv -f ${MOD}.pdf ${outdir}/${MOD}-Kindle.pdf

	set_pgkoboaurahd
	make vclean ; make && mv -f ${MOD}.pdf ${outdir}/${MOD}-KoboAuraHD.pdf

	set_pgkobomini
	make vclean ; make && mv -f ${MOD}.pdf ${outdir}/${MOD}-KoboMini.pdf
}

rm -rf $OUT ; mkdir -p $OUT/{public,private}

set_tag coverimage
set_tag introinclude
set_tag fancylettrine
set_tag pictures
unset_tag nofnt
unset_tag nofancydecor

unset_tag private
build_all public

set_tag private
build_all private

unset_tag coverimage
unset_tag introinclude
unset_tag fancylettrine
unset_tag pictures
unset_tag private
set_tag nofnt
set_tag nofancydecor

make vclean ; make && mv -f ${MOD}.pdf pdf/public/${MOD}-KoboAuraHD-plain.pdf
