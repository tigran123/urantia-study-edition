#!/bin/bash

MOD=urantia-study-edition
STYFILE=${MOD}.sty

function set_doublecol()
{
	ed -s ${STYFILE} <<-EOF
	%s/\[parvs,lettrine]{ubook}/[doublecol,parvs,lettrine]{ubook}/
	wq
	EOF
}

function unset_doublecol()
{
	ed -s ${STYFILE} <<-EOF
	%s/\[doublecol,parvs,lettrine]{ubook}/[parvs,lettrine]{ubook}/
	wq
	EOF
}

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
	set_doublecol
	unset_tag pgnexus7
	unset_tag pghanlin
	set_tag pgkindledx
}

function set_pghanlin()
{
	echo "Building Kindle PDF"
	unset_doublecol
	unset_tag pgkindledx
	unset_tag pgnexus7
	set_tag pghanlin
}

function set_pgnexus7()
{
	echo "Building Android PDF"
	unset_doublecol
	unset_tag pgkindledx
	unset_tag pghanlin
	set_tag pgnexus7
}

rm -rf pdf ; mkdir pdf

set_pgkindledx
make vclean ; make && mv -f ${MOD}.pdf pdf/${MOD}-KindleDX.pdf

set_pgnexus7
make vclean ; make && mv -f ${MOD}.pdf pdf/${MOD}-Android.pdf

set_pghanlin
make vclean ; make && mv -f ${MOD}.pdf pdf/${MOD}-Kindle.pdf
