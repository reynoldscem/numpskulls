'Simple Brainfuck interpreter.'
from readchar import readchar
import numpy as np
import argparse
import sys
import os

INSTRUCTION_SET = '+-<>,.[]'
TAPE_SIZE = 30000


def build_parser():
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument(
        help='Name of program to run.',
        type=str,
        dest='filename'
    )

    return parser


def load_program(bf_filename):
    with open(bf_filename) as fd:
        program = fd.read()

    program = [
        instruction
        for instruction in program
        if instruction in INSTRUCTION_SET
    ]

    return program


def inc(program, program_counter, data, data_pointer):
    data[data_pointer] += 1
    program_counter += 1
    return program, program_counter, data, data_pointer


def dec(program, program_counter, data, data_pointer):
    data[data_pointer] -= 1
    program_counter += 1
    return program, program_counter, data, data_pointer


def data_pointer_inc(program, program_counter, data, data_pointer):
    data_pointer = (data_pointer + 1 % TAPE_SIZE)
    program_counter += 1
    return program, program_counter, data, data_pointer


def data_pointer_dec(program, program_counter, data, data_pointer):
    data_pointer = (data_pointer - 1 % TAPE_SIZE)
    program_counter += 1
    return program, program_counter, data, data_pointer


def read_in(program, program_counter, data, data_pointer):
    data[data_pointer] = ord(sys.stdin.read(1))
    program_counter += 1
    return program, program_counter, data, data_pointer


def print_out(program, program_counter, data, data_pointer):
    print(chr(data[data_pointer]), end='', flush=True)
    program_counter += 1
    return program, program_counter, data, data_pointer


def loop_start(program, program_counter, data, data_pointer):
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
    return program, program_counter, data, data_pointer


def loop_end(program, program_counter, data, data_pointer):
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
    return program, program_counter, data, data_pointer


def main(bf_filename):
    assert os.path.isfile(bf_filename)
    program = load_program(bf_filename)

    program_counter = 0
    data_pointer = 0
    data = np.zeros(TAPE_SIZE, dtype=np.uint8)

    instruction_lookup = {
        '+': inc,
        '-': dec,
        '>': data_pointer_inc,
        '<': data_pointer_dec,
        ',': read_in,
        '.': print_out,
        '[': loop_start,
        ']': loop_end
    }

    while program_counter < len(program):
        instruction_function = instruction_lookup[program[program_counter]]
        program, program_counter, data, data_pointer = instruction_function(
            program, program_counter, data, data_pointer
        )


if __name__ == '__main__':
    args = build_parser().parse_args()
    main(args.filename)
