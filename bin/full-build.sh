#!/bin/bash

MOD=urantia-study-edition
STYFILE=${MOD}.sty
OUT=pdf
OUTFILE=Revelation

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
	unset_tag pgkoboaurahd
	set_tag pgkindledx
}

function set_pgkobomini()
{
	echo "Building Kobo Mini PDF"
	unset_tag pgkindledx
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
	set_tag pgkoboaurahd
}

function set_pgnexus7()
{
	echo "Building Android PDF"
	unset_tag pgkobomini
	unset_tag pgkindledx
	unset_tag pgkoboaurahd
	set_tag pgnexus7
}

function build_all()
{
	local outdir=${OUT}/$1

	set_pgnexus7
	make vclean ; make && mv -f ${MOD}.pdf ${outdir}/${OUTFILE}-tablet.pdf
    cd ${outdir}
    zip ${OUTFILE}-tablet.pdf.zip ${OUTFILE}-tablet.pdf
    cd -

	set_pgkindledx
	make vclean ; make && mv -f ${MOD}.pdf ${outdir}/${OUTFILE}-twocolumn.pdf
    cd ${outdir}
    zip ${OUTFILE}-twocolumn.pdf.zip ${OUTFILE}-twocolumn.pdf
    cd -

	set_pgkobomini
	make vclean ; make && mv -f ${MOD}.pdf ${outdir}/${OUTFILE}-5in.pdf
    cd ${outdir}
    zip ${OUTFILE}-5in.pdf.zip ${OUTFILE}-5in.pdf
    cd -

	set_pgkoboaurahd
	make vclean ; make && mv -f ${MOD}.pdf ${outdir}/${OUTFILE}-7in.pdf
    cd ${outdir}
    zip ${OUTFILE}-7in.pdf.zip ${OUTFILE}-7in.pdf
    cd -
}

rm -rf $OUT ; mkdir -p $OUT/{public,private}

set_tag introinclude
set_tag pictures
set_tag coverimage
unset_tag private
unset_tag nofnt
unset_tag nofancydecor
unset_tag fancylettrine

build_all public

set_tag private
build_all private
