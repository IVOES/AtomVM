#
# This file is part of AtomVM.
#
# Copyright 2023 Paul Guyot <pguyot@kallisys.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0 OR LGPL-2.1-or-later
#

add_library(esp32_test_modules)

ExternalProject_Add(HostAtomVM
    SOURCE_DIR ../../../../../../../../
)

function(compile_erlang module_name)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${module_name}.beam"
        COMMAND erlc ${CMAKE_CURRENT_SOURCE_DIR}/${module_name}.erl
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${module_name}.erl"
        COMMENT "Compiling ${module_name}.erl"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )

    set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_CURRENT_BINARY_DIR}/${module_name}.beam")
endfunction()

compile_erlang(test_socket)
compile_erlang(test_time_and_processes)

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/esp32_test_modules.avm"
    COMMAND HostAtomVM-prefix/src/HostAtomVM-build/tools/packbeam/PackBEAM -i esp32_test_modules.avm
        HostAtomVM-prefix/src/HostAtomVM-build/libs/atomvmlib.avm
        test_socket.beam
        test_time_and_processes.beam
    DEPENDS
        HostAtomVM
        "${CMAKE_CURRENT_BINARY_DIR}/test_socket.beam"
        "${CMAKE_CURRENT_BINARY_DIR}/test_time_and_processes.beam"
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    VERBATIM
)

set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_CURRENT_BINARY_DIR}/esp32_test_modules.avm")

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/esp32_test_modules.avm.S
    COMMAND "${CMAKE_COMMAND}"
    -D "DATA_FILE=${CMAKE_CURRENT_BINARY_DIR}/esp32_test_modules.avm"
    -D "SOURCE_FILE=${CMAKE_CURRENT_BINARY_DIR}/esp32_test_modules.avm.S"
    -D "FILE_TYPE=BINARY"
    -P "${idf_path}/tools/cmake/scripts/data_file_embed_asm.cmake"
    MAIN_DEPENDENCY "${CMAKE_CURRENT_BINARY_DIR}/esp32_test_modules.avm"
    DEPENDS "${idf_path}/tools/cmake/scripts/data_file_embed_asm.cmake"
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    VERBATIM
)

set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_CURRENT_BINARY_DIR}/esp32_test_modules.avm.S")

target_sources(esp32_test_modules PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/esp32_test_modules.avm.S)
