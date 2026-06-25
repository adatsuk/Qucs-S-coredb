#!/usr/bin/env bash
# Install build dependencies on RHEL 8 / Rocky Linux 8 / AlmaLinux 8 (CI and local containers).
set -euo pipefail

QT_VERSION="${QT_VERSION:-6.5.3}"
QT_INSTALL_ROOT="${QT_INSTALL_ROOT:-/opt/qt}"
QT_DIR="${QT_INSTALL_ROOT}/${QT_VERSION}/gcc_64"

dnf install -y dnf-plugins-core
dnf config-manager --set-enabled powertools 2>/dev/null \
  || dnf config-manager --set-enabled crb 2>/dev/null \
  || true
dnf install -y epel-release 2>/dev/null || true

dnf install -y \
  gcc gcc-c++ make cmake ninja-build git pkgconfig \
  flex bison gperf dos2unix \
  python3 python3-pip \
  autoconf automake libtool zlib-devel \
  libX11-devel libxcb-devel libglvnd-devel mesa-libGL-devel

# Rocky 8 base repos do not ship Qt 6 devel; use aqtinstall for a known-good toolchain.
if [[ ! -x "${QT_DIR}/bin/qmake" ]]; then
  pip3 install 'aqtinstall<4'
  aqt install-qt linux desktop "${QT_VERSION}" gcc_64 \
    -O "${QT_INSTALL_ROOT}" -m qtsvg
fi

export PATH="${QT_DIR}/bin:${PATH}"
export CMAKE_PREFIX_PATH="${QT_DIR}"
export LD_LIBRARY_PATH="${QT_DIR}/lib:${LD_LIBRARY_PATH:-}"

if [[ -n "${GITHUB_ENV:-}" ]]; then
  {
    echo "PATH=${PATH}"
    echo "CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
    echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
    echo "QT_DIR=${QT_DIR}"
  } >> "${GITHUB_ENV}"
fi

echo "Qt: $("${QT_DIR}/bin/qmake" -query QT_VERSION 2>/dev/null || echo "${QT_VERSION}")"
echo "CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
