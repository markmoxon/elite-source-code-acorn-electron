BEEBASM?=beebasm
PYTHON?=python
PHP?=php

# A make command with no arguments will build the Ian Bell Superior Software
# variant with the standard commander and crc32 verification of the game
# binaries
#
# Optional arguments for the make command are:
#
#   variant=<release>   Build the specified variant:
#
#                         ib-superior (default)
#                         ib-acornsoft
#
#   disc=no             Build a version to load from cassette rather than disc
#
#   commander=max       Start with a maxed-out commander
#
#   verify=no           Disable crc32 verification of the game binaries
#
# So, for example:
#
#   make variant=ib-acornsoft commander=max verify=no
#
# will build the Ian Bell Acornsoft variant with a maxed-out commander and
# no crc32 verification
#
# The following variables are written into elite-build-options.asm depending on
# the above arguments, so they can be passed to BeebAsm:
#
# _VERSION
#   5 = Acorn Electron
#
# _VARIANT
#   1 = Ian Bell's Superior Software UEF (default)
#   2 = Ian Bell's Acornsoft UEF
#
# _MAX_COMMANDER
#   TRUE  = Maxed-out commander
#   FALSE = Standard commander
#
# _DISC
#   TRUE  = Build for loading from disc
#   FALSE = Build for loading from cassette
#
# The verify argument is passed to the crc32.py script, rather than BeebAsm

ifeq ($(commander), max)
  max-commander=TRUE
else
  max-commander=FALSE
endif

unencrypt=-u
remove-checksums=FALSE
build-for-disc=TRUE
variant-number=1
folder=ib-superior
suffix=-compendium

.PHONY:all
all:
	echo _VERSION=5 > 1-source-files/main-sources/elite-build-options.asm
	echo _VARIANT=$(variant-number) >> 1-source-files/main-sources/elite-build-options.asm
	echo _REMOVE_CHECKSUMS=$(remove-checksums) >> 1-source-files/main-sources/elite-build-options.asm
	echo _MAX_COMMANDER=$(max-commander) >> 1-source-files/main-sources/elite-build-options.asm
	echo _DISC=$(build-for-disc) >> 1-source-files/main-sources/elite-build-options.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-source.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-bcfs.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm -v >> 3-assembled-output/compile.txt
	$(PYTHON) 2-build-files/elite-checksum.py $(unencrypt) -rel$(variant-number)
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc.asm -do 5-compiled-game-discs/elite-electron$(suffix).ssd -opt 3 -title "E L I T E"
ifneq ($(verify), no)
	@$(PYTHON) 2-build-files/crc32.py 4-reference-binaries/$(folder) 3-assembled-output
endif
