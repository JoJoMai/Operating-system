# RISC-V Operating System Kernel

A simple 32-bit operating system kernel for the RISC-V architecture, developed for educational purposes. This project implements several core OS functionalities from scratch, including cooperative multitasking, virtual memory management, a VirtIO block device driver, an in-memory TAR-based file system, and a basic interactive user shell.

## Features

* **RISC-V 32-bit Kernel:** Runs on a 32-bit RISC-V architecture emulated by QEMU.
* **Cooperative Multitasking:** Supports multiple processes running concurrently through a cooperative scheduling mechanism implemented in `kernel.c`.
* **Sv32 Virtual Memory Management:** Implements two-level paging for virtual memory (as defined by `SATP_SV32` and page flags in `kernel.h`), providing memory isolation for processes using functions like `map_page` in `kernel.c`.
* **System Call Interface:** Provides an API for user-space applications to request kernel services (e.g., `putchar`, `getchar`, `exit`, `readfile`, `writefile`). These are defined in `common.h`, implemented in `kernel.c`, and accessed via wrapper functions in `user.c`.
* **VirtIO Block Device Driver:** Interacts with an emulated VirtIO block device (e.g., in QEMU) for disk I/O, based on structures and constants in `kernel.h` and implemented in `kernel.c`.
* **TAR-based File System:** Reads and writes files from/to a disk image. The file system logic in `kernel.c` uses the `struct tar_header` defined in `kernel.h` to interpret the TAR format. Files are managed in memory.
* **User Shell:** A simple command-line interface (`shell.c`) allowing interaction with the OS, including running commands like `hello`, `exit`, and performing basic file operations (`readfile`, `writefile`).
* **Custom C Standard Library Functions:** Includes implementations of common functions like `printf`, `memcpy`, `memset`, `strcpy`, and `strcmp` in `common.c`.

## Technologies Used

* **Programming Languages:** C, RISC-V Assembly (for context switching, trap handling, etc. in `kernel.c` and `user.c`)
* **Architecture:** RISC-V (32-bit, specifically `riscv32-unknown-elf` target).
* **Emulator:** QEMU (`qemu-system-riscv32`).
* **Compiler & Tools:**
    * LLVM/Clang compiler.
    * `llvm-objcopy` for binary manipulation.
    * Linker Scripts (e.g., `kernel.ld`, `user.ld`, referenced in `run.sh`).
* **Build System:** Bash Script (`run.sh`).
* **Device Model:** VirtIO (Block Device, constants defined in `kernel.h`).

## Getting Started

### Prerequisites

* A RISC-V 32-bit cross-compiler toolchain:
    * Clang (specifically one that can target `riscv32-unknown-elf`).
    * `llvm-objcopy` (usually part of the LLVM toolchain).
* QEMU (specifically `qemu-system-riscv32`).
* Standard Unix utilities like `tar` and `bash`.

**Note:** The `run.sh` script contains hardcoded paths for the Clang compiler (`CC=/opt/homebrew/opt/llvm/bin/clang`) and `llvm-objcopy` (`OBJCOPY=/opt/homebrew/opt/llvm/bin/llvm-objcopy`). You may need to adjust these paths in `run.sh` to match your local development environment.

### Build and Run

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd <repository-directory-name>
    ```
    (Replace `<your-repository-url>` and `<repository-directory-name>` accordingly)

2.  **Prepare Disk Image (Optional but Recommended for Full File System Functionality):**
    The `run.sh` script attempts to create a `disk.tar` file from text files located in a `disk` directory. To use the file system features like `readfile` and `writefile` in the shell:
    * Create a directory named `disk` in the project root: `mkdir disk`
    * Place some `.txt` files inside the `disk` directory. For example, you could create `disk/hello.txt` with some sample content.

3.  **Make the run script executable:**
    ```bash
    chmod +x run.sh
    ```

4.  **Execute the script:**
    ```bash
    ./run.sh
    ```
    This script will:
    * Compile the user shell (`shell.c`, `user.c`, `common.c`).
    * Convert the shell binary into an object file suitable for linking with the kernel.
    * Compile the kernel (`kernel.c`, `common.c`) and link it with the shell object file using their respective linker scripts.
    * If the `disk` directory exists and contains `*.txt` files, package them into `disk.tar`.
    * Run the compiled kernel (`kernel.elf`) in QEMU. You should see kernel boot messages followed by the shell prompt (`>`) in your terminal.

## Project Structure

A brief overview of the key files:

* `kernel.c`, `kernel.h`: Contains the core kernel logic. This includes process management, virtual memory management, system call handling, the VirtIO block device driver, and the TAR-based file system implementation.
* `shell.c`: Implements the simple user-space command-line shell.
* `user.c`, `user.h`: Provides the user-mode library functions, primarily wrappers for making system calls to the kernel.
* `common.c`, `common.h`: Contains shared utility functions (like a custom `printf`, `memcpy`, `strcpy`, etc.) and type definitions used by both the kernel and user-space code. It also includes system call number definitions.
* `run.sh`: The main build and execution script for the project.
* `user.ld`, `kernel.ld`: Linker scripts (not provided in the initial context but referenced by `run.sh`) that define the memory layout for the user application and the kernel, respectively.
* `disk/`: (User-created directory) Intended to hold files that will be packaged into the `disk.tar` image, which the kernel's file system can then read.

---