#!/bin/bash

sed -i '/"-m/d;/gcc"/a\
      "--sysroot=\/usr\/arm-none-eabi\/",' "$@"
