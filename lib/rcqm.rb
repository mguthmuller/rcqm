require 'optparse'
require_relative 'rcqm/coverage.rb'
require_relative 'rcqm/coding_style.rb'
require_relative 'rcqm/statistics.rb'
require_relative 'rcqm/tags.rb'
require_relative 'rcqm/complexity.rb'
require_relative 'rcqm/documentation.rb'

# Rcqm module
module Rcqm

  # Rcqm class, corresponding object used in rcqm executable script 
  class Rcqm

    # Constructor
    def initialize
      @options = {}
      # Default values
      @options[:metrics] = 'all'
      @options[:quiet] = false
      @options[:report] = true
      @options[:dev] = false
      @options[:config] =
        "#{File.expand_path(File.join(File.dirname(__FILE__), ".."))}"\
        '/config/.rubocop.yml'
      optparse = OptionParser.new do |opts|
        # Usage
        opts.banner = 'Usage: rcqm [options]'
        # Define specific files to analyze
        opts.on('-fFILES', '--files=FILES',
                'List of specific files to analyze '\
                '(separate with \',\')') do |x|
          @options[:files] = x
        end
        # Exclude specific files from analysis
        opts.on('-eFILES', '--exclude=FILES',
                'Exclude files from analysis (separate with \',\')') do |x|
          @options[:exclude] = x.to_s
        end
        # Define specific metrics
        opts.on('-mMETRICS', '--metrics=METRICS',
                'List of metrics to evaluate (separate with \',\')') do |x|
          @options[:metrics] = x
        end
        # Define specific tags to check
        opts.on('-tTAGS', '--tags=TAGS',
                'List of tags to evaluate (separate with \',\')') do |x|
          @options[:tags] = x
        end
        # Define specific tags to check
        opts.on('-sSTATISTICS', '--statistics=STATISTICS',
                'List of statistics to evaluate (separate with \',\')') do |x|
          @options[:stats] = x
        end
        # Upload your own rubocop configuration file
        opts.on('-cCONFIG_FILE', '--config=CONFIG_FILE',
                'Upload your own rubocop configuration file') do |x|
          @options[:config] = x
        end
        # Disable results display
        opts.on('-q', '--quiet', 'Disable results display') do
          @options[:quiet] = true
        end
        # Disable reporting
        opts.on('-n', '--no_report', 'Disable reporting') do
          @options[:report] = false
        end
        # Developer mode: display only information to improve
        opts.on('-d', '--dev', 'Developer mode') do
          @options[:dev] = true
        end
      end
      
      # Parse options et check their validity
      begin
        optparse.parse!
      rescue OptionParser::ParseError
        $stderr.puts("Error: #{$ERROR_INFO}")
      end
    end

    # Launch individual checks for each metric specified in command line
    def individual_checks
      return_code = 0
      metrics = @options[:metrics].split(',')
      if metrics.include?('all')
        return_code = all_checks
      else
        metrics.each do |metric_name|
          case metric_name
          when 'coverage'
            $stderr.puts('Coverage metric not implemented yet! Ignore it')
          when 'coding_style'
            @coding_style_metric = CodingStyle.new(@options)
            return_code |= @coding_style_metric.check('Coding style')
          when 'statistics'
            @statistics_metric = Statistics.new(@options)
            return_code |= @statistics_metric.check('Statistics')
          when 'tags'
            @tags_metric = Tags.new(@options)
            return_code |= @tags_metric.check('Tags tracking')
          when 'complexity'
            @complexity_metric = Complexity.new(@options)
            return_code |= @complexity_metric.check('Complexity')
          when 'documentation'
            @documentation_metric = Documentation.new(@options)
            return_code |= @documentation_metric.check('Documentation')
          else
            $stderr.puts "#{metric_name}: Unknown metric. Ignore it."
          end
        end
      end
      return_code
    end

    # Launch checks for all metrics 
    def all_checks
      return_code = 0
      @coding_style_metric = CodingStyle.new(@options)
      return_code |= @coding_style_metric.check('Coding style')
      @complexity_metric = Complexity.new(@options)
      return_code |= @complexity_metric.check('Complexity')
      @documentation_metric = Documentation.new(@options)
      return_code |= @documentation_metric.check('Documentation')
      unless @options[:dev]
        @statistics_metric = Statistics.new(@options)
        return_code |= @statistics_metric.check('Statistics')
      end
      @tags_metric = Tags.new(@options)
      return_code |= @tags_metric.check('Tags tracking')
      return_code
    end

    # Run metric checks
    def run
      return_code = individual_checks
      puts "Return code : #{return_code}"
      exit return_code
    end
    
  end
  
end
