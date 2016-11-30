'Simple Brainfuck interpreter.'
from __future__ import print_function
import numpy as np
import sys
import os

cimport numpy as np
cimport cython

DTYPE = np.int
ctypedef np.int_t DTYPE_t

INSTRUCTION_SET = '+-<>,.[]'
cdef np.int TAPE_SIZE = 30000


def load_program(bf_filename):
    with open(bf_filename) as fd:
        program = fd.read()

    program = [
        instruction
        for instruction in program
        if instruction in INSTRUCTION_SET
    ]

    return program

def main(bf_filename):
    assert os.path.isfile(bf_filename)
    program = load_program(bf_filename)
    execute(program)

@cython.boundscheck(False)
def execute(program_str):
    cdef int program_len = len(program_str)
    cdef np.ndarray program = np.array(
        list(map(ord, program_str)), dtype=DTYPE
    )

    cdef int program_counter = 0
    cdef int data_pointer = 0
    cdef int curr_pus = 0
    cdef int open_bracket = 0
    cdef np.ndarray data = np.zeros(TAPE_SIZE, dtype=DTYPE)

    cdef np.ndarray start_to_end = np.ones(program_len, dtype=DTYPE) * -1
    cdef np.ndarray end_to_start = np.ones(program_len, dtype=DTYPE) * -1

    while program_counter < program_len:
        if program[program_counter] == ord('+'):
            data[data_pointer] += 1
            program_counter += 1
        elif program[program_counter] == ord('-'):
            data[data_pointer] -= 1
            program_counter += 1
        elif program[program_counter] == ord('>'):
            data_pointer = (data_pointer + 1 % TAPE_SIZE)
            program_counter += 1
        elif program[program_counter] == ord('<'):
            data_pointer = (data_pointer - 1 % TAPE_SIZE)
            program_counter += 1
        elif program[program_counter] == ord(','):
            data[data_pointer] = ord(sys.stdin.read(1))
            program_counter += 1
        elif program[program_counter] == ord('.'):
            print(chr(data[data_pointer]), end='', flush=True)
            program_counter += 1
        elif program[program_counter] == ord('['):
            if data[data_pointer] == 0:
                if start_to_end[program_counter] != -1:
                    program_counter = start_to_end[program_counter]
                else:
                    curr_pos = program_counter
                    open_brackets = 1
                    while open_brackets > 0:
                        curr_pos += 1
                        if program[curr_pos] == ord('['):
                            open_brackets += 1
                        elif program[curr_pos] == ord(']'):
                            open_brackets -= 1
                    start_to_end[program_counter] = curr_pos
                    program_counter = curr_pos
            program_counter += 1
        elif program[program_counter] == ord(']'):
            if data[data_pointer] != 0:
                if end_to_start[program_counter] != -1:
                    program_counter = end_to_start[program_counter]
                else:
                    curr_pos = program_counter - 1
                    open_brackets = 1
                    while open_brackets > 0:
                        curr_pos -= 1
                        if program[curr_pos] == ord('['):
                            open_brackets -= 1
                        elif program[curr_pos] == ord(']'):
                            open_brackets += 1
                    end_to_start[program_counter] = curr_pos
                    program_counter = curr_pos
            else:
                program_counter += 1
