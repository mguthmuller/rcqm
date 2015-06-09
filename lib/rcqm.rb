require 'optparse'
require_relative 'rcqm/coverage.rb'
require_relative 'rcqm/coding_style.rb'
require_relative 'rcqm/statistics.rb'
require_relative 'rcqm/tags.rb'
require_relative 'rcqm/complexity.rb'
require_relative 'rcqm/documentation.rb'

module Rcqm

  class Rcqm

    def initialize(_args)
      @options = {}
      # Default values
      @options[:metrics] = 'all'
      @options[:quiet] = false
      optparse = OptionParser.new do |opts|
        # Usage
        opts.banner = 'Usage: rcqm [options]'
        # Define specific files to analyze
        opts.on('-fFILES', '--files=FILES',
                'List of specific files to analyze (separate with ',')') do |x|
          @options[:files] = x
        end
        # Exclude specific files from analysis
        opts.on('-eFILES', '--exclude=FILES',
                'Exclude files from analysis (separate with ',')') do |x|
          @options[:exclude] = x.to_s
        end
        # Define specific metrics
        opts.on('-mMETRICS', '--metrics=METRICS',
                'List of metrics to evaluate (separate with ',')') do |x|
          @options[:metrics] = x
        end
        # Define specific tags to check
        opts.on('-tTAGS', '--tags=TAGS',
                'List of tags to evaluate (separate with ',')') do |x|
          @options[:tags] = x
        end
        # Define specific tags to check
        opts.on('-sSTATISTICS', '--statistics=STATISTICS',
                'List of statistics to evaluate (separate with ',')') do |x|
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
      end
      
      # Parse options et check their validity
      begin
        optparse.parse!
      rescue OptionParser::ParseError
        $stderr.puts("Error: #{$ERROR_INFO}")
      end
    end

    def start_checks
      metrics = @options[:metrics].split(',')
      metrics.each do |metric_name|
        case metric_name
        when 'coverage'
          $stderr.puts("Coverage metric not implemented yet! Ignore it")
        when 'coding_style'
          @coding_style_metric = CodingStyle.new(@options)
          @coding_style_metric.check
          puts "Coding style done"
        when 'statistics'
          @statistics_metric = Statistics.new(@options)
          @statistics_metric.check
          puts "Statistics done"
        when 'tags'
          @tags_metric = Tags.new(@options)
          @tags_metric.check
          puts "Tags tracking done"
        when 'complexity'
          @complexity_metric = Complexity.new(@options)
          @complexity_metric.check
          puts "Complexity done"
        when 'documentation'
          @documentation_metric = Documentation.new(@options)
          @documentation_metric.check
          puts "Documentation done"
        when 'all'
          check_all
        else
          $stderr.puts "#{metric_name}: Unknown metric. Ignore it."
        end
      end
    end

    def check_all
      @coding_style_metric = CodingStyle.new(@options)
      @coding_style_metric.check
      puts "Coding style done"
      @complexity_metric = Complexity.new(@options)
      @complexity_metric.check
      puts "Complexity done"
      @documentation_metric = Documentation.new(@options)
      @documentation_metric.check
      puts "Documentation done"
      @statistics_metric = Statistics.new(@options)
      @statistics_metric.check
      puts "Statistics done"
      @tags_metric = Tags.new(@options)
      @tags_metric.check
      puts "Tags tracking done"
    end

    def run
      start_checks
    end
    
  end
  
end
