MOD = urantia-study-edition
WORKDIR = $(TMPDIR)/$(MOD)
LATEX = xelatex -output-directory=$(WORKDIR) -halt-on-error $(MOD) < /dev/null > /dev/null 2>&1

all::		$(MOD).pdf

.PHONY:		clean

clean::		
		@rm -rf $(WORKDIR) select-book.tex missfont.log $(MOD).pdf

$(MOD).pdf:	select-book.tex
		@mkdir -p $(WORKDIR)
		$(LATEX)
ifndef DRAFT
		$(LATEX)
		$(LATEX)
		@if test -s $(WORKDIR)/$(MOD).fnchk; then perl bin/fnchk.pl < $(WORKDIR)/$(MOD).fnchk; fi
endif
		@mv $(WORKDIR)/$(MOD).pdf .

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
