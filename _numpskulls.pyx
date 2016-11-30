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


# def build_parser():
#     parser = argparse.ArgumentParser(description=__doc__)
# 
#     parser.add_argument(
#         help='Name of program to run.',
#         type=str,
#         dest='filename'
#     )
# 
#     return parser


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
def execute(program):
    cdef int program_counter = 0
    cdef int data_pointer = 0
    cdef int curr_pus = 0
    cdef int open_bracketopen_brackets = 0
    cdef np.ndarray data = np.zeros(TAPE_SIZE, dtype=DTYPE)

    while program_counter < len(program):
        if program[program_counter] == '+':
            data[data_pointer] += 1
            program_counter += 1
        elif program[program_counter] == '-':
            data[data_pointer] -= 1
            program_counter += 1
        elif program[program_counter] == '>':
            data_pointer = (data_pointer + 1 % TAPE_SIZE)
            program_counter += 1
        elif program[program_counter] == '<':
            data_pointer = (data_pointer - 1 % TAPE_SIZE)
            program_counter += 1
        elif program[program_counter] == ',':
            data[data_pointer] = ord(sys.stdin.read(1))
            program_counter += 1
        elif program[program_counter] == '.':
            print(chr(data[data_pointer]), end='', flush=True)
            program_counter += 1
        elif program[program_counter] == '[':
            if data[data_pointer] == 0:
                curr_pos = program_counter
                open_brackets = 1
                while open_brackets > 0:
                    curr_pos += 1
                    if program[curr_pos] == '[':
                        open_brackets += 1
                    elif program[curr_pos] == ']':
                        open_brackets -= 1
                program_counter = curr_pos
            program_counter += 1
        elif program[program_counter] == ']':
            if data[data_pointer] != 0:
                curr_pos = program_counter - 1
                open_brackets = 1
                while open_brackets > 0:
                    curr_pos -= 1
                    if program[curr_pos] == '[':
                        open_brackets -= 1
                    elif program[curr_pos] == ']':
                        open_brackets += 1
                program_counter = curr_pos
            else:
                program_counter += 1
