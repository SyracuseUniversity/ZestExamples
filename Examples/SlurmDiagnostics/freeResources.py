#!/usr/bin/env python3
"""Summarize free CPUs, memory and GPUs on Zest.

Reads the output of

    scontrol show node --oneliner

either from standard input or by running the command itself, and prints a
table of total and available resources per partition, plus the largest free
block of CPUs.  Only the Python standard library is used.

Usage:
    python3 freeResources.py                 # queries scontrol itself
    scontrol show node -o | python3 freeResources.py -
    python3 freeResources.py --partition gpu,gpu_zone2
"""

import argparse
import re
import subprocess
import sys
from collections import defaultdict


def parse_tres(spec):
    """Turn 'cpu=128,mem=489730M,gres/gpu=4' into {'cpu': 128, 'mem': 489730, 'gpu': 4}."""
    result = {}
    if not spec:
        return result
    for item in spec.split(","):
        if "=" not in item:
            continue
        key, value = item.split("=", 1)
        key = key.replace("gres/", "")
        if key.startswith("gpu:"):        # gres/gpu:a40=4 style
            key = "gpu"
        match = re.match(r"([0-9.]+)([KMGT]?)", value)
        if not match:
            continue
        number = float(match.group(1))
        unit = match.group(2)
        if key == "mem":                  # normalise memory to MB
            number *= {"": 1, "K": 1 / 1024, "M": 1, "G": 1024, "T": 1024 * 1024}[unit]
        result[key] = result.get(key, 0) + number
    return result


def parse_nodes(text):
    nodes = []
    for line in text.splitlines():
        if not line.startswith("NodeName="):
            continue
        fields = dict(re.findall(r"(\w+)=(\S*)", line))
        cfg = parse_tres(fields.get("CfgTRES", ""))
        # Configured GPUs are reported in the Gres field, as gpu:4 or gpu:a40:4(S:0-1)
        gpus = re.findall(r"gpu(?::[^:,()]+)?:(\d+)", fields.get("Gres", ""))
        if gpus:
            cfg["gpu"] = sum(int(g) for g in gpus)
        nodes.append({
            "name": fields.get("NodeName"),
            "partitions": fields.get("Partitions", "").split(","),
            "state": fields.get("State", ""),
            "cfg": cfg,
            "alloc": parse_tres(fields.get("AllocTRES", "")),
        })
    return nodes


def gpus_used_by_running_jobs():
    """Return {partition: gpus} for all running jobs, from squeue."""
    out = subprocess.run(["squeue", "-h", "-t", "RUNNING", "-o", "%P %D %b"],
                         capture_output=True, text=True, check=True).stdout
    used = defaultdict(int)
    for line in out.splitlines():
        parts = line.split()
        if len(parts) < 3:
            continue
        partition, nodes, gres = parts[0], int(parts[1]), parts[2]
        match = re.search(r"gpu(?::[^:,()]+)?:(\d+)", gres)
        if match:
            used[partition] += int(match.group(1)) * nodes
    return used


def usable(node):
    state = node["state"].upper()
    return not any(bad in state for bad in ("DOWN", "DRAIN", "NOT_RESPONDING", "MAINT", "RESERVED"))


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--partition", "-p", help="comma separated list of partitions to include")
    parser.add_argument("source", nargs="?", default=None,
                        help="'-' to read 'scontrol show node -o' output from standard input, "
                             "otherwise scontrol is run directly")
    args = parser.parse_args()

    if args.source == "-":
        text = sys.stdin.read()
        gpus_in_use = None
    else:
        text = subprocess.run(["scontrol", "show", "node", "--oneliner"],
                              capture_output=True, text=True, check=True).stdout
        gpus_in_use = gpus_used_by_running_jobs()

    wanted = set(args.partition.split(",")) if args.partition else None
    totals = defaultdict(lambda: defaultdict(float))
    largest = {}

    for node in parse_nodes(text):
        if not usable(node):
            continue
        for part in node["partitions"]:
            if wanted and part not in wanted:
                continue
            for key in ("cpu", "mem", "gpu"):
                cfg = node["cfg"].get(key, 0)
                used = node["alloc"].get(key, 0)
                totals[part][key + "_total"] += cfg
                totals[part][key + "_free"] += max(cfg - used, 0)

    # Zest's accounting does not record GPUs in AllocTRES, so when running live
    # count the GPUs held by running jobs instead.
    if gpus_in_use is not None:
        for part, used in gpus_in_use.items():
            if part in totals:
                totals[part]["gpu_free"] = max(totals[part]["gpu_total"] - used, 0)
            free_cpus = node["cfg"].get("cpu", 0) - node["alloc"].get("cpu", 0)
            if free_cpus > largest.get(part, (0, 0, ""))[0]:
                largest[part] = (free_cpus, node["cfg"].get("cpu", 0), node["name"])

    print(f"{'Partition':<16}{'CPUs free/total':>18}{'Memory (GB) free/total':>26}{'GPUs free/total':>18}")
    for part in sorted(totals):
        t = totals[part]
        gpus = f"{int(t['gpu_free'])}/{int(t['gpu_total'])}" if t["gpu_total"] else "-"
        print(f"{part:<16}{int(t['cpu_free']):>8}/{int(t['cpu_total']):<9}"
              f"{int(t['mem_free'] / 1024):>12}/{int(t['mem_total'] / 1024):<13}{gpus:>18}")

    print()
    for part in sorted(largest):
        free, total, name = largest[part]
        print(f"Largest free block of CPUs in {part}: {int(free)} on {name} ({int(total)} CPUs)")


if __name__ == "__main__":
    main()
