
all: img
boot:
	nasm -f elf32  foo.asm -o foo.o
	nasm -f elf32  boot.asm -o boot.o
	nasm -f elf32  head.asm -o head.o
	nasm -f elf32  kernel_s.asm -o kernel_s.o
	gcc -m32 -c -g main.c -o main.o
	gcc -m32 -c -g test.c -o test.o
	gcc -c -g kernel.c -o kernel.o
	#ld -m elf_i386  -dynamic-linker /lib/ld-linux.so.2 main.o foo.o -lc -e _start -o main.bin
	ld -T ld_script.ld boot.o -o boot.bin
	ld -T ld_script.ld head.o -o head.bin
	ld -T ld_script.ld test.o -o test.bin
	ld -T ld_script.ld kernel.o kernel_s.o -o kernel.bin
	#ld  kernel.o kernel_s.o -e kernel -o kernel.bin
	objcopy -O binary -j .text boot.bin
	objcopy -O binary -j .text head.bin
	objcopy -O binary -j .text test.bin
	objcopy -O binary -j .text kernel.bin
run: img
	qemu-system-i386 -boot a -fda boot.img -serial stdio
bochs: img
	bochs -f bochs.conf
debug: img
	qemu-system-i386  -boot a -fda boot.img -gdb tcp::1234 -S
img: boot
	dd if=/dev/zero of=emptydisk.img bs=512 count=2880 #生成空白软盘镜像文件
	dd if=boot.bin of=boot.img bs=512 count=1 #用 bin file 生成对应的镜像文件
	dd if=head.bin of=boot.img bs=512 count=1 seek=1
	dd if=kernel.bin of=boot.img bs=512 count=2 seek=2
	dd if=font8.bin of=boot.img bs=512 count=8 seek=4
	#dd if=emptydisk.img of=boot.img skip=1 seek=1 bs=512 count=2879 #在 bin 生成的镜像文件后补上空白，成为合适大小的软盘镜像

font:	./tools/font.c ./tools/font8.font
	gcc "./tools/font.c" -o "./tools/font.bin"
	-"./tools/font.bin" "./tools/font8.font" "./tools/font8.bin"
	cp "./tools/font8.bin" "./font8.bin"
clean:
	rm -f *.o
	rm -f *.bin
	rm -f *.img
