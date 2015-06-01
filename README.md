# Ruby Code Quality Metrics

## Usage:

rcqm [options]
    -f, --files=FILES                    List of specific files to analyze (separate with ',')
    -e, --exclude=FILES              Exclude files from analysis (separate with ',')
    -m, --metrics=METRICS         List of metrics to evaluate (separate with ',')
    -t, --tags=TAGS                    List of tags to evaluate (separate with ',')
    -v, --verbose=VERBOSE        Enable/Disable verbose mode


## Metrics name:
- coverage 
- coding_style 
- statistics
- tags
- complexity 
- all

## Functionalities:

### Tags (FIXME, TODO, ...) tracking
- With '-m tags' option
- You can specify other tags with '-t' option

### Not implemented yet ...
- Code Coverage
- Coding Style
- Statistics (LOC, Comments, ...)
- Cyclomatic complexity
- Dead Code
- Duplication

## Dependancies:

