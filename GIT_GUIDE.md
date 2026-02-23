# Git & GitHub Quick Guide

## Branches

| Branch | Purpose |
|--------|---------|
| `main` | Live, stable code. Never work here directly. |
| `develop` | Where all work lands before going to `main`. |
| `feature/...` | Your working branch. Always branch off `develop`. |

---

## Starting New Work

```bash
git checkout develop
git pull                          # get latest
git checkout -b feature/my-thing  # create your branch
```

---

## Saving Work

```bash
git add <file>          # stage a specific file
git add .               # stage everything
git commit -m "message" # commit
git push                # push (first time: git push -u origin feature/my-thing)
```

---

## Opening a PR

```bash
gh pr create --base develop --title "..." --body "..."
```

Or open it on GitHub. Always target **`develop`**, not `main`.

---

## Merging a PR

```bash
gh pr merge <number> --merge
```

---

## Syncing After a Merge

After a PR lands on `develop`, sync your local:

```bash
git checkout develop
git pull
```

To get `main` up to date after merging `develop` → `main`:

```bash
git checkout main
git pull
git checkout develop  # switch back
```

---

## Common Commands

| What | Command |
|------|---------|
| See current status | `git status` |
| See recent commits | `git log --oneline -10` |
| Switch branch | `git checkout <branch>` |
| See all branches | `git branch -a` |
| Discard unstaged changes | `git restore <file>` |
| Undo last commit (keep changes) | `git reset HEAD~1` |

---

## Branch Naming

```
feature/retry-logic
fix/wavespeed-timeout
docs/update-readme
chore/bump-dependencies
```

---

## Full Feature Flow (start to finish)

```bash
git checkout develop && git pull
git checkout -b feature/my-feature

# ... do work ...

git add .
git commit -m "Add my feature"
git push -u origin feature/my-feature

gh pr create --base develop --title "Add my feature" --body "..."
gh pr merge <number> --merge

git checkout develop && git pull
```
