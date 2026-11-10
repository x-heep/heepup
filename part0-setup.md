# Part 0: setup (at home)

Goal: install the tools and run `hello_world` on the simulated X-HEEP.
Do it **before** the tutorial: there is no time for installations in the lab.

Supported: Linux x86_64 (Ubuntu 22.04/24.04), macOS (arm64/x86_64), Windows 10/11 through WSL2 (Ubuntu).

## 1. System packages

Linux / WSL:

```bash
sudo apt update
sudo apt install -y build-essential git wget curl cmake ninja-build autoconf automake help2man \
    flex bison libfl-dev libelf-dev libyaml-dev zlib1g-dev libexpat-dev python3 \
    openocd openfpgaloader picocom
```

macOS ([Homebrew](https://brew.sh)):

```bash
brew install git wget cmake ninja autoconf automake help2man flex bison libelf libyaml \
    openocd openfpgaloader picocom
```

Windows only: install WSL2 (`wsl --install` in an admin PowerShell), then do everything inside Ubuntu.
For the board you also need USB passthrough: install [usbipd-win](https://learn.microsoft.com/en-us/windows/wsl/connect-usb)
and attach the board with `usbipd attach --wsl --busid <busid>`.

## 2. RISC-V toolchain (CORE-V GCC)

Download the build for your OS, extract it to `~/tools/riscv` and export `RISCV_XHEEP`:

| OS | Archive |
|----|---------|
| Ubuntu 22.04+ / WSL | https://buildbot.embecosm.com/job/corev-gcc-ubuntu2204/47/artifact/corev-openhw-gcc-ubuntu2204-20240530.tar.gz |
| macOS arm64 | https://buildbot.embecosm.com/job/corev-gcc-macos-arm64/8/artifact/corev-openhw-gcc-macos-20240530.zip |
| macOS x86_64 | https://buildbot.embecosm.com/job/corev-gcc-macos/48/artifact/corev-openhw-gcc-macos-20240530.zip |

```bash
mkdir -p ~/tools/riscv
tar -xzf corev-openhw-gcc-*.tar.gz -C ~/tools/riscv --strip-components=1   # Linux
# macOS: unzip the .zip and move the content of the extracted folder to ~/tools/riscv
echo 'export RISCV_XHEEP=$HOME/tools/riscv' >> ~/.bashrc   # or ~/.zshrc
```

## 3. Verilator 5.040

```bash
git clone https://github.com/verilator/verilator.git ~/tools/verilator-src
cd ~/tools/verilator-src && git checkout v5.040
# macOS only: patch for Clang
sed -i '' 's|V3Hash{reinterpret_cast<uintptr_t>(val)} {}|V3Hash{static_cast<uint64_t>(reinterpret_cast<uintptr_t>(val))} {}|g' src/V3Hash.h
autoconf && ./configure --prefix=$HOME/tools/verilator
make -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu)" && make install
echo 'export PATH=$HOME/tools/verilator/bin:$PATH' >> ~/.bashrc   # or ~/.zshrc
```

## 4. Verible

Download `v0.0-4023-gc1271a00` from the [Verible releases](https://github.com/chipsalliance/verible/releases/tag/v0.0-4023-gc1271a00)
(`linux-static-x86_64` or `macOS`), extract it to `~/tools/verible` and add `~/tools/verible/bin` to `PATH`.

## 5. Tutorial repository and Python environment

You need [Miniconda](https://www.anaconda.com/docs/getting-started/miniconda/install).

```bash
git clone --recursive https://github.com/x-heep/heepup.git
cd heepup/x-heep
make conda
conda activate x-heep
```

## 6. Check

Open a new terminal, then:

```bash
cd heepup
conda activate x-heep
scripts/check-env.sh
```

Every line must be `OK`. The FPGA tools may be `WARN` only if you cannot install them; ask us before the tutorial.

## 7. hello_world in simulation

```bash
cd x-heep
make mcu-gen                              # generate X-HEEP with the default configuration
make verilator-build                      # build the simulation model (a few minutes)
make app PROJECT=hello_world              # compile the application
make verilator-run                        # run it
```

Expected output:

```
hello world!
```

## 8. GR-HEEP in simulation

```bash
cd ../gr-heep
make mcu-gen
make verilator-build
make app PROJECT=gr_heep_hello_world
make verilator-run
```

If both runs print their hello world, you are ready for the lab.
