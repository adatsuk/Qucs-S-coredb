# CORE integration in Qucs-S

Qucs-S can open and save schematic views in the [CORE](https://github.com/IHP-GmbH/CommonDB) format (`.core`, `*.schematic.core`) when built with `QUCS_ENABLE_CORE=ON` (default).

## Layout

| Path | Role |
|------|------|
| `../CommonDB` | CORE library (sibling checkout) |
| `../LibMan/capnp-install` | Cap'n Proto prefix (reused automatically) |
| `qucs/core_schematic_io.*` | CORE ↔ Qucs `.sch` bridge |
| `cmake/FetchCore.cmake` | CMake subproject for CORE |

## Build (Windows, Qt 6)

```powershell
cd C:\Users\anton\Documents\Qucs-S-coredb
git submodule update --init --depth 1

mkdir build
cd build
cmake .. -G "MinGW Makefiles" `
  -DCMAKE_PREFIX_PATH=C:/Qt/6.10.2/mingw_64 `
  -DCMAKE_BUILD_TYPE=Release `
  -DQUCS_ENABLE_CORE=ON `
  -DQUCS_CORE_SOURCE_DIR=C:/Users/anton/Documents/CommonDB `
  -DCAPNP_ROOT=C:/Users/anton/Documents/LibMan/capnp-install

cmake --build . --target qucs-s -j
```

Requires: Qt 6, CMake, flex, bison, gperf, MinGW (same toolchain as Qt).

## Usage

- **File → Open** — select `*.core` or `*.schematic.core`
- **File → Save** — writes back to CORE when the document path is a `.core` file
- Round-trip uses CommonDB `QucsImporter` / `QucsExporter` internally

## Disable CORE

```powershell
cmake .. -DQUCS_ENABLE_CORE=OFF
```
