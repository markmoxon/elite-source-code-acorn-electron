# Fully documented source code for Elite on the Acorn Electron

[BBC Micro cassette Elite](https://github.com/markmoxon/cassette-elite-beebasm) | [BBC Micro disc Elite](https://github.com/markmoxon/disc-elite-beebasm) | [6502 Second Processor Elite](https://github.com/markmoxon/6502sp-elite-beebasm) | [BBC Master Elite](https://github.com/markmoxon/master-elite-beebasm) | **Acorn Electron Elite** | [NES Elite](https://github.com/markmoxon/nes-elite-beebasm) | [Elite-A](https://github.com/markmoxon/elite-a-beebasm) | [Teletext Elite](https://github.com/markmoxon/teletext-elite) | [Elite Universe Editor](https://github.com/markmoxon/elite-universe-editor) | [Elite Compendium](https://github.com/markmoxon/elite-compendium) | [Elite over Econet](https://github.com/markmoxon/elite-over-econet) | [Flicker-free Commodore 64 Elite](https://github.com/markmoxon/c64-elite-flicker-free) | [BBC Micro Aviator](https://github.com/markmoxon/aviator-beebasm) | [BBC Micro Revs](https://github.com/markmoxon/revs-beebasm) | [Archimedes Lander](https://github.com/markmoxon/archimedes-lander)

![Screenshot of Elite on the Acorn Electron](https://www.bbcelite.com/images/github/Elite-Electron.png)

This repository contains source code for Elite on the Acorn Electron, with every single line documented and (for the most part) explained. It has been reconstructed by hand from a disassembly of the original game binaries.

It is a companion to the [bbcelite.com website](https://www.bbcelite.com).

See the [introduction](#introduction) for more information, or jump straight into the [documented source code](1-source-files/main-sources).

## Contents

* [Introduction](#introduction)

* [Acknowledgements](#acknowledgements)

  * [A note on licences, copyright etc.](#user-content-a-note-on-licences-copyright-etc)

* [Browsing the source in an IDE](#browsing-the-source-in-an-ide)

* [Folder structure](#folder-structure)

* [Flicker-free Elite](#flicker-free-elite)

* [Building Elite from the source](#building-elite-from-the-source)

  * [Requirements](#requirements)
  * [Windows](#windows)
  * [Mac and Linux](#mac-and-linux)
  * [Build options](#build-options)
  * [Verifying the output](#verifying-the-output)
  * [Log files](#log-files)

* [Building different variants of the Electron version of Elite](#building-different-variants-of-the-electron-version-of-elite)

  * [Building the Ian Bell Superior Software variant](#building-the-ian-bell-superior-software-variant)
  * [Building the Ian Bell Acornsoft variant](#building-the-ian-bell-acornsoft-variant)
  * [Differences between the variants](#differences-between-the-variants)

## Introduction

This repository contains source code for Elite on the Acorn Electron, with every single line documented and (for the most part) explained.

You can build the fully functioning game from this source. [Two variants](#building-different-variants-of-the-electron-version-of-elite) are currently supported: the Superior Software version from Ian Bell's personal website, and the original Acornsoft version from the same site (which has the galactic hyperspace bug).

It is a companion to the [bbcelite.com website](https://www.bbcelite.com), which contains all the code from this repository, but laid out in a much more human-friendly fashion. The links at the top of this page will take you to repositories for the other versions of Elite that are covered by this project.

* If you want to browse the source and read about how Elite works under the hood, you will probably find [the website](https://www.bbcelite.com) is a better place to start than this repository.

* If you would rather explore the source code in your favourite IDE, then the [annotated source](1-source-files/main-sources/elite-source.asm) is what you're looking for. It contains the exact same content as the website, so you won't be missing out (the website is generated from the source files, so they are guaranteed to be identical). You might also like to read the section on [Browsing the source in an IDE](#browsing-the-source-in-an-ide) for some tips.

* If you want to build Elite from the source on a modern computer, to produce a working game disc that can be loaded into an Electron or an emulator, then you want the section on [Building Elite from the source](#building-elite-from-the-source).

My hope is that this repository and the [accompanying website](https://www.bbcelite.com) will be useful for those who want to learn more about Elite and what makes it tick. It is provided on an educational and non-profit basis, with the aim of helping people appreciate one of the most iconic games of the 8-bit era.

## Acknowledgements

Electron Elite was written by Ian Bell and David Braben and is copyright &copy; Acornsoft 1984.

The code on this site has been reconstructed from a disassembly of the version released on [Ian Bell's personal website](http://www.elitehomepage.org/).

The commentary is copyright &copy; Mark Moxon. Any misunderstandings or mistakes in the documentation are entirely my fault.

Huge thanks are due to the original authors for not only creating such an important piece of my childhood, but also for releasing the source code for us to play with; to Paul Brink for his annotated disassembly; and to Kieran Connell for his [BeebAsm version](https://github.com/kieranhj/elite-beebasm), which I forked as the original basis for this project. You can find more information about this project in the [accompanying website's project page](https://www.bbcelite.com/about_site/about_this_project.html).

The following archives from Ian Bell's personal website forms the basis for this project:

* [Electron Elite, Acornsoft version](http://www.elitehomepage.org/archive/a/a4090000.zip)
* [Electron Elite, Superior Software version](http://www.elitehomepage.org/archive/a/a4090010.zip)

### A note on licences, copyright etc.

This repository is _not_ provided with a licence, and there is intentionally no `LICENSE` file provided.

According to [GitHub's licensing documentation](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/licensing-a-repository), this means that "the default copyright laws apply, meaning that you retain all rights to your source code and no one may reproduce, distribute, or create derivative works from your work".

The reason for this is that my commentary is intertwined with the original Elite source code, and the original source code is copyright. The whole site is therefore covered by default copyright law, to ensure that this copyright is respected.

Under GitHub's rules, you have the right to read and fork this repository... but that's it. No other use is permitted, I'm afraid.

My hope is that the educational and non-profit intentions of this repository will enable it to stay hosted and available, but the original copyright holders do have the right to ask for it to be taken down, in which case I will comply without hesitation. I do hope, though, that along with the various other disassemblies and commentaries of this source, it will remain viable.

## Browsing the source in an IDE

If you want to browse the source in an IDE, you might find the following useful.

* The most interesting files are in the [main-sources](1-source-files/main-sources) folder:

  * The main game's source code is in the [elite-source.asm](1-source-files/main-sources/elite-source.asm) file - this is the motherlode and probably contains all the stuff you're interested in.

  * The game's loader is in the [elite-loader.asm](1-source-files/main-sources/elite-loader.asm) file - this is mainly concerned with setup and copy protection.

* It's probably worth skimming through the [notes on terminology and notations](https://www.bbcelite.com/terminology/) on the accompanying website, as this explains a number of terms used in the commentary, without which it might be a bit tricky to follow at times (in particular, you should understand the terminology I use for multi-byte numbers).

* The accompanying website contains [a number of "deep dive" articles](https://www.bbcelite.com/deep_dives/), each of which goes into an aspect of the game in detail. Routines that are explained further in these articles are tagged with the label `Deep dive:` and the relevant article name.

* There are loads of routines and variables in Elite - literally hundreds. You can find them in the source files by searching for the following: `Type: Subroutine`, `Type: Variable`, `Type: Workspace` and `Type: Macro`.

* If you know the name of a routine, you can find it by searching for `Name: <name>`, as in `Name: SCAN` (for the 3D scanner routine) or `Name: LL9` (for the ship-drawing routine).

* The entry point for the [main game code](1-source-files/main-sources/elite-source.asm) is routine `TT170`, which you can find by searching for `Name: TT170`. If you want to follow the program flow all the way from the title screen around the main game loop, then you can find a number of [deep dives on program flow](https://www.bbcelite.com/deep_dives/) on the accompanying website.

* The source code is designed to be read at an 80-column width and with a monospaced font, just like in the good old days.

I hope you enjoy exploring the inner workings of Electron Elite as much as I have.

## Folder structure

There are five main folders in this repository, which reflect the order of the build process.

* [1-source-files](1-source-files) contains all the different source files, such as the main assembler source files, image binaries, fonts, boot files and so on.

* [2-build-files](2-build-files) contains build-related scripts, such as the checksum, encryption and crc32 verification scripts.

* [3-assembled-output](3-assembled-output) contains the output from the assembly process, when the source files are assembled and the results processed by the build files.

* [4-reference-binaries](4-reference-binaries) contains the correct binaries for each variant, so we can verify that our assembled output matches the reference.

* [5-compiled-game-discs](5-compiled-game-discs) contains the final output of the build process: an SSD disc image that contains the compiled game and which can be run on real hardware or in an emulator.

## Flicker-free Elite

This repository also includes a flicker-free version, which incorporates the backported flicker-free ship-drawing routines from the BBC Master, as well as a fix for planets so they no longer flicker. The flicker-free code is in a separate branch called `flicker-free`, and apart from the code differences for reducing flicker, this branch is identical to the main branch and the same build process applies.

The flicker-free Electron version also includes a number of extra features, all of which are backported from the BBC Micro version. The complete feature list is as follows:

* Flicker-free ships

* Flicker-free planets

* The escape capsule animation from the BBC Micro has been added, which is not present in the original Electron version

* There are now three sizes of stardust (like the BBC Micro) rather than two, with the addition of one-pixel stardust

* Planets are more high-fidelity, so the planet's circle looks more like the BBC Micro, and less like a 50p; this does slow things down a little, but overall the faster algorithm for flicker-free planets compensates for this

* For the SSD disc version, the black box that shows loading progress has been removed from the Acornsoft loading screen (it is still used to show loading progress in the UEF cassette version)

The annotated source files in the `flicker-free` branch contain both the original Acornsoft code and all of the modifications for flicker-free Elite, so you can look through the source to see exactly what's changed. Any code that I've removed from the original version is commented out in the source files, so when they are assembled they produce the flicker-free binaries, while still containing details of all the modifications. You can find all the diffs by searching the sources for `Mod:`.

For more information on flicker-free Elite, see the [hacks section of the accompanying website](https://www.bbcelite.com/hacks/flicker-free_elite.html).

## Building Elite from the source

Builds are supported for both Windows and Mac/Linux systems. In all cases the build process is defined in the `Makefile` provided.

### Requirements

You will need the following to build Elite from the source:

* BeebAsm, which can be downloaded from the [BeebAsm repository](https://github.com/stardot/beebasm). Mac and Linux users will have to build their own executable with `make code`, while Windows users can just download the `beebasm.exe` file.

* Python. The build process has only been tested on 3.x, but 2.7 should work.

* Mac and Linux users may need to install `make` if it isn't already present (for Windows users, `make.exe` is included in this repository).

For details of how the build process works, see the [build documentation on bbcelite.com](https://www.bbcelite.com/about_site/building_elite.html).

Let's look at how to build Elite from the source.

### Windows

For Windows users, there is a batch file called `make.bat` which you can use to build the game. Before this will work, you should edit the batch file and change the values of the `BEEBASM` and `PYTHON` variables to point to the locations of your `beebasm.exe` and `python.exe` executables. You also need to change directory to the repository folder (i.e. the same folder as `make.bat`).

All being well, entering the following into a command window:

```
make.bat
```

will produce a file called `elite-electron-ib-superior.ssd` in the `5-compiled-game-discs` folder that contains the Ian Bell Superior Software variant, which you can then load into an emulator, or into a real Electron using a device like a Gotek.

### Mac and Linux

The build process uses a standard GNU `Makefile`, so you just need to install `make` if your system doesn't already have it. If BeebAsm or Python are not on your path, then you can either fix this, or you can edit the `Makefile` and change the `BEEBASM` and `PYTHON` variables in the first two lines to point to their locations. You also need to change directory to the repository folder (i.e. the same folder as `Makefile`).

All being well, entering the following into a terminal window:

```
make
```

will produce a file called `elite-electron-ib-superior.ssd` in the `5-compiled-game-discs` folder that contains the Ian Bell Superior Software variant, which you can then load into an emulator, or into a real Electron using a device like a Gotek.

### Build options

By default the build process will create a typical Elite game disc with a standard commander and verified binaries. There are various arguments you can pass to the build to change how it works. They are:

* `variant=<name>` - Build the specified variant:

  * `variant=ib-superior` (default)
  * `variant=ib-acornsoft`

* `commander=max` - Start with a maxed-out commander (specifically, this is the test commander file from the original source, which is almost but not quite maxed-out)

* `verify=no` - Disable crc32 verification of the game binaries

So, for example:

`make variant=ib-acornsoft commander=max verify=no`

will build the Ian Bell Acornsoft variant with a maxed-out commander and no crc32 verification.

See below for more on the verification process.

### Verifying the output

The default build process prints out checksums of all the generated files, along with the checksums of the files from the original sources. You can disable verification by passing `verify=no` to the build.

The Python script `crc32.py` in the `2-build-files` folder does the actual verification, and shows the checksums and file sizes of both sets of files, alongside each other, and with a Match column that flags any discrepancies. If you are building an unencrypted set of files then there will be lots of differences, while the encrypted files should mostly match (see the Differences section below for more on this).

The binaries in the `4-reference-binaries` folder are those extracted from the released version of the game, while those in the `3-assembled-output` folder are produced by the build process. For example, if you don't make any changes to the code and build the project with `make`, then this is the output of the verification process:

```
Results for variant: ib-superior
[--originals--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
171314b3  19200  171314b3  19200   Yes   ELITECO.bin
a173fec7  19200  a173fec7  19200   Yes   ELITECO.unprot.bin
97e920c8   4864  97e920c8   4864   Yes   ELITEDA.bin
2e0a1a46   2205  2e0a1a46   2205   Yes   ELTA.bin
7f230b24   2338  7f230b24   2338   Yes   ELTB.bin
41e0d10e   2699  41e0d10e   2699   Yes   ELTC.bin
7b227167   2786  7b227167   2786   Yes   ELTD.bin
142b20dd   1812  142b20dd   1812   Yes   ELTE.bin
440253b4   2671  440253b4   2671   Yes   ELTF.bin
553b0078   2340  553b0078   2340   Yes   ELTG.bin
f23f7ef2   2348  f23f7ef2   2348   Yes   SHIPS.bin
a6ee7213   1024  a6ee7213   1024   Yes   WORDS9.bin
```

All the compiled binaries match the originals, so we know we are producing the same final game as the Ian Bell Superior Software variant.

### Log files

During compilation, details of every step are output in a file called `compile.txt` in the `3-assembled-output` folder. If you have problems, it might come in handy, and it's a great reference if you need to know the addresses of labels and variables for debugging (or just snooping around).

## Building different variants of the Electron version of Elite

This repository contains the source code for two different variants of the Acorn Electron version of Elite:

* The variant from the Superior Software UEF on Ian Bell's website

* The variant from the Acornsoft UEF on Ian Bell's website

By default the build process builds the Superior Software variant, but you can build a specified variant using the `variant=` build parameter.

### Building the Ian Bell Superior Software variant

You can add `variant=ib-superior` to produce the `elite-electron-ib-superior.ssd` file containing the Superior Software variant, though that's the default value so it isn't necessary. In other words, you can build it like this:

```
make.bat variant=ib-superior
```

or this on a Mac or Linux:

```
make variant=ib-superior
```

This will produce a file called `elite-electron-ib-superior.ssd` in the `5-compiled-game-discs` folder that contains the Ian Bell Superior Software variant.

The verification checksums for this version are as follows:

```
Results for variant: ib-superior
[--originals--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
171314b3  19200  171314b3  19200   Yes   ELITECO.bin
a173fec7  19200  a173fec7  19200   Yes   ELITECO.unprot.bin
97e920c8   4864  97e920c8   4864   Yes   ELITEDA.bin
2e0a1a46   2205  2e0a1a46   2205   Yes   ELTA.bin
7f230b24   2338  7f230b24   2338   Yes   ELTB.bin
41e0d10e   2699  41e0d10e   2699   Yes   ELTC.bin
7b227167   2786  7b227167   2786   Yes   ELTD.bin
142b20dd   1812  142b20dd   1812   Yes   ELTE.bin
440253b4   2671  440253b4   2671   Yes   ELTF.bin
553b0078   2340  553b0078   2340   Yes   ELTG.bin
f23f7ef2   2348  f23f7ef2   2348   Yes   SHIPS.bin
a6ee7213   1024  a6ee7213   1024   Yes   WORDS9.bin
```

### Building the Ian Bell Acornsoft variant

You can build the Ian Bell Acornsoft variant by appending `variant=ib-acornsoft` to the `make` command, like this on Windows:

```
make.bat variant=ib-acornsoft
```

or this on a Mac or Linux:

```
make variant=ib-acornsoft
```

This will produce a file called `elite-disc-ib-acornsoft.ssd` in the `5-compiled-game-discs` folder that contains the Ian Bell Acornsoft variant.

The verification checksums for this version are as follows:

```
Results for variant: ib-acornsoft
[--originals--]  [---output----]
Checksum   Size  Checksum   Size  Match  Filename
-----------------------------------------------------------
be5d6b7c  19200  be5d6b7c  19200   Yes   ELITECO.bin
e983beb3  19200  e983beb3  19200   Yes   ELITECO.unprot.bin
97e920c8   4864  97e920c8   4864   Yes   ELITEDA.bin
d27b7e45   2205  d27b7e45   2205   Yes   ELTA.bin
30655bb7   2338  30655bb7   2338   Yes   ELTB.bin
fdeca895   2699  fdeca895   2699   Yes   ELTC.bin
f43fb8fd   2783  f43fb8fd   2783   Yes   ELTD.bin
e08543b0   1814  e08543b0   1814   Yes   ELTE.bin
1114d856   2671  1114d856   2671   Yes   ELTF.bin
ea71aacd   2340  ea71aacd   2340   Yes   ELTG.bin
f23f7ef2   2348  f23f7ef2   2348   Yes   SHIPS.bin
a6ee7213   1024  a6ee7213   1024   Yes   WORDS9.bin
```

### Differences between the variants

You can see the differences between the variants by searching the source code for `_IB_SUPERIOR` (for features in the Ian Bell Superior Software variant) or `_IB_ACORNSOFT` (for features in the Ian Bell Acornsoft variant). There are only a few differences:

* The Acornsoft variant contains the galactic hyperspace bug from the first release of the game, which prevents the galactic hyperspace from working

* Galactic hyperspace does not work in the Acornsoft variant, but if it did, it would drop you at a randomly generated point in the new galaxy, rather than the closest system to galactic coordinates (96, 96), which is how all the other versions work

* If the galactic hyperspace worked in the Acornsoft variant, it would be triggered by CAPS-LOCK-H rather than CTRL-H

* The Acornsoft variant contains the same "hyperspace while docking" as the original cassette and disc versions; the Superior Software variant contains part of the fix for this issue, but it isn't completely fixed

See the [accompanying website](https://www.bbcelite.com/electron/releases.html) for a comprehensive list of differences between the variants.

---

Right on, Commanders!

_Mark Moxon_