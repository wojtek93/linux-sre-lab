# MOT-25 — Bash vs Python

## Goal

Understand when Bash is a better choice for automation and when Python is more appropriate.

The goal is not to decide that one language is always better, but to choose the simplest tool that fits the task while considering complexity, maintainability and future requirements.

## Bash — When to Use It

Bash is a good choice for:

- simple Linux administration tasks
- executing system commands
- checking service status
- collecting disk and memory information
- chaining commands
- simple SSH-based automation
- short operational scripts
- jobs scheduled with cron

Example:

```bash
systemctl status nginx
df -h
free -h
uptime
```

For a simple task such as restarting a service, checking its status and saving the result, Bash is usually the natural choice.

## Python — When to Use It

Python is a better choice when automation requires:

- more complex logic
- file parsing
- structured data processing
- JSON or CSV manipulation
- exception handling
- API integration
- retries
- report generation
- larger and more maintainable programs

Examples:

- parsing large log files
- generating reports
- processing JSON responses
- integrating with REST APIs
- handling multiple failure scenarios

## Practical Example

### Scenario A

Restart a Linux service, check its status and save the result.

**Choice: Bash**

Reason: Bash is convenient for executing Linux commands and simple system administration tasks.

### Scenario B

Parse 50,000 log lines, extract data, handle exceptions and generate a report.

**Choice: Python**

Reason: Python provides better tools for parsing, error handling and complex program logic.

## Scaling an Automation

A simple solution for collecting information from Linux servers could use:

```text
Bash + SSH + cron
```

For example, Bash could collect:

- disk usage
- memory usage
- service status

If the environment grows and new requirements appear, such as:

- hundreds of servers
- JSON processing
- API integration
- retries
- complex error handling
- report generation

the main logic may be better implemented in Python.

Bash can still be used as a small wrapper around system commands if needed.

## Do Not Rewrite Working Code Without a Reason

A working Bash script should not automatically be rewritten in Python.

Before rewriting it, consider:

- Is the current solution reliable?
- Is it readable?
- Is it maintainable?
- Is it easy to test?
- Are new requirements making the logic too complex?
- What risk does the rewrite introduce?

If the existing Bash solution works well and meets the requirements, rewriting it may provide little benefit while introducing additional risk.

## Interview Answer

> I would use Bash for simple system administration tasks, such as checking running services, disk usage, executing Linux commands or chaining commands together. I would use Python when the automation requires more complex logic, file or data parsing, error handling, API integration or report generation. In general, I choose the simplest tool that fits the task, but I also consider how easy the solution will be to maintain and extend.

## Senior-Level Takeaway

The decision should be based on engineering requirements rather than assuming one language is always better.

Consider:

```text
task complexity
readability
maintainability
extensibility
testing
error handling
risk of change
future requirements
```

A useful principle:

> Choose the simplest tool that solves the problem reliably and remains maintainable as the solution grows.

## Useful Vocabulary

- **maintainability** — ease of maintaining the solution
- **extensibility** — ease of extending the solution
- **wrapper** — a small layer around another command or program
- **error handling** — handling failures in a controlled way
- **structured data** — structured formats such as JSON or CSV
- **reliability** — ability to work consistently and correctly

## What I Practiced

- choosing between Bash and Python
- Bash for Linux system administration
- Python for parsing and complex logic
- maintainability and extensibility
- scaling automation
- combining Bash and Python
- evaluating the risk of rewriting working software
- explaining technical decisions during an interview
