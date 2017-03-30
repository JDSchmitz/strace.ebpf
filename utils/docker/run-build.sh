#!/bin/bash -e
#
# Copyright 2016-2017, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#
#     * Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#
# run-build.sh - is called inside a Docker container;
#		starts a build of strace.ebpf
#

SKIP_MESSAGE="Notice: skipping tests (too old kernel: required >= 4.7, actual = $(uname -r))"
REQ_KV=470

#
# get_kernel_version -- get kernel version, e.g.: v3.13 => 313
#
function get_kernel_version()
{
	local VER=$(uname -r)
	local N1=$(echo $VER | cut -d'.' -f1)
	local N2=$(echo $VER | cut -d'.' -f2)
	echo $((100 * N1 + N2))
}

# Build all and run tests
cd $WORKDIR
if [ -n "$COMPILER" ]; then
	export CC=$COMPILER
fi

mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=/tmp/strace.ebpf \
		-DCMAKE_BUILD_TYPE=Debug && echo

make && echo

if [ $(get_kernel_version) -ge $REQ_KV ]; then
	sudo mount -t debugfs debugfs /sys/kernel/debug
	# ctest --output-on-failure
	ctest -V && echo
else
	echo $SKIP_MESSAGE && echo
fi

echo make install SKIPPED && echo

cd ..
rm -rf build
mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=/tmp/strace.ebpf \
		-DCMAKE_BUILD_TYPE=Release && echo

make && echo

if [ $(get_kernel_version) -ge $REQ_KV ]; then
	# ctest --output-on-failure
	ctest -V && echo
else
	echo $SKIP_MESSAGE && echo
fi

echo make install SKIPPED && echo

cd ..
rm -rf build
