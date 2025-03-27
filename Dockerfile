FROM ubuntu:24.04

RUN apt update
RUN apt upgrade -y
# Necessary for `git clone`
RUN apt install -y --no-install-recommends git ca-certificates
# Necessary for kernel `make *config`
RUN apt install -y --no-install-recommends make gcc flex bison libc6-dev
# Necessary for kernel build
RUN apt install -y --no-install-recommends bc xz-utils libelf-dev libssl-dev
# Necessary for Busybox build and install
RUN apt install -y --no-install-recommends bzip2
# Necessary to build initramfs
RUN apt install -y --no-install-recommends cpio
# Necessary to build ISO image
RUN apt install -y --no-install-recommends grub2 xorriso

RUN mkdir -p /src/iso/boot/grub
COPY ["files", "/src/files/"]

RUN cd /src && \
    git clone --depth=1 -b v6.14 https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

RUN cd /src && \
    git clone --depth=1 -b 1_37_stable https://git.busybox.net/busybox

RUN mv /src/files/x86_64_min.config \
       /src/files/initramfs_xz.config \
       /src/linux/kernel/configs/

RUN cd /src/linux && \
    make distclean && \
    make allnoconfig && \
    make x86_64_min.config && \
    make kvm_guest.config && \
    make initramfs_xz.config && \
    make mod2yesconfig

RUN cd /src/linux && \
    make -j`nproc`

RUN cd /src/busybox && \
    make distclean && \
    make defconfig && \
    sed -i 's/CONFIG_TC=y/CONFIG_TC=n/' .config && \
    echo "CONFIG_STATIC=y" >> .config

RUN cd /src/busybox && \
    make -j`nproc` && \
    echo "CONFIG_STATIC=y" >> .config && \
    make install

RUN mv /src/files/init /src/busybox/_install/

RUN cd /src/busybox/_install && \
    mkdir dev proc sys && \
    chmod +x init && \
    chmod u+s bin/busybox && \
    find . -print0 | cpio --null -ov --format=newc | xz -9 --check=crc32 > ../initramfs.cpio.xz

RUN mv /src/files/grub.cfg /src/iso/boot/grub/

RUN cd /src && \
    cp linux/arch/x86/boot/bzImage iso/boot/ && \
    cp busybox/initramfs.cpio.xz iso/boot/ && \
    grub-mkrescue -o minlin.iso iso/

RUN mkdir -p /minlin/iso

CMD ["cp", "/src/minlin.iso", "/minlin/iso/"]
