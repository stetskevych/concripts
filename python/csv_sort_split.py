#!/usr/bin/env python3

# By Vyacheslav Stetskevych, 2017

import os
import csv
import operator
import argparse

parser = argparse.ArgumentParser(description='Sort CSV by a master column, split to smaller CSV files. Make sure groups of values in the master column do not end up in different files.')
parser.add_argument("input_file",
                    help="the original CSV file to be split")
parser.add_argument("-e", "--file-encoding", default='iso-8859-1',
                    help="the encoding of the input and output files; default=iso-8859-1")
parser.add_argument("-s", "--sort-by", default='INVOICE_NUMBER',
                    help="CSV column name by which to sort; default=INVOICE_NUMBER")
parser.add_argument("-l", "--split-lines", default='200', type=int,
                    help="number of lines to attempt to split at. will be inflated, if the --sort-by parameter is the same on the file boundary; default=200")
parser.add_argument("-v", "--verbose", action="store_true",
                    help="be verbose")
args = parser.parse_args()

INPUT_FILE = args.input_file
MASTER_COLUMN_NAME = args.sort_by
ENCODING = args.file_encoding
SPLIT_LINES = args.split_lines
verbose = args.verbose

FILE_BASENAME, FILE_EXTENSION = os.path.splitext(os.path.basename(INPUT_FILE))

with open(INPUT_FILE, 'r', newline='', encoding=ENCODING) as input_file:
    reader = csv.reader(input_file, delimiter=',')
    header = next(reader)
    master_column_index = header.index(MASTER_COLUMN_NAME)
    sorted_csv_data = sorted(reader, key=operator.itemgetter(master_column_index))

total_rows = len(sorted_csv_data)
current_row_num = 0
last_row_num = total_rows - 1 # because arrays are 0-indexed
output_file_suffix = 0

print("Reading from " + INPUT_FILE + ", sorting by " + MASTER_COLUMN_NAME + ", encoding is " + ENCODING + ", trying to split at " + str(SPLIT_LINES) + " lines. Total rows is " + str(total_rows) + ", last row number is " + str(last_row_num)) if verbose else None

# here we split the file, making sure blocks of data in MASTER_COLUMN_NAME end up in the same file
while current_row_num < last_row_num:
    current_csv_data = []
    output_file_suffix += 1

    print("===> Current file index is " + str(output_file_suffix) + ", starting row number is " + str(current_row_num) ) if verbose else None

    # get a fixed block of lines into a temporary array
    for current_row_num in range(current_row_num, current_row_num + SPLIT_LINES):
        if current_row_num <= last_row_num: # not reached EOF?
            print("#1 Processing row " + str(current_row_num) + ", master column value is " + str(sorted_csv_data[current_row_num][master_column_index]) ) if verbose else None
            current_csv_data.append(sorted_csv_data[current_row_num])
        else:
            current_row_num -= 1
            break # don't count all the way to range end

    # check if we're on the egde of an invoice number block or we need to fetch additional lines
    while current_row_num < last_row_num and sorted_csv_data[current_row_num][master_column_index] == sorted_csv_data[current_row_num + 1][master_column_index]:
        # this also covers the case of writing the last row, no need for additional checks
        current_row_num += 1
        print("#2 Processing row " + str(current_row_num) + ", master column value is " + str(sorted_csv_data[current_row_num][master_column_index])) if verbose else None
        current_csv_data.append(sorted_csv_data[current_row_num])

    # write the accumulated array to file here
    current_output_file = FILE_BASENAME + "_" + str(output_file_suffix).zfill(4) + FILE_EXTENSION
    with open(current_output_file, 'w', newline='', encoding=ENCODING) as output_file:
        writer = csv.writer(output_file, delimiter=',')
        writer.writerow(header)
        for row in current_csv_data:
            writer.writerow(row)

    print("===> Wrote file with index " + str(output_file_suffix) + ", ending row number was " + str(current_row_num) + ", total rows (not including header) in the file: " + str(len(current_csv_data)) ) if verbose else None

    # if we get to have another iteration, start from the next row
    current_row_num += 1

### check execution
# rm -f *00* && ./csv_sort_split.py --verbose test.csv > log && wc -l *00* && wc -l test.csv
# review numbers, compare with log
