#!/usr/bin/env python3

import os
import subprocess as sp
import sys


def eprint(*args, **kwargs):
    """Print to stderr."""
    print(*args, file=sys.stderr, **kwargs)


def msg_err(message: str):
    """Print an error message."""
    eprint(f"\x1b[1;31mError: {message}\x1b[0m")


def msg_fatal(message: str):
    """Print an error message and exit."""
    msg_err(message)
    sys.exit(1)


def msg_warn(message: str):
    """Print a warning message."""
    eprint(f"\x1b[1;36mWarning:\x1b[0m {message}")


def msg_bold(message: str):
    """Print a boldface message."""
    print(f"\x1b[1m{message}\x1b[0m")


def msg_step(message: str):
    """Print a message at the main step level."""
    print(f"\x1b[1;32m\n{message}\x1b[0m")


def msg_substep(message: str):
    """Print a message at the substep level."""
    print(f"\x1b[1m\n{message}\x1b[0m")


def msg_subsubstep(message: str):
    """Print a message at the subsubstep level."""
    print(f"\x1b[4m{message}\x1b[0m")


def is_allowed(string: str):
    """Check whether string contains only allowed characters."""
    allowed = " $/-=':%_"  # allowed non-alphanumeric characters
    return all(not (not c.isalnum() and c not in allowed) for c in string)


def exec_cmd(cmd: str, msg=None, silent=False, safe=False, debug=False):
    """Execute a shell command."""
    if debug:
        eprint(cmd)
    # Protect against injected command
    if not safe and not is_allowed(cmd):
        msg_fatal("Command contains forbidden characters!")
    try:
        if silent:
            sp.run(cmd, shell=True, check=True, stdout=sp.DEVNULL, stderr=sp.DEVNULL)  # nosec B602
        else:
            sp.run(cmd, shell=True, check=True)  # nosec B602
    except sp.CalledProcessError:
        msg_fatal(msg if msg else f"executing: {cmd}")


def get_cmd(cmd: str, msg=None, safe=False, debug=False) -> str:
    """Get output of a shell command."""
    if debug:
        eprint(cmd)
    # Protect against injected command
    if not safe and not is_allowed(cmd):
        msg_fatal("Command contains forbidden characters!")
    try:
        out = sp.check_output(cmd, shell=True, text=True)  # nosec B602
        return out.strip()
    except sp.CalledProcessError:
        msg_fatal(msg if msg else f"executing: {cmd}")
        return ""


def chdir(path: str):
    """Change directory."""
    path_real = get_cmd(f"realpath {path}")
    if not os.path.isdir(path_real):
        msg_fatal(f"{path} does not exist.")
    os.chdir(path_real)


def sizeof_fmt(num, unit="B", base=1000):
    """Express a value in the appropriate order of units."""
    for prefix in ["", "k", "M", "G", "T", "P", "E", "Z"]:
        if abs(num) < base:
            return f"{num:3.1f} {prefix}{unit}"
        num /= base
    return f"{num:.1f} Y{unit}"


exec_cmd("echo Hi")
# exec_cmd("cd ..; pwd; ls -l")
# exec_cmd("ls -l")
# exec_cmd("exit 1")
# exec_cmd("git status")
me = get_cmd("whoami")
print(f"I am {me}")
exec_cmd("git branch")
exec_cmd("echo $USER, $ALIBUILD_WORK_DIR")
