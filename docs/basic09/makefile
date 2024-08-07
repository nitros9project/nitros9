BOOK		= basic09
STYLESHEET	= ../../../../xslt10-stylesheets/xsl/html/docbook.xsl
STYLESHEET2	= ../../../../xslt10-stylesheets/xsl/html/docbook.xsl

all: $(BOOK).pdf

$(BOOK).pdf: $(BOOK).docbook $(STYLESHEET)
	xsltproc $(STYLESHEET) $(BOOK).docbook

$(BOOK).ps: $(BOOK).docbook $(STYLESHEET)
	xsltproc $(STYLESHEET) $(BOOK).docbook

$(BOOK).md: $(BOOK).docbook $(STYLESHEET)
	xsltproc $(STYLESHEET) $(BOOK).docbook | pandoc --verbose --from docbook --to markdown --css $(STYLESHEET2) --output $@

$(BOOK).html: $(BOOK).docbook $(STYLESHEET)
	xsltproc $(STYLESHEET) $(BOOK).docbook | pandoc --verbose --from docbook --to html --css $(STYLESHEET2) --output $@
#	xsltproc $(STYLESHEET) $(BOOK).docbook
#	jade -t sgml -V html-index -d /usr/share/sgml/docbook/dsssl-stylesheets-1.64/html/docbook.dsl $(BOOK).docbook
#	collateindex.pl -p -o index.docbook HTML.index
#	docbook2html -d $(STYLESHEET)#html $(BOOK).docbook

print:
	psnup -2 $(BOOK).ps | lpr

clean:
	$(RM) *.md *.html $(BOOK).pdf $(BOOK).ps
