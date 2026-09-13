# MOT-26 — Git and Jenkins

## Goal

Review practical Git workflow and Jenkins pipeline fundamentals required for Linux Platform / DevOps work.

## Git Workflow

Basic workflow:

```text
modify files
    ↓
git add
    ↓
git commit
    ↓
git push
```

### git add

Stages selected changes for the next commit.

```bash
git add file.txt
```

### git commit

Saves staged changes as a new commit in the local repository.

```bash
git commit -m "Update configuration"
```

### git push

Sends local commits to the remote repository.

```bash
git push
```

## Branches

A branch allows development of changes independently from another branch such as `main`.

Example:

```bash
git switch -c feature-branch
```

Typical workflow:

```text
main
  \
   feature branch
        ↓
     changes
        ↓
      commit
        ↓
      merge
        ↓
       main
```

## Merge Conflicts

A merge conflict can occur when branches modify conflicting parts of the same file.

Typical resolution:

```text
identify conflict
↓
edit file
↓
choose correct content
↓
git add <file>
↓
complete merge
```

After resolving the conflict, `git add` tells Git that the file has been resolved and stages the result.

## Fetch vs Pull

### git fetch

Downloads information about new commits and branches from the remote repository without integrating them into the current local branch.

```bash
git fetch origin
```

Remote changes can then be inspected:

```bash
git log main..origin/main
git diff main..origin/main
```

### git pull

Downloads remote changes and integrates them into the current branch.

In a common configuration it can be understood as:

```text
fetch + integration
```

The integration may use merge or rebase depending on configuration.

## Merge vs Rebase

### Merge

Combines histories while preserving the existing branch structure.

Useful when working with shared history and when rewriting existing commits is undesirable.

### Rebase

Replays commits on top of another branch.

It can create a cleaner linear history, but it rewrites commits.

A practical rule:

```text
merge  -> preserve shared history
rebase -> useful for organizing local unpublished changes
```

Avoid blindly rebasing shared branches because it rewrites history.

## Jenkins Pipeline

A Jenkins pipeline is an automated sequence of stages used to perform tasks such as building, testing and deploying software.

Typical structure:

```text
Pipeline
├── Stage: Build
│   └── Step: build application/image
├── Stage: Test
│   └── Step: run tests
└── Stage: Deploy
    └── Step: deploy application
```

A pipeline is commonly defined in a:

```text
Jenkinsfile
```

stored in the source code repository.

## Stage vs Step

A **stage** is a logical part of a pipeline.

Examples:

```text
Build
Test
Deploy
```

A **step** is an individual action performed inside a stage.

Examples:

```text
docker build
pytest
shell command
deployment command
```

## Exit Codes

Jenkins can use command and script exit codes to determine whether execution succeeded.

```text
0        -> success
non-zero -> failure
```

This connects directly with Bash:

```bash
echo $?
```

and Python:

```python
sys.exit(0)
sys.exit(1)
```

If a command returns a failure code, Jenkins can mark the step or stage as failed and handle the pipeline accordingly.

## Typical Pipeline

A simple CI/CD flow can look like:

```text
Checkout
↓
Build
↓
Test
↓
Deploy
↓
Verification
```

The exact stages depend on the project.

## Interview Answers

### Git fetch vs pull

> `git fetch` downloads information about new commits and branches from the remote repository without changing my current local branch. `git pull` downloads the remote changes and then integrates them into my current branch, usually by merge or rebase.

### Jenkins pipeline

> A Jenkins pipeline is an automated sequence of stages, and each stage contains individual steps. For example, the pipeline can build an application, run tests and deploy it. Jenkins checks the exit code returned by each command or script. Exit code 0 means success, while a non-zero exit code indicates failure.

## Key Takeaways

- `git add` stages changes.
- `git commit` saves them locally.
- `git push` sends commits to remote.
- `git fetch` retrieves remote changes without integrating them.
- `git pull` retrieves and integrates remote changes.
- merge preserves branch history.
- rebase can create a linear history by replaying commits.
- Jenkins pipelines consist of stages and steps.
- pipelines are commonly defined in a Jenkinsfile.
- exit codes allow Jenkins to detect success or failure.
