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
	echo _VERSION=1 > sources/elite-header.h.asm
	echo _RELEASE=$(rel-electron) >> sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=TRUE >> sources/elite-header.h.asm
	$(BEEBASM) -i sources/elite-source.asm -v > output/compile.txt
	$(BEEBASM) -i sources/elite-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-readme.asm -v >> output/compile.txt
	$(PYTHON) sources/elite-checksum.py -u -rel$(rel-electron)
	$(BEEBASM) -i sources/elite-disc.asm -do elite-electron-flicker-free$(suffix-electron).ssd -opt 3 -title "E L I T E"

.PHONY:encrypt
encrypt:
	echo _VERSION=1 > sources/elite-header.h.asm
	echo _RELEASE=$(rel-electron) >> sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=FALSE >> sources/elite-header.h.asm
	$(BEEBASM) -i sources/elite-source.asm -v > output/compile.txt
	$(BEEBASM) -i sources/elite-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-readme.asm -v >> output/compile.txt
	$(PYTHON) sources/elite-checksum.py -rel$(rel-electron)
	$(BEEBASM) -i sources/elite-disc.asm -do elite-electron-flicker-free$(suffix-electron).ssd -opt 3 -title "E L I T E"

.PHONY:verify
verify:
	@$(PYTHON) sources/crc32.py extracted$(folder-electron) output
