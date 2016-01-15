#
# Makefile for the Russian Synodal Bible.
# By default we make the PDF version of the whole Bible at top quality.
# make DRAFT=1 to make a draft (no bookmarks, rough margins and headings).
# make LIST="Gen Exo" to make only selected books.
# The above variables can be combined.
#

MOD = russian-synodal-bible

LATEX = xelatex -halt-on-error $(MOD) < /dev/null > /dev/null 2>&1

BOOKS = Gen Exo Lev Num Deu Jos Jdg Rut 1Sa 2Sa 1Ki 2Ki 1Ch 2Ch \
	Ezr Neh 2Ez Tob Jdt Est Job Psa Pro Ecc Sol Wis Sir Isa \
	Jer Lam Epj Bar Eze Dan Hos Joe Amo Oba Jon Mic Nah Hab \
	Zep Hag Zec Mal 1Ma 2Ma 3Ma 3Ez Mat Mar Luk Joh Act Jam \
	1Pe 2Pe 1Jo 2Jo 3Jo Jud Rom 1Co 2Co Gal Eph Phi Col 1Th \
	2Th 1Ti 2Ti Tit Phm Heb Rev

MISCFILES = tex/title.tex tex/ntpage.tex tex/intro.tex tex/nt-events.tex tex/nt-money.tex

ifdef LIST
	TEXFILES = $(MISCFILES) \
		   $(shell echo $(LIST) | sed "s/\([^ ][^ ]*\)/tex\/\1.tex/g")
	SUBSET=yes
else
	LIST = $(BOOKS)
	TEXFILES = $(wildcard tex/*.tex)
	SUBSET=no
endif

all::		$(MOD).pdf

.PHONY:		clean

clean::		
		@rm -rf $(MOD)-{1,2}.pdf $(MOD).{voc,1,2,idx,ind,ilg,txt,out,aux,synctex,bibtoc,toc,words,fwnp,marnin,marnout,fnvar,fnchk} *.log select-book.tex tex/*.aux

vclean:		clean
		@rm -f $(MOD).pdf

$(MOD).pdf:	tex $(MOD).tex select-book.tex $(TEXFILES)
		$(LATEX)
ifndef DRAFT
		mv $(MOD).pdf $(MOD)-1.pdf
		$(LATEX)
		mv $(MOD).pdf $(MOD)-2.pdf
		if test -s $(MOD).out; then sort -t% -k2,2n $(MOD).out > $(MOD).out.tmp && mv $(MOD).out.tmp $(MOD).out; fi
		$(LATEX)
		if test -s $(MOD).fnchk; then ../utils/fnchk.pl < $(MOD).fnchk; fi
endif

tex:	
	@mkdir -p tex

select-book.tex:	
ifeq ($(SUBSET),yes)
	$(shell export LINE="\includeonly{" ; \
		for b in $(LIST) ; do \
			LINE="$${LINE}tex/$${b}," ; \
		done ; \
		echo $${LINE}} | sed "s/,}/}/" > select-book.tex \
	)
else
	> select-book.tex
endif
