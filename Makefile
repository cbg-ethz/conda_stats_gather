THISMONTH := $(shell date '+%Y%m' )
# or:   ls out/ | tail -1 | grep -Po '^[[:digit:]]{6}'

HEADER=$(shell yq 'join(",")' make_csv.yaml)
ORIG_CSV = $(wildcard archive/downloads-*.csv.orig)
ALL_CSV = $(patsubst %.csv.orig, %.csv, $(ORIG_CSV))

.PHONY: all clean


all: downloads.csv

archive/downloads-%.csv:archive/downloads-%.csv.orig make_csv.yaml
	gawk -v headers="$(HEADER)" -f  missing_col.awk $< | xsv select --output $@ -- "timestamp,$(HEADER)"

downloads.csv: $(ALL_CSV) $(wildcard out/$(THISMONTH)*.json)
	@echo -e '\e[32mGather stats from $(THISMONTH)...\e[0m'
	./make_csv.pl | xsv select -- "timestamp,$(HEADER)" | xsv cat rows --output $@ -- $(sort $(ALL_CSV)) -
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
