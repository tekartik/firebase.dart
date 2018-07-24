#!/bin/bash

# Fast fail the script on failures.
set -xe

dartfmt -w lib test
dartanalyzer --fatal-warnings lib test

pub run test -p vm
# pub run build_runner test -- -p chrome