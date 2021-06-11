from typing import Optional
import argparse
import os
from pathlib import Path
import sys


import tankerci
import tankerci.bump


def build_and_test() -> None:
    tankerci.run("bundle", "install")
    tankerci.run("bundle", "exec", "rake", "spec")


def deploy(version: str) -> None:
    tankerci.bump.bump_files(version)

    # Note: this commands also re-gerenates the lock as a side-effect since the
    # gemspec has changed - keep this before the git commands
    tankerci.run("bundle", "install")

    # Note: `bundle exec rake build` does not like dirty git repos, so make a
    # commit with the new changes first
    tankerci.git.run(Path.cwd(), "add", "--update", ".")
    tankerci.git.run(Path.cwd(), "commit", "--message", f"Bump to {version}")
    tankerci.run("bundle", "exec", "rake", "build")
    tankerci.run("bundle", "exec", "rake", "push")


def main() -> None:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(title="subcommands", dest="command")

    subparsers.add_parser("build-and-test")

    deploy_parser = subparsers.add_parser("deploy")
    deploy_parser.add_argument("--version", required=True)

    args = parser.parse_args()
    command = args.command

    if command == "build-and-test":
        build_and_test()
    elif command == "deploy":
        deploy(args.version)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
