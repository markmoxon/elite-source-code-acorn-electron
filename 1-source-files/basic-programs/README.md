# BASIC programs for the Electron version of Elite

This folder contains the BASIC programs from the original game disc for the Electron version of Elite on Ian Bell's personal website.

* [ELITE-cassette.bas](ELITE-cassette.bas) is the BASIC loader program for the cassette version, which has the binary mode 7 screen from elite-loading-screen.asm  appended in order to create the final hybrid BASIC/machine code loader program; this file is not used in the build process and is included for reference

* [ELITE-cassette.bin](ELITE-cassette.bin) is the tokenised version of the BASIC source and is the one that's used in the build process; this version includes a blank window for showing loading progress

* [ELITE-disc.bas](ELITE-disc.bas) is the BASIC loader program for the disc version, which has the binary mode 7 screen appended in order to create the final hybrid BASIC/machine code loader program; this file is not used in the build process and is included for reference

* [ELITE-disc.bin](ELITE-disc.bin) is the tokenised version of the BASIC source and is the one that's used in the build process; this version does not a blank window

By default the disc version is included in the build, but this can be changed using the disc=no build option.

---

Right on, Commanders!

_Mark Moxon_