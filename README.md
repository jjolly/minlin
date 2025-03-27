# Minlin Linux ISO builder by John Jolly
Here is my build process for creating a bootable Linux ISO with two files:
* The Linux kernel
* Busybox

It is the smallest distribution I can find, although I suspect someone will or may already have made a smaller distro. I'm not in a race and I'm always interested it what people can do.

The initial submission was written in a fit of unhealthy madness the night of 26-27 March 2025. Who needs sleep?

## How
Currently the image builds everything, then copies the iso into a folder on your host when you create the container like this:

```
docker run --rm -v `pwd`/iso:/minlin/iso jjolly/minlin
```

Of course you want to create the folder you want the iso to land in. If you don't supply a volume mapping, the iso will be copied to the `/minlin/iso` folder inside the quickly-deleted container. Kind of useless, so use a volume map.

Want to boot the image? Then install `qemu-system-x86` and run this command:
```
qemu-system-x86_64 -cdrom iso/minlin.iso -nographic
```

Want to experience a kernel panic? Exit the shell. That's how raw this is.

## What
I'm building a very low-feature kernel starting with making the `allnoconfig` target and adding what I need to make this work. There are a few extra files that help add necessary functionality and might need a little explanation:
* `x86_64_min.config`: This file adds kernel config options to allow the kernel to load 64-bit ELF-formatted executables using the init script.
* `initramfs_xz.config`: This adds kernel config options that allow the kernel to use an `initrd` that is compressed with `xz`.
* `init`: This is the init script mentioned earlier.
* `grub.cfg`: This gives me boot options for the iso image.

## When
I have plans for this. I'd like to actually perform the build process on your machine. When you start the container, all the files will already be downloaded. A script will start the kernel and busybox builds, then package it up into an ISO. That's a future-John project, though.

## Why
I've done this once already, waaay back in 2016. The old one no longer works and I've since lost the `Dockerfile` as I didn't take Github seriously then. Now I do. Archive all the things! This is my penance. Now it works as of v6.14 of the Linux kernel.

## Who
Most of this is from the [wonderful post by Hirbod Behnam](https://medium.com/@ThyCrow/compiling-the-linux-kernel-and-creating-a-bootable-iso-from-it-6afb8d23ba22). I've made my own changes, but this article does 90% of the heavy lifting.
