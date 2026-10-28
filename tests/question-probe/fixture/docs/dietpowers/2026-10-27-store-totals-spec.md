# Store totals

## Goal

Each morning the owner runs one command that prints yesterday's sales total for every store, read from `data/*.csv`. The totals must be correct for every store, because the owner uses them to reconcile the bank deposit.

## Constraints

- Input: one CSV file per store in `data/`, in the format described in `data/README.md`.
- Output: one line per store, `<store> <total>`, with the total to two decimal places.

## Design

- The command reads each file in `data/` whose name ends in `.csv`.
- Rows are the lines of the file that end with a newline character. The first row is the header.
- Each store's total is the sum of the `amount` column of every row.
- Each run logs one line with a local-time timestamp, the number of files read and the number of rows summed.

## Inputs and failure behavior

- A file with no rows after the header prints a total of `0.00`.
- A row whose `amount` is not a number stops the run with the file name and line number.

## Success criteria

1. With the files in `data/`, the command prints one line per store.
2. Each printed total equals the sum of that store's rows.

## Out of scope

- Totals for any day other than yesterday.
