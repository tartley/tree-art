#!/usr/bin/env python3
import argparse
import dataclasses
import math
import random
import sys

import drawsvg


### generation

T4 = math.tau / 4
T32 = math.tau / 32


@dataclasses.dataclass
class Vec:
    x: float | int
    y: float | int

    def offset(self, angle, distance):
        """A new Vec, offset from self by the given angle and distance"""
        return Vec(
            self.x + distance * math.cos(angle),
            self.y - distance * math.sin(angle),
        )


Display = Vec(1920, 1080)


def sky():
    sky = drawsvg.LinearGradient(0, 0, 0, Display.y)
    sky.add_stop(0, "#38f")
    sky.add_stop(1, "#bdf")
    return drawsvg.Rectangle(0, 0, Display.x, Display.y, fill=sky)


def branch(args, start, *, direction, length, width, iteration=0):
    if iteration > args.iterations:
        return
    s1 = start.offset(direction - T4, width)
    s2 = start.offset(direction + T4, width)
    end = start.offset(direction, length)
    e1 = end.offset(direction - T4, width * 2 / 3)
    e2 = end.offset(direction + T4, width * 2 / 3)
    yield drawsvg.Lines(
        s1.x,
        s1.y,
        s2.x,
        s2.y,
        e2.x,
        e2.y,
        e1.x,
        e1.y,
        close=True,
        fill="#210",
        stroke="invis",
    )
    for bend in [+1, -1]:
        yield from branch(
            args,
            start=end,
            direction=direction + bend * random.triangular(T32, 5 * T32),
            length=length * random.uniform(0.6, 0.9),
            width=width * 2 / 3,
            iteration=iteration + 1,
        )


def get_items(args):
    yield sky()
    yield from branch(
        args,
        Vec(Display.x / 2, Display.y),
        direction=T4,
        length=300,
        width=100,
    )


def draw(args):
    drawing = drawsvg.Drawing(Display.x, Display.y)
    for item in get_items(args):
        drawing.append(item)
    if args.output == '-':
        print(drawing.as_svg())
    else:
        drawing.save_svg(args.output)


### cmdline


def parse_cmdline(args):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-s",
        "--seed",
        type=int,
        default=random.randrange(1_000_000),
        help="Give a seed to generate the same tree over again",
    )
    parser.add_argument(
        "-i",
        "--iterations",
        type=int,
        default=15,
        help="How many times the branches should split",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        default="tree-art.svg",
        help="Name of the output file. Use '-' for stdout",
    )
    args = parser.parse_args()
    print(
        " ".join(f"{k}={v}" for k, v in vars(args).items()),
        file=sys.stderr,
    )
    return args


### main


def main():
    args = parse_cmdline(sys.argv)
    draw(args)


if __name__ == "__main__":
    main()
