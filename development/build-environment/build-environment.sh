#!/usr/bin/env bash
#
# Copyright 2026 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# -----------------------------------------------------------------------------
# The AndroidX build environment contract.
#
# This file is defines the JDK, the Android SDK, and output and cache
# directories variables that are used throughout the build.
#
# The definitions are consumed by sourcing this file (gradlew does, so every
# Gradle daemon and every process launched from it - including the managed
# IDEs started inherits the environment)
#
# -----------------------------------------------------------------------------

function androidx_apply_build_environment() {
  local support_root
  support_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

  if [ -n "$OUT_DIR" ] ; then
      mkdir -p "$OUT_DIR"
      OUT_DIR="$(cd $OUT_DIR && pwd -P)"
      export TMPDIR="$OUT_DIR/tmp"
  elif [[ $support_root == /google/cog/* ]] ; then
      export OUT_DIR="$HOME/androidxout"
  else
      local checkout_root
      checkout_root="$(cd $support_root/../.. && pwd -P)"
      export OUT_DIR="$checkout_root/out"
  fi
  export GRADLE_USER_HOME="$OUT_DIR/.gradle"
  export KONAN_DATA_DIR="$OUT_DIR/.konan"

  # unset ANDROID_BUILD_TOP so that Lint doesn't think we're building the platform itself
  unset ANDROID_BUILD_TOP

  # Pick the correct fullsdk for this OS.
  local plat="linux"
  case "$(uname)" in
    Darwin* )
      plat="darwin"
      ;;
  esac
  local platform_suffix="x86"
  case "$(arch)" in
    arm64* )
      platform_suffix="arm64"
  esac

  # Tests for lint checks default to using sdk defined by this variable. This removes a lot of
  # setup from each lint module.
  local prebuilt_android_home="$support_root/../../prebuilts/fullsdk-$plat"
  if [ -d "$prebuilt_android_home" ]; then
    export ANDROID_HOME="$prebuilt_android_home"
  elif [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME" ]; then
    export ANDROID_HOME
  elif [ -n "${ANDROID_SDK_ROOT:-}" ] && [ -d "$ANDROID_SDK_ROOT" ]; then
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
  else
    echo "Set ANDROID_HOME or ANDROID_SDK_ROOT to an installed Android SDK." >&2
    exit 1
  fi

  local prebuilt_jdk="$support_root/../../prebuilts/jdk/jdk21/$plat-$platform_suffix"
  if [ -d "$prebuilt_jdk" ]; then
    export JAVA_HOME="$prebuilt_jdk"
  elif [ -z "${JAVA_HOME:-}" ] || [ ! -x "$JAVA_HOME/bin/java" ]; then
    echo "Set JAVA_HOME to an installed JDK when building the standalone checkout." >&2
    exit 1
  fi
  export ANDROIDX_JDK21="$JAVA_HOME"
  export STUDIO_GRADLE_JDK=$JAVA_HOME

  # Creates/overwrites local.properties with sdk.dir and cmake.dir to avoid invalidating configuration cache
  $support_root/development/write_sdk_path.sh

  ANDROIDX_PROJECT_CACHE_DIR="$OUT_DIR/gradle-project-cache"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]] ; then
  # Executing this script would apply the contract to a throwaway shell.
  echo "$0 must be sourced, not executed, to apply the AndroidX build environment contract" >&2
  exit 1
fi

androidx_apply_build_environment
