# Lab 08 - getopts

## Objective

Learn how to build a simple command-line interface (CLI) in Bash using the `getopts` built-in. The script parses command-line options, validates user input, and copies an input file to a specified output location.

## Skills Practiced

- getopts
- Command-line argument parsing
- OPTARG
- case statement
- Input validation
- File existence checks
- Boolean flags
- Default values
- File operations (`cp`)
- Creating directories with `mkdir -p`

## Project Structure

```
08-getopts/
├── cli_tool.sh
├── input/
│   ├── users.txt
│   └── servers.txt
└── output/
```

## Run

```bash
chmod +x cli_tool.sh

./cli_tool.sh -h

./cli_tool.sh -f input/users.txt

./cli_tool.sh -f input/users.txt -v

./cli_tool.sh -f input/users.txt -o output/users_backup.txt

./cli_tool.sh -f input/servers.txt -o output/servers_copy.txt -v
```

## Supported Options

| Option | Description |
|--------|-------------|
| `-f <file>` | Input file (required) |
| `-o <file>` | Output file (optional, defaults to `output/result.txt`) |
| `-v` | Enable verbose mode |
| `-h` | Display help message |

## Example

```bash
./cli_tool.sh -f input/users.txt -o output/users_copy.txt -v
```

Output:

```text
Verbose mode enabled
Input file : input/users.txt
Output file: output/users_copy.txt

File copied successfully.
Saved to: output/users_copy.txt
```

## What I Learned

- Parsing command-line options with `getopts`
- Reading option arguments using `OPTARG`
- Distinguishing between required and optional parameters
- Validating user input before execution
- Checking whether files exist
- Working with boolean flags
- Providing default values for optional arguments
- Creating directories automatically with `mkdir -p`
- Copying files using the `cp` command
- Building a simple and reusable Bash CLI utility
