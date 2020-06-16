FONTBASES = Teletext50 Teletext50-extended Teletext50-semicondensed \
            Teletext50-condensed Teletext50-extracondensed Teletext50-ultracondensed

SFDFILES = $(addsuffix .sfd, $(FONTBASES))
TTFFILES = $(addsuffix .ttf, $(FONTBASES))

DISTFILES = bedstead.c Makefile COPYING NEWS \
	$(TTFFILES) \
	Teletext50-10.bdf Teletext50-20.bdf \
	Teletext50-10-df.png Teletext50-20-df.png \
	Teletext50-complement.pdf

all: $(DISTFILES) \
     sample-white-text.png \
     sample-black-text.png

.PHONY: experimental
experimental: Teletext50-chiseltip.ttf Teletext50-plotter-thin.ttf \
 Teletext50-plotter-light.ttf Teletext50-plotter-medium.ttf \
 Teletext50-plotter-bold.ttf plotter.png

Teletext50.sfd: bedstead
	./bedstead > Teletext50.sfd

Teletext50-extended.sfd: bedstead
	./bedstead --extended > Teletext50-extended.sfd

Teletext50-semicondensed.sfd: bedstead
	./bedstead --semi-condensed > Teletext50-semicondensed.sfd

Teletext50-condensed.sfd: bedstead
	./bedstead --condensed > Teletext50-condensed.sfd

Teletext50-extracondensed.sfd: bedstead
	./bedstead --extra-condensed > Teletext50-extracondensed.sfd

Teletext50-ultracondensed.sfd: bedstead
	./bedstead --ultra-condensed > Teletext50-ultracondensed.sfd

Teletext50-oc.sfd: bedstead
	./bedstead --plotter > Teletext50-oc.sfd

Teletext50-plotter-%.sfd: strokefont.py Teletext50-oc.sfd
	fontforge -lang=py -script strokefont.py plotter-$* Teletext50-oc.sfd \
		Teletext50-plotter-$*.sfd

Teletext50-chiseltip.sfd: strokefont.py Teletext50-oc.sfd
	fontforge -lang=py -script strokefont.py chiseltip Teletext50-oc.sfd \
		Teletext50-chiseltip.sfd

%-10.bdf %-20.bdf: %.sfd
	fontforge -lang=ff \
	    -c 'Open($$1); BitmapsAvail([10, 20]); Generate($$2, "bdf")' \
	    $< $*.

%.ttf: %.sfd
	fontforge -lang=ff \
	    -c 'Open($$1); Generate($$2)' \
	    $< $*.ttf

sample-black-text.png: sample-black-text.ps $(TTFFILES) Fontmap
	gs -P -q -dSAFER -sDEVICE=pnggray -dTextAlphaBits=4 -o $@ $<

sample-white-text.png: sample-white-text.ps $(TTFFILES) Fontmap
	gs -P -q -dSAFER -sDEVICE=pngalpha -dTextAlphaBits=4 -o $@ $<

Teletext50-%-df.png: df.ps Teletext50.ttf Fontmap
	gs -P -q -dSAFER -dsize=$* -sDEVICE=png16m -o $@ $<

Teletext50-complement.ps: bedstead
	./bedstead --complement > Teletext50-complement.ps

Teletext50-complement.pdf: Teletext50-complement.ps Teletext50.ttf Fontmap
	ps2pdf -P $< $@

.PHONY: clean
clean:
	rm -f bedstead *.sfd *.ttf *.bdf *.png *.pdf Teletext50-complement.ps

.PHONY: dist

dist: $(DISTFILES)
	rm -rf Teletext50-$$(sed -n 's/^Version: //p' < Teletext50.sfd)
	mkdir Teletext50-$$(sed -n 's/^Version: //p' < Teletext50.sfd)
	ln $(DISTFILES) \
	    Teletext50-$$(sed -n 's/^Version: //p' < Teletext50.sfd)
	zip -r Teletext50-$$(sed -n 's/^Version: //p' < Teletext50.sfd).zip \
	    Teletext50-$$(sed -n 's/^Version: //p' < Teletext50.sfd)
	rm -r Teletext50-$$(sed -n 's/^Version: //p' < Teletext50.sfd)
