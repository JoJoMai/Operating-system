#!/bin/bash
set -xue  # Print commands, exit on error or undefined vars

# Paths to tools
CC=/opt/homebrew/opt/llvm/bin/clang       # RISC-V Clang compiler (Ubuntu users: use clang)
OBJCOPY=/opt/homebrew/opt/llvm/bin/llvm-objcopy  # Tool to manipulate binaries
QEMU=qemu-system-riscv32                   # RISC-V emulator

# Common compiler flags for bare-metal RISC-V
CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra --target=riscv32-unknown-elf -fno-stack-protector -ffreestanding -nostdlib"

# -----------------------------
# Build the user application
# -----------------------------
# Step 1: Compile and link user-space app with custom memory layout
$CC $CFLAGS -Wl,-Tuser.ld -Wl,-Map=shell.map -o shell.elf shell.c user.c common.c

# Step 2: Convert ELF to raw binary format for memory embedding
$OBJCOPY --set-section-flags .bss=alloc,contents -O binary shell.elf shell.bin

# Step 3: Convert binary to object file so it can be linked with the kernel
$OBJCOPY -Ibinary -Oelf32-littleriscv shell.bin shell.bin.o

# -----------------------------
# Build the kernel
# -----------------------------
# Link the kernel with the embedded application binary
$CC $CFLAGS -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf \
    kernel.c common.c shell.bin.o

# -----------------------------
# Run on QEMU
# -----------------------------
$QEMU -machine virt -bios default -nographic -serial mon:stdio --no-reboot \
    -d unimp,guest_errors,int,cpu_reset -D qemu.log \
    -drive id=drive0,file=lorem.txt,format=raw,if=none \
    -device virtio-blk-device,drive=drive0,bus=virtio-mmio-bus.0 \
    -kernel kernel.elf
