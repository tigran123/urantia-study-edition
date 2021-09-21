MOD = urantia-study-edition
SHELL = /bin/bash
LATEX = xelatex -halt-on-error $(MOD) < /dev/null > /dev/null 2>&1

all::		$(MOD).pdf

.PHONY:		clean

clean::		
		@rm -f $(MOD)*.{aux,bibtoc,fnchk,idx,ilg,ind,lof,log,out,pdf} select-book.tex missfont.log

$(MOD).pdf:	select-book.tex
		$(LATEX)
		@mv $(MOD).pdf $(MOD)-1.pdf
ifndef DRAFT
		$(LATEX)
		@mv $(MOD).pdf $(MOD)-2.pdf
		$(LATEX)
		@if test -s $(MOD).fnchk; then perl bin/fnchk.pl < $(MOD).fnchk; fi
endif

select-book.tex:	
ifdef LIST
	$(shell export LINE="\includeonly{" ; \
		for b in $(LIST) ; do \
			LINE="$${LINE}tex/$${b}," ; \
		done ; \
		echo $${LINE}} | sed "s/,}/}/" > select-book.tex \
	)
else
	> select-book.tex
endif
