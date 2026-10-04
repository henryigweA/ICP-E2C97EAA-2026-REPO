# Linux & Git Notes

## Linux fundamentals practised
`ls -la`, `chmod +x`, `find -mtime`, `tar -czf/-tzf`, `grep`, `tee -a`, `crontab -e`, exit codes (`$?`), pipes and redirection (`2>&1`), `/tmp` lock files.

## Git advanced usage practised
- `git rm -r --cached <path>` to untrack files accidentally committed (see error #9 in the error log)
- `.gitignore` for `.venv/`, `.terraform/`, `*.tfstate`
- `git commit --amend`, `git rebase -i` to tidy history, `git revert` for safe undo
- Branching: feature branches, merge vs. rebase
