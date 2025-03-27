# Minlin Linux ISO builder

Here is my build process for creating a bootable Linux ISO with two files:
* The Linux kernel
* Busybox

Currently the image builds everything, then copies the iso into a folder on your host when you create the container like this:

```
docker run --rm -v `pwd`/iso:/minlin/iso jjolly/minlin
```

Of course you want to create the folder you want the iso to land in. If you don't supply a volume mapping, the iso will be copied to the `/minlin/iso` folder inside the quickly-deleted container. Kind of useless, so use a volume map.

I have plans for this. I'd like to actually perform the build process on your machine. When you start the container, all the files will already be downloaded. A script will start the kernel and busybox builds, then package it up into an ISO. That's a future-John project, though.

Most of this is from the [wonderful post by Hirbod Behnam](https://medium.com/@ThyCrow/compiling-the-linux-kernel-and-creating-a-bootable-iso-from-it-6afb8d23ba22). I've made my own changes, but this article does 90% of the heavy lifting.
