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
  python3.12 python3.12-pip \
  autoconf automake libtool zlib-devel \
  libX11-devel libxcb-devel libglvnd-devel mesa-libGL-devel

# Rocky 8 base repos do not ship Qt 6 devel; use aqtinstall (needs Python 3.8+).
# aqt only ships qtbase for 6.5.x (no qttools module); build LinguistTools separately.
if [[ ! -x "${QT_DIR}/bin/qmake" ]]; then
  python3.12 -m pip install --upgrade pip
  python3.12 -m pip install 'aqtinstall<4'
  python3.12 -m aqt install-qt linux desktop "${QT_VERSION}" gcc_64 \
    -O "${QT_INSTALL_ROOT}"
fi

if [[ ! -x "${QT_DIR}/bin/lrelease" ]]; then
  QTTOOLS_SRC="${QTTOOLS_SRC:-/tmp/qttools-${QT_VERSION}}"
  if [[ ! -d "${QTTOOLS_SRC}/.git" ]]; then
    git clone --depth 1 --branch "v${QT_VERSION}" \
      https://code.qt.io/qt/qttools.git "${QTTOOLS_SRC}"
  fi
  cmake -S "${QTTOOLS_SRC}" -B "${QTTOOLS_SRC}/build" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${QT_DIR}" \
    -DCMAKE_INSTALL_PREFIX="${QT_DIR}" \
    -DFEATURE_assistant=OFF \
    -DFEATURE_designer=OFF \
    -DFEATURE_linguist=ON \
    -DFEATURE_qdoc=OFF \
    -DFEATURE_qtattributionsscanner=OFF \
    -DFEATURE_pixeltool=OFF \
    -DFEATURE_distancefieldgenerator=OFF
  cmake --build "${QTTOOLS_SRC}/build" --target install -j"$(nproc)"
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
