#!/usr/bin/env bash

set +xe

export PKG="firebase"
./tool/travis.sh dartfmt dartanalyzer test_vm
export PKG="firebase_sembast"
./tool/travis.sh dartfmt dartanalyzer test_vm
export PKG="firebase_sim"
./tool/travis.sh dartfmt dartanalyzer test_vm test_browser
export PKG="firebase_sim_io"
./tool/travis.sh dartfmt dartanalyzer test_vm test_browser
export PKG="firebase_node"
./tool/travis.sh dartfmt dartanalyzer
