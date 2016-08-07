#!/bin/bash

MOD=urantia-study-edition
STYFILE=${MOD}.sty
OUT=pdf
OUTFILE=Revelation
FORMATS="10in A4 tablet 5in 7in"

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

function set_tags()
{
   local list=$1

   for tag in $list
   do
      set_tag $tag
   done
}

function unset_tags()
{
   local list=$1

   for tag in $list
   do
      unset_tag $tag
   done
}

function set_pg10in()
{
   set_tags "afterpartnewpage papernewpage introinclude coverimage arno pgkindledx"
   unset_tags "beforepartnewpage noquiz nofancydecor garamond pgcrownq pgkobomini pgkoboaurahd pgafour pgnexus7"
}

function set_pg5in()
{
    set_tags "afterpartnewpage papernewpage introinclude coverimage arno pgkobomini"
    unset_tags "beforepartnewpage noquiz nofancydecor garamond pgcrownq pgkindledx pgkoboaurahd pgafour pgnexus7"
}

function set_pg7in()
{
    set_tags "afterpartnewpage papernewpage introinclude coverimage arno pgkoboaurahd"
    unset_tags "beforepartnewpage noquiz nofancydecor garamond pgcrownq pgkobomini pgkindledx pgafour pgnexus7"
}

function set_pgtablet()
{
    set_tags "afterpartnewpage papernewpage introinclude coverimage arno pgnexus7"
    unset_tags "beforepartnewpage noquiz nofancydecor garamond pgcrownq pgkobomini pgkindledx pgkoboaurahd pgafour"
}

function set_pgA4()
{
    set_tags "afterpartnewpage papernewpage noquiz introinclude coverimage nofancydecor arno pgafour"
    unset_tags "beforepartnewpage garamond pgcrownq pgkobomini pgkindledx pgkoboaurahd pgnexus7"
}

function set_pgcrownq()
{
    set_tags "beforepartnewpage papernewpage noquiz nofancydecor garamond pgcrownq"
    unset_tags "afterpartnewpage introinclude coverimage arno pgafour pgkobomini pgkindledx pgkoboaurahd pgnexus7"
}


function build_all()
{
    local flag=$1
	local outdir=${OUT}/$flag

    for fmt in $FORMATS
    do
	   set_pg${fmt}
       echo -n "$fmt: "
	   make vclean ; make -s && mv -f ${MOD}.pdf ${outdir}/${OUTFILE}-${fmt}.pdf
       if [ "$flag" = "public" ] ; then
          cd ${outdir}
          zip ${OUTFILE}-${fmt}.pdf.zip ${OUTFILE}-${fmt}.pdf
          cd -
       fi
       echo "OK"
    done
}

rm -rf $OUT ; mkdir -p $OUT/{public,private}

set_tag pictures
unset_tags "private nofnt fancylettrine"
build_all public

set_tag private
build_all private
