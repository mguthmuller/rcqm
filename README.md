# Ruby Code Quality Metrics

## Usage:

```bash
rcqm [options]
```

## Command line options

```bash
 -f, --files=FILES                List of specific files to analyze (separate with ',')
 -e, --exclude=FILES              Exclude files from analysis (separate with ',')
-m, --metrics=METRICS            List of metrics to evaluate (separate with ',')
-t, --tags=TAGS                  List of tags to evaluate (separate with ',')
-s, --statistics=STATISTICS      List of statistics to evaluate (separate with ',')
-c, --config=CONFIG_FILE         Upload your own rubocop configuration file
-q, --quiet                      Disable result display
```

## Metrics names:
- coverage 
- coding_style 
- statistics
- tags
- complexity 
- documentation
- all

## Default files included in the analysis

'app', 'bin', 'feature', 'lib', 'spec' and 'test' directories

## Functionalities:

### Tags (FIXME, TODO, ...) tracking (with '-m tags' option)

You can specify other tags with '-t' option

### Statistics (per file, with '-m statistics' option)

You can specify which statistics to evaluate with '-s' option

#### List of statistics available
- total: Total lines
- empty: Empty lines
- comments: Commented lines
- locs: Lines of code
- modules: Number of modules ('module' tag tracking)
- classes: Number of classes ('class' tag tracking) 
- methods: Methods ('def' tag tracking)
- requires: Requires ('require' tag tracking)
- all : All previous statistics

### Documentation rates (with '-m documentation' option)

Based on [inch] (https://github.com/rrrene/inch) gem

#### Documentation grade
- A: Seems really good
- B: Properly documented
- C: Needs work
- U: Undocumented

### Coding style (with '-m coding_style' option)

- Based on [rubocop] (https://github.com/bbatsov/rubocop) gem
- Configuration file in config/.rubocop.yml
- You can include your own rubocop configuration with '-c path/config/file' option

### Cyclomatic complexity (with '-m complexity' option)

Based on [flog] (https://github.com/seattlerb/flog)

### Not implemented yet ...
- Code Coverage
- Dead Code
- Duplication

## Analysis reporting

Results of each analysis are stored in a json file ('tags.json', 'statistics.json', ...)  in 'reports' directory

## Dependancies:
* [inch] (https://github.com/rrrene/inch)
* [rubocop](https://github.com/bbatsov/rubocop)
* [flog] (https://github.com/seattlerb/flog)
