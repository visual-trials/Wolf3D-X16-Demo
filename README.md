# Wolf3D-X16-Demo

This is an attempt to recreate the shareware version of Wolfenstein 3D on the Commander X16

## To compile into a .rom file

Right now the Wold3D is best compiled with vasm6502 (oldstyle). This is how you can generate a .rom file:

  `vasm6502_oldstyle.exe -Fbin -dotdir -wdc02 wolf3d.s -o wolf3d.rom`

VASM manual: http://sun.hasenbraten.de/vasm/release/vasm_6.html

## To run using the X16 emulator

In order to run the hardware tester using the emulator you can set the rom-file like this:

  `x16emu.exe -rom "wolf3d.rom" -ram 2048 -debug`

## To run using X16 hardware

The generated .rom file can be flashed to your ROM (SST39SF040) using your favorite flash programmer. It uses the full 512 KB in size.

-> Note that you need 2048kB of Banked RAM for this demo to run!

