import argparse
import re
import logging
import json

from dataclasses import dataclass
from pathlib import Path

logging.basicConfig(level=logging.INFO)


@dataclass
class Args:
    log_path: Path


def parse_args() -> Args:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--log_path", type=Path, required=True, help="Output of terraform execution after setting TF_LOG=trace"
    )
    return parser.parse_args()


special_services = {"Secrets Manager": "secretsmanager", "Auto Scaling": "autoscaling", "CloudWatch Logs": "logs"}

regex_string_request = r"rpc\.method=(?P<method>\S+).*rpc\.service=(?P<service>\S+)"
regex_string_response = r"rpc\.service=(?P<service>\S+).*rpc\.method=(?P<method>\S+)"
regex_string_special_request = r"rpc\.service=\"(?P<service>[^\"]+)\".*rpc\.method=(?P<method>\S+)"
regex_string_special_response = r"rpc\.method=(?P<method>\S+).*rpc\.service=\"(?P<service>[^\"]+)\""
timestamp_pattern = r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[+-]\d{4}"


def format_log(log_path: Path) -> list:
    with open(log_path, "r", encoding="utf-8") as logs:
        lines = logs.readlines()
    formatted_lines = []
    for line in lines:
        matched = re.match(timestamp_pattern, line)
        if matched:
            formatted_lines.append(line.strip("\n").replace("\n", ""))
        elif len(formatted_lines) > 0:
            formatted_lines[-1] = f"{formatted_lines[-1]} {line}".strip("\n").replace("\n", " ")
    return formatted_lines


def create_action(match: dict) -> str:
    service = special_services.get(match["service"], match["service"]).lower()
    return f"{service}:{match['method']}"


def extract_actions(logs: list) -> set:
    actions = set()
    for line in logs:
        match = re.search(regex_string_special_request, line)
        if match:
            actions.add(create_action(match))
            continue
        match = re.search(regex_string_special_response, line)
        if match:
            actions.add(create_action(match))
            continue
        match = re.search(regex_string_request, line)
        if match:
            actions.add(create_action(match))
            continue
        match = re.search(regex_string_response, line)
        if match:
            actions.add(create_action(match))
            continue
    return actions


def create_policy(actions: set, output_path: Path) -> None:
    policy = {
        "Version": "2012-10-17",
        "Statement": [{"Effect": "Allow", "Action": list(sorted(actions)), "Resource": "*"}],
    }
    with open(output_path, "w+", encoding="utf-8") as output:
        logging.info("Outputting to %s", output_path)
        json.dump(policy, output, indent=4)


def main(args: Args):
    logs = format_log(args.log_path)
    actions = extract_actions(logs)
    output_path = Path(f"{args.log_path.parent}\\{args.log_path.stem}_output.json")
    create_policy(actions, output_path)


if __name__ == "__main__":
    parsed_arguments = parse_args()
    main(parsed_arguments)
