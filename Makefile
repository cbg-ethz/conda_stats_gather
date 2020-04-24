THISMONTH := $(shell date '+%Y%m' )
LASTMONTH := $(shell date '+%Y%m' --date='last month 06:00' )
# or:   ls out/ | tail -1 | grep -Po '^[[:digit:]]{6}'


.PHONY: all clean

all: overview.pdf

archive/downloads-$(LASTMONTH).csv:
	./mkarchive $(LASTMONTH)

downloads.csv: archive/downloads-$(LASTMONTH).csv $(wildcard out/$(THISMONTH)*.json)
	@echo -e '\e[32mGather stats from $(THISMONTH)...\e[0m'
	./make_csv.pl | gawk 'NR==1||FNR>1' $(sort $(wildcard archive/downloads-*.csv)) - > $@
	@echo -e '\e[2mdone\e[0m'

overview_totals.pdf overview_diffs.pdf: downloads.csv
	@echo -e '\e[32mDraw plots...\e[0m'
	./plot.py
	@echo -e '\e[2mdone\e[0m'

overview.pdf: overview_totals.pdf overview_diffs.pdf
	@echo -e '\e[32mCombine report...\e[0m'
	pdfjam --fitpaper 'true' --outfile $@ -- $(+:= -)
	@echo -e '\e[2mdone\e[0m'

clean:
	rm overview.pdf overview_totals.pdf overview_diffs.pdf downloads.csv
