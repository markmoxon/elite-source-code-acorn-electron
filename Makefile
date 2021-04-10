BEEBASM?=beebasm
PYTHON?=python

rel-electron=1
folder-electron=''

.PHONY:build
build:
	echo _VERSION=1 > sources/elite-header.h.asm
	echo _RELEASE=$(rel-electron) >> sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=TRUE >> sources/elite-header.h.asm
	$(BEEBASM) -i sources/elite-source.asm -v > output/compile.txt
	#$(BEEBASM) -i sources/elite-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader.asm -v >> output/compile.txt
	#$(PYTHON) sources/elite-checksum.py -u -rel$(rel-electron)
	$(BEEBASM) -i sources/elite-disc.asm -do elite-electron.ssd -opt 3

.PHONY:encrypt
encrypt:
	echo _VERSION=1 > sources/elite-header.h.asm
	echo _RELEASE=$(rel-electron) >> sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=FALSE >> sources/elite-header.h.asm
	$(BEEBASM) -i sources/elite-source.asm -v > output/compile.txt
	#$(BEEBASM) -i sources/elite-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader.asm -v >> output/compile.txt
	#$(PYTHON) sources/elite-checksum.py -rel$(rel-electron)
	$(BEEBASM) -i sources/elite-disc.asm -do elite-electron.ssd -opt 3

.PHONY:verify
verify:
	@$(PYTHON) sources/crc32.py extracted$(folder-electron) output
