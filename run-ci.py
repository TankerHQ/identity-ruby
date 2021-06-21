import argparse
from pathlib import Path
import subprocess
import sys

import tbump
import tbump.config


def version_from_git_tag(git_tag: str) -> str:
    prefix = "v"
    assert git_tag.startswith(prefix), "tag should start with %s" % prefix
    cfg_file = tbump.config.get_config_file(Path.cwd())
    tbump_cfg = cfg_file.get_config()
    regex = tbump_cfg.version_regex
    version = git_tag[len(prefix) :]  # noqa
    match = regex.match(version)
    assert match, "Could not parse %s as a valid tag" % git_tag
    return version


def deploy(version: str) -> None:
    tbump.bump_files(version_from_git_tag(version))

    # Note: this commands also re-gerenates the lock as a side-effect since the
    # gemspec has changed - keep this before the git commands
    subprocess.run(["bundle", "install"], check=True)

    # Note: `bundle exec rake build` does not like dirty git repos, so make a
    # commit with the new changes first
    subprocess.run(["git", "add", "--update", "."], cwd=Path.cwd(), check=True)
    subprocess.run(
        ["git", "commit", "--message", f"Bump to {version}"],
        cwd=Path.cwd(),
        check=True,
    )

    subprocess.run(["bundle", "exec", "rake", "build"], check=True)
    subprocess.run(["bundle", "exec", "rake", "push"], check=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(title="subcommands", dest="command")

    deploy_parser = subparsers.add_parser("deploy")
    deploy_parser.add_argument("--version", required=True)

    args = parser.parse_args()
    command = args.command

    if command == "deploy":
        deploy(args.version)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
