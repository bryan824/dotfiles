# Global Agent Guidelines

## Search & Grep

- Always use `ripgrep` (`rg`) for any grep-like search work — never plain `grep` or `find … | grep`.
- `rg` is faster, respects `.gitignore` by default, and produces cleaner output.
- Examples:
  - Search for a string: `rg "pattern"`
  - Search in specific file types: `rg "pattern" --type ts`
  - Case-insensitive: `rg -i "pattern"`
  - List only file names: `rg -l "pattern"`
  - Include hidden/ignored files when needed: `rg --no-ignore "pattern"`
