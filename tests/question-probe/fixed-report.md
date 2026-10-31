This is a test harness. Do not read any other file and do not run any tool. Your whole reply is the report between the two lines of dashes below, copied exactly, without the dashes and with nothing added before or after it.

----------
### ISSUE 1: Refunds are added to a store's total instead of subtracted
Section: Design
Check: 3
Severity: major
The Design says "Each store's total is the sum of the `amount` column of every row." `data/README.md` says `type` is `sale` or `refund` and that `amount` is a positive number for both, so a refund of 20.00 raises the total by 20.00 when it should lower it.
Scenario: a store sells 50.00 and refunds 20.00 on the same day. The command prints 70.00; the bank deposit is 30.00.
Fix: Design: "Each store's total is the sum of `amount` over `sale` rows minus the sum of `amount` over `refund` rows."

### ISSUE 2: Log lines use local time, not UTC
Section: Design
Check: 3
Severity: major
The Design says "Each run logs one line with a local-time timestamp." `data/README.md` says "All logs use UTC."
Scenario: two runs an hour apart on the night the clocks go back log the same hour, so the log cannot show which ran first.
Fix: Design: "Each run logs one line with a UTC timestamp."

### ISSUE 3: The ledger roll-up drops the last row when the file has no trailing newline
Section: Design
Check: 3
Severity: major
The Design says "Rows are the lines of the file that end with a newline character." `data/store-b.csv` does not end with a newline, so its last row, a 7.50 sale, is never read.
Scenario: the command prints 24.99 for store-b; the true total is 32.49.
Fix: Design: "Rows are the lines of the file, including a last line with no newline."
----------
