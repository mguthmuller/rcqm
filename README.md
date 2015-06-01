# Ruby Code Quality Metrics

## Usage:

rcqm [options]

## Command line options
- -f, --files=FILES                List of specific files to analyze (separate with ',')
- -e, --exclude=FILES              Exclude files from analysis (separate with ',')
- -m, --metrics=METRICS            List of metrics to evaluate (separate with ',')
- -t, --tags=TAGS                  List of tags to evaluate (separate with ',')
- -v, --verbose=VERBOSE            Enable/Disable verbose mode

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

### Statistics (per file)
- Total lines
- Empty lines
- Commented lines
- Lines of code
- Modules
- Classes
- Methods
- Requires

### Not implemented yet ...
- Code Coverage
- Coding Style
- Cyclomatic complexity
- Dead Code
- Duplication

## Analysis reporting

Results of each analysis are stored in a json file ('tags.json', 'statistics.json', ...)  in 'reports' directory

## Dependancies:

