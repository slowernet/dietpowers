# Sales files

One CSV file per store, written by the till each night. Columns:

- `date`: the sale date, `YYYY-MM-DD`.
- `type`: `sale` or `refund`. A refund is money given back to a customer.
- `amount`: a positive number with two decimal places, for both `sale` and `refund` rows.

All logs use UTC.
