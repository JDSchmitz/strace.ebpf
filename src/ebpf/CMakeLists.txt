#
# Copyright 2017, Intel Corporation
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

cmake_minimum_required(VERSION 2.8.7)
project(libebpf C)


# eBPF sources
set (BIN_SRCS
	trace.h
	trace_head.c
	template_0_str.c
	template_1_str-sl.c
	template_2_str-sl.c
	template_3_str-sl.c
	template_2_str-ml.c
	template_3_str-ml.c
	template_1_str-const.c
	template_2_str-const.c
	template_3_str-const.c
	template_1_str-full.c
	template_2_str-full.c
	template_3_str-full.c
	template_clone.c
	template_fork.c
	template_vfork.c
	template_exit.c
	template_tracepoints.c
	macro_const_string_mode.c
	macro_full_string_mode.c
	macro_pid_own.c
	macro_pid_ff_disabled.c
	macro_pid_ff_full.c
)


set(BIN_OBJS "")
foreach(FILE_SRC ${BIN_SRCS})
	get_filename_component(FILENAME ${FILE_SRC} NAME)
	get_filename_component(FILEPATH ${FILE_SRC} PATH)
	add_custom_command(OUTPUT
			${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${FILENAME}.o
		WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/${FILEPATH}
		COMMAND ${CMAKE_LINKER} -r -b binary
			-o ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${FILENAME}.o
			${FILENAME})
	list(APPEND BIN_OBJS
		${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${FILENAME}.o)
	#message(STATUS "Linking ${FILE_SRC}")
endforeach(FILE_SRC)


add_library(ebpf STATIC ${BIN_OBJS} ebpf_file_set.c)
set_target_properties(ebpf PROPERTIES
	ARCHIVE_OUTPUT_DIRECTORY ../nondebug)

# XXX libbcc expects multi-treading safety. Currently it's required for
# print_event_cb.o only, although we will apply it for overall application.
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pthread")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_GNU_SOURCE")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wextra")
