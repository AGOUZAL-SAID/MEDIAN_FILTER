# @file  Makefile
# @brief The project source files
# @note  This file can be edited by the user to adapt it to its project

export SYN_DIR = $(shell pwd)

# source files directory
SRC_DIR = $(SYN_DIR)/../src

# source files for synthesis
# add the path to source files ex:MCE.sv
# separated with spaces
SOURCE_FILES =  MCE.sv MED.sv MEDIAN.sv

# Top module for synthesis
# add the top modle for synthesis ex:MCE
export TOP_MODULE  = MEDIAN

export HDL_FILES = $(patsubst %,$(SRC_DIR)/%,$(SOURCE_FILES))

# End of SOURCE_FILES
.PHONY : all syn clean pr show

all:
	@echo "make syn  : launch synthesis"
	@echo "make show : show elaborated generic schematic"
	@echo "make pr   : launch place and route phase for FPGA target"
	@echo "make clean: clean the current directory"


SYN_PR_TOOLS=/comelec/softs/opt/yosys
YOSYS_PATH=${SYN_PR_TOOLS}/current/bin
GRAPH_PATH=${SYN_PR_TOOLS}/netlistsvg

# Partie 1 : synthèse
syn:$(TOP_MODULE)_syn.json

$(TOP_MODULE)_syn.json:
ifeq ($(TOP_MODULE),xxxx)
	@echo "You have to define the TOP MODULE !!!"
else
ifeq ($(SOURCE_FILES),xxxx.sv)
	@echo "You have to define the SOURCE FILES !!!"
else
	@echo "==> TOP LEVEL MODULE  : $(TOP_MODULE)"
	@echo "==> FILES : $(SOURCE_FILES)"
	$(YOSYS_PATH)/yosys -c synthesis.tcl -L $(TOP_MODULE)_syn.log
endif
endif

# Partie 2 : affichage du schéma "RTL"
show: $(TOP_MODULE)_prep.svg
	inkview $<

$(TOP_MODULE)_prep.svg: $(TOP_MODULE)_syn.json
	${GRAPH_PATH}/netlistsvg ${TOP_MODULE}_prep.json -o $@

# Partie 3: Placement / Routage
# Quelle marque/type de fpga
# ATTENTION: a n'utiliser que pour la dernière phase (MEDIAN)
DEVICE?=5CSEMA5F31C6
# Ou sont les entrées/sorties du chip
QSF?=de1Soc.qsf
# Quelle est la fréquence de fonctionnement désirée (MHz)
FREQ?=50

pr:$(TOP_MODULE)_pr.v

$(TOP_MODULE)_pr.json:$(TOP_MODULE)_syn.json $(QSF)
ifeq ($(TOP_MODULE),MEDIAN)
	$(YOSYS_PATH)/nextpnr-mistral --quiet  --top $(TOP_MODULE) --device $(DEVICE) --freq $(FREQ) --json $< --write $@ --qsf $(QSF) --router router2 --sdf $(TOP_MODULE)_pr.sdf --sdf-cvc --detailed-timing-report --log $(TOP_MODULE)_pr.log
else
	@echo "The Place and Route phase is only for MEDIAN module"
endif

$(TOP_MODULE)_pr.v: $(TOP_MODULE)_pr.json
	$(YOSYS_PATH)/yosys -p "read_json $< ; write_verilog $@" -l $(TOP_MODULE)_conv_pr.log 



clean:
	@rm -fr *.svg
	@rm -fr *.log
	@rm -fr *.v
	@rm -fr *.json
	@rm -fr *.sdf
