#!/usr/bin/env python
#
# ******************************************************************************
#
# ELITE CHECKSUM SCRIPT
#
# Written by Kieran Connell and Mark Moxon
#
# This script applies encryption, checksums and obfuscation to the compiled
# binaries for the main game and the loader. The script has two parts:
#
#   * The first part generates an encrypted version of the main game's "ELTcode"
#     binary, based on the code in the original "S.BCFS" BASIC source program
#
#   * The second part generates an encrypted version of the main game's "ELITE"
#     binary, based on the code in the original "ELITES" BASIC source program
#
# ******************************************************************************

from __future__ import print_function
import sys

argv = sys.argv
encrypt = True
release = 1

for arg in argv[1:]:
    if arg == "-u":
        encrypt = False
    if arg == "-rel1":
        release = 1
    if arg == "-rel2":
        release = 2

print("Electron Elite Checksum")
print("Encryption = ", encrypt)

# Load assembled code files that make up big code file

data_block = bytearray()
eliteb_offset = 0

# Append all assembled code files

elite_names = ("ELTA", "ELTB", "ELTC", "ELTD", "ELTE", "ELTF", "ELTG")

for file_name in elite_names:
    print(str(len(data_block)), file_name)
    if file_name == "ELTB":
        eliteb_offset = len(data_block)
    elite_file = open("3-assembled-output/" + file_name + ".bin", "rb")
    data_block.extend(elite_file.read())
    elite_file.close()

# Commander data checksum

commander_offset = 0x52
CH = 0x4B - 2
CY = 0
for i in range(CH, 0, -1):
    CH = CH + CY + data_block[eliteb_offset + i + 7]
    CY = (CH > 255) & 1
    CH = CH % 256
    CH = CH ^ data_block[eliteb_offset + i + 8]

print("Commander checksum = ", hex(CH))

data_block[eliteb_offset + commander_offset] = CH ^ 0xA9
data_block[eliteb_offset + commander_offset + 1] = CH

# Skip one byte for checksum0

checksum0_offset = len(data_block)
data_block.append(0)

# Skip another byte for the unused byte after checksum0 for IB Disc variant

if release == 2:
    data_block.append(0)

# Append SHIPS file

ships_file = open("3-assembled-output/SHIPS.bin", "rb")
data_block.extend(ships_file.read())
ships_file.close()

print("3-assembled-output/SHIPS.bin file read")

# Calculate checksum0

checksum0 = 0
for n in range(0x0, 0x4600):
    checksum0 += data_block[n + 0x28]

# This is an unprotected version, so let's just hard-code the checksum
# to the value from the extracted binary
checksum0 = 0x67

print("checksum 0 = ", hex(checksum0))

if encrypt:
    data_block[checksum0_offset] = checksum0 % 256

# Write output file for ELITECO

output_file = open("3-assembled-output/ELITECO.bin", "wb")
output_file.write(data_block)
output_file.close()

print("3-assembled-output/ELITECO.bin file saved")
