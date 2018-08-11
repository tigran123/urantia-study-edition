#!/bin/bash

MOD=urantia-study-edition
STYFILE=${MOD}.sty
OUT=pdf
OUTFILE=Revelation
FORMATS="tablet bigtablet 5in 7in 8in 10in A4"

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
   set_tags "afterpartnewpage papernewpage introinclude coverimage arno pgkindledx nofancydecor"
   unset_tags "beforepartnewpage noquiz pgcrownq garamond pgkobomini pgkoboaurahd pgauraone pgafour pgnexus7 pgnexus10"
}

function set_pg5in()
{
    set_tags "afterpartnewpage papernewpage introinclude coverimage arno nofancydecor pgkobomini"
    unset_tags "beforepartnewpage noquiz garamond pgcrownq pgkindledx pgkoboaurahd pgauraone pgafour pgnexus7 pgnexus10"
}

function set_pg7in()
{
    set_tags "afterpartnewpage papernewpage nofancydecor introinclude coverimage garamond pgkoboaurahd"
    unset_tags "beforepartnewpage noquiz pgcrownq pgkobomini arno pgkindledx pgafour pgnexus7 pgauraone pgnexus10"
}

function set_pg8in()
{
    set_tags "afterpartnewpage papernewpage nofancydecor introinclude coverimage garamond pgauraone"
    unset_tags "beforepartnewpage noquiz pgcrownq pgkobomini arno pgkindledx pgafour pgnexus7 pgkoboaurahd pgnexus10"
}

function set_pgtablet()
{
    set_tags "afterpartnewpage papernewpage inofancydecor ntroinclude coverimage garamond pgnexus7"
    unset_tags "beforepartnewpage noquiz pgcrownq pgkobomini pgkindledx pgkoboaurahd pgauraone pgafour pgnexus10"
}

function set_pgbigtablet()
{
    set_tags "afterpartnewpage papernewpage inofancydecor ntroinclude coverimage garamond pgnexus10"
    unset_tags "beforepartnewpage noquiz pgcrownq pgkobomini pgkindledx pgkoboaurahd pgauraone pgafour pgnexus7"
}


function set_pgA4()
{
    set_tags "afterpartnewpage papernewpage noquiz introinclude coverimage nofancydecor arno pgafour"
    unset_tags "beforepartnewpage pgcrownq pgkobomini pgkindledx garamond pgkoboaurahd pgauraone pgnexus7 pgnexus10"
}

function set_pgcrownq()
{
    set_tags "beforepartnewpage papernewpage noquiz nofancydecor garamond pgcrownq"
    unset_tags "afterpartnewpage introinclude coverimage arno pgafour pgkobomini pgkindledx pgkoboaurahd pgauraone pgnexus7 pgnexus10"
}


function build_all()
{
    local flag=$1
	local outdir=${OUT}/$flag

    for fmt in $FORMATS
    do
       set_pg${fmt}
       echo -n "$fmt: "
       make vclean
       make -s
       if [ $? -eq 0 ] ; then
         mv -f ${MOD}.pdf ${outdir}/${OUTFILE}-${fmt}.pdf
       else
          echo "ERROR: Build failed, please examine the logs"
          exit
       fi
       if [ "$flag" = "public" ] ; then
          cd ${outdir}
          zip -q ${OUTFILE}-${fmt}.pdf.zip ${OUTFILE}-${fmt}.pdf
          cd -
       fi
       echo "OK"
    done
}

rm -rf $OUT ; mkdir -p $OUT/{public,private}

set_tag pictures
unset_tags "private nofnt"
build_all public

set_tag private
build_all private
