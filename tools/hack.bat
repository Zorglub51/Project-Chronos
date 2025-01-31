@echo off

sunxi-fel.exe -v -p write 0x2000 fes1.bin 
sunxi-fel.exe -v -p exe 0x2000
sunxi-fel.exe -v -p write 0x43800000 boot.img.tftp.cpio.xz
sunxi-fel.exe -v -p write 0x47000000 uboot.bin
sunxi-fel.exe -v -p exe 0x47000000
nand_dump.exe full
mv full_nand.bin BACKUP\full_nand.bin
nand_dump.exe split
mv mmcblk0p1 BACKUP\mmcblk0p1
mv mmcblk0p2 BACKUP\mmcblk0p2
mv mmcblk0p5 BACKUP\mmcblk0p5
mv mmcblk0p6 BACKUP\mmcblk0p6
mv mmcblk0p7 BACKUP\mmcblk0p7
mv mmcblk0p8 BACKUP\mmcblk0p8
mv mmcblk0p9 BACKUP\mmcblk0p9
mv mmcblk0p10 BACKUP\mmcblk0p10

