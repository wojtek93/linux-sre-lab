# Lab 09 - Exit Codes

## Objective

Learn how to work with exit codes in Bash by executing multiple scripts, checking their return values, and stopping the workflow when a critical step fails.

## Skills Practiced

- Exit codes
- `$?`
- `exit`
- `if/else`
- Sequential workflow execution
- Error handling
- Conditional execution
- Script chaining

## Project Structure

```
09-exit-codes/
├── workflow.sh
├── README.md
└── scripts/
    ├── check_service.sh
    ├── check_disk.sh
    └── deploy_app.sh
```

## Run

```bash
chmod +x workflow.sh
chmod +x scripts/*.sh

./workflow.sh
```

## Example Output

```text
Starting workflow...

Checking service status...
Service is running.
Service check passed.

Checking disk usage...
Disk usage is acceptable.
Disk check passed.

Deploying application...
Application deployed successfully.
Deployment completed successfully.

Workflow completed successfully.
```

## Simulating a Failure

Edit one of the helper scripts, for example:

```bash
vim scripts/check_disk.sh
```

Change:

```bash
exit 0
```

to:

```bash
exit 1
```

Run the workflow again:

```bash
./workflow.sh
```

The workflow will stop immediately after the failed step.

Check the returned exit code:

```bash
echo $?
```

## What I Learned

- Understanding Unix exit codes
- Capturing the exit status using `$?`
- Distinguishing between success (`0`) and failure (non-zero)
- Stopping script execution when a critical step fails
- Building a simple sequential workflow
- Using exit codes for basic error handling
