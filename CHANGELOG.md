## Hobble 0.1.0 (04/08/2014) ##

*   The #schedule methods can take a block
    which is re-evaluated as the schedule
    after each run.

*   Hobble::Schedule can weight groups differently
    using the #weight! method, which affects the
    rate at which time debt accumulates.

*   Schedules can now optionally run only `n`
    items, by calling `run(n) { ... }`.

## Hobble 0.0.1 (02/08/2014) ##

*   Initial Release.
