BEEBASM?=beebasm
PYTHON?=python

# You can set the release that gets built by adding 'release=<rel>' to
# the make command, where <rel> is one of:
#
#   sth
#
# So, for example:
#
#   make encrypt verify release=sth
#
# will build the version from the Stairway to Hell archive. If you omit
# the release parameter, it will build the Stairway to Hell version.

rel-electron=1
folder-electron=/sth
suffix-electron=-sth

.PHONY:build
build:
	echo _VERSION=1 > 1-source-files/main-sources/elite-header.h.asm
	echo _RELEASE=$(rel-electron) >> 1-source-files/main-sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=TRUE >> 1-source-files/main-sources/elite-header.h.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-source.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-bcfs.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm -v >> 3-assembled-output/compile.txt
	$(PYTHON) 2-build-files/elite-checksum.py -u -rel$(rel-electron)
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc.asm -do 5-compiled-game-discs/elite-electron$(suffix-electron).ssd -opt 3 -title "E L I T E"

.PHONY:encrypt
encrypt:
	echo _VERSION=1 > 1-source-files/main-sources/elite-header.h.asm
	echo _RELEASE=$(rel-electron) >> 1-source-files/main-sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=FALSE >> 1-source-files/main-sources/elite-header.h.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-source.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-bcfs.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm -v >> 3-assembled-output/compile.txt
	$(PYTHON) 2-build-files/elite-checksum.py -rel$(rel-electron)
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc.asm -do 5-compiled-game-discs/elite-electron$(suffix-electron).ssd -opt 3 -title "E L I T E"

.PHONY:verify
verify:
	@$(PYTHON) 2-build-files/crc32.py 4-reference-binaries$(folder-electron) 3-assembled-output
