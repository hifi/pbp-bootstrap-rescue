all: bootfs

.PHONY: image
image: pbp-bar.img.xz

pbp-bar.img.xz: bootfs
	./make-image.sh
	xz -f pbp-bar.img

rootfs:
	sudo mkdir -p rootfs/
	sudo debootstrap --include=busybox,debootstrap,iproute2,iw,wpasupplicant,isc-dhcp-client --variant=minbase --arch=arm64 stretch rootfs/ http://cdn.debian.net/debian

rootfs.cpio: rootfs
	(cd rootfs && find . | sudo cpio -H newc -ov > "../rootfs.cpio")

bootfs/bootstrap.gz: rootfs.cpio
	cp rootfs.cpio bootfs/bootstrap
	(cd installer && sudo find . | sudo cpio -H newc -ov >> "../bootfs/bootstrap")
	gzip -f -9 bootfs/bootstrap

bootfs: bootfs/bootstrap.gz bootfs/Image bootfs/rk3399-pinebookpro.dtb

bootfs/Image:
	curl -Lo bootfs/Image https://github.com/mrfixit2001/updates_repo/raw/v1.8/pinebook/kernel/Image

bootfs/rk3399-pinebookpro.dtb:
	curl -Lo bootfs/rk3399-pinebookpro.dtb https://github.com/mrfixit2001/updates_repo/raw/v1.8/pinebook/kernel/rk3399-pinebookpro.dtb

clean:
	rm -f rootfs.cpio bootfs/bootstrap.gz pbp-bar.img* bootfs/Image bootfs/rk3399-pinebookpro.dtb
	sudo rm -rf rootfs/
