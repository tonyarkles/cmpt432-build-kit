
# Warning

There may be a bug in the bootloader where it will only copy the first
64kB of your kernel image. This was reported and fixed by a student at
one point, but I have no clue if it made it in here yet. If you find
it before I do, send a PR please!

# Overview

This is the build kit I put together for CMPT432 in around 2010. Found
it recently and decided to share it. This will build a floppy disk
image with an exceptionally simple bootloader that loads the disk
image into memory, configures 32-bit protected mode, and ultimately
jumps to main() in C.

# Building

`make` in the project root will:

- build the bootloader
- build the kernel
- assemble both into a floppy image

`make clean` will remove all of the intermediate files (.o and
friends).

# Running

This has been run on Linux, OS X, and Windows in a various emulators:
VirtualBox, VMWare, and QEMU. While writing this today, I'm using QEMU
on WSL2:

```
qemu-system-i386 -fda floppyimg -curses
```

As a quick refresher, in curses-mode, you can switch to your OS by
hitting "Esc 1" and to the QEMU monitor console with "Esc 2". You can
quit by typing `quit` into the monitor console.
