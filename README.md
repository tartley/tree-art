# Tree art

Python script to show my kiddo how to generate an SVG tree using recursive
function calls, inspired by the trees we saw on our hike earlier today, looking
great against the first blue skies of the year.

![./tree-art.py -i18](tree-art.lossy.webp)

## Installation

I wrote it on Linux, Pop!OS 22.04, using Python3.13, but I guess it'll run
on anything kinda similar.

First, install dependencies:

```bash
make setup
```

This installs system dependencies right here on your host (sorry), using `sudo
apt install ...`, so you'll need to enter a password (sorry). It also populates
a Python virtualenv.

## Usage

Run the script to draw an SVG tree:

```bash
make svg
```

This chooses some default parameters, notably `-i18`, i.e. 18 iterations of
branches (I guess I mean recursion depth, not iterations, ohwell), which
generates 2^18 branches, taking almost 10 seconds on my laptop, and generating
an 100MB SVG file. Much bigger than this and my SVG viewing and conversion tools
start to break.

Convert the unweildy SVG file into a lossy webp image, which is only 300kB:

```bash
make lossy
```

Just running `make` with no args lists all the things it can do, such as
converting the image to different output formats. See the commands that make
displays when you run these targets, to modify and construct your own commands.

## Thoughts for later

* It's slow to generate and render. Can we join up the drawn entities into
  fewer, more complex polygons, to speed it up, and reduce the 100MB SVG
  filesize?
* Is it worth trying alt SVG generation libraries?

