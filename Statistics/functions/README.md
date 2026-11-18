# Functions

No new custom analysis helpers have been introduced. The original script is kept close to source, and ordinary `saveRDS()`, `write_csv()`, and `ggsave()` calls are used instead.

**Known original dependency:** `summarySE()` is supplied by `Rmisc`, which has been added to the dependency list only; its calculations have not been rewritten.
