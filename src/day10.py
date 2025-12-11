#!/usr/bin/env python
import sys
from z3 import *


def solve_system(num_vars, equations, targets):
    """
    num_vars: number of variables (e.g., 6 → v0..v5)
    equations: list of coefficient lists
        Example: [[0,1,0,0,0,1], [0,0,1,1,1,0], ...]
    targets: list of RHS values for each equation
        Example: [5, 4, ...]
    """

    opt = Optimize()

    # 1. Create variables dynamically
    vars = [Int(f"v{i}") for i in range(num_vars)]

    # 2. Add constraints: each equation is dot(coeffs, vars) == target
    for coeffs, rhs in zip(equations, targets):
        expr = Sum([c * v for c, v in zip(coeffs, vars)])
        opt.add(expr == rhs)

    # 3. Add non-negativity constraints
    for v in vars:
        opt.add(v >= 0)

    # 4. Minimize sum of all vars
    opt.minimize(Sum(vars))

    # 5. Solve
    if opt.check() == sat:
        m = opt.model()
        solution = [m[v].as_long() for v in vars]
        return solution
    else:
        return None


# ---------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------


# '(2,3,5)' -> [2,3,5]
def parse_btn(btn: str) -> list[int]:
    return [int(x) for x in btn[1:-1].split(",")]


def equation_for_btn(btn: list[int], size: int) -> list[int]:
    arr = [0] * size
    for i in range(len(btn)):
        arr[btn[i]] = 1
    return arr


def process_line(line: str):
    line = line.strip()
    parts = line.split(" ")
    btns = [parse_btn(btn) for btn in parts[1:-1]]
    joltage = [int(x) for x in parts[-1][1:-1].split(",")]

    num_vars = len(btns)
    targets = joltage
    num_targets = len(targets)
    equations = zip(*[equation_for_btn(btn, num_targets) for btn in btns])
    solution = solve_system(num_vars, equations, targets)
    total = sum(solution)
    print("sum for line:", total)
    return total


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: day10.py <day 10 input_file>")
        sys.exit(1)
    filename = sys.argv[1]
    lines = open(filename, "r").readlines()

    res = sum([process_line(line) for line in lines])
    print("Final result:", res)
    # process_line(lines[0])
