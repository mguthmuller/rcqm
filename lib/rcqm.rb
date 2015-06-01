require 'optparse'
require_relative 'rcqm/coverage.rb'
require_relative 'rcqm/coding_style.rb'
require_relative 'rcqm/statistics.rb'
require_relative 'rcqm/tags.rb'
require_relative 'rcqm/complexity.rb'

module Rcqm

  class Rcqm
    
    def initialize(args)
      @options = {}
      # Default values
      @options[:metrics] = "all"
      @options[:verbose] = "enable"
      optparse = OptionParser.new do |opts|
        # Usage
        opts.banner = "Usage: rcqm [options]"
        # Define specific files to analyze
        opts.on("-fFILES", "--files=FILES",
                "List of specific files to analyze (separate with ',')") do |x|
          @options[:files] = x
        end
        # Exclude specific files from analysis
        opts.on("-eFILES", "--exclude=FILES",
                "Exclude files from analysis (separate with ',')") do |x|
          @options[:exclude] = x
        end
        # Define specific metrics
        opts.on("-mMETRICS", "--metrics=METRICS",
                "List of metrics to evaluate (separate with ',')") do |x|
          @options[:metrics] = x
        end
        # Define specific tags to check
        opts.on("-tTAGS", "--tags=TAGS",
                "List of tags to evaluate (separate with ',')") do |x|
          @options[:tags] = x
        end
        # Enable/Disable verbose mode
        opts.on("-vVERBOSE","--verbose=VERBOSE",
                "Enable/Disable verbose mode") do |x|
          @options[:verbose] = x
        end         
      end
      
      # Parse options et check their validity
      begin
        optparse.parse!
      rescue OptionParser::ParseError
        STDERR.puts("Error: #{$!}")
      end
    end

    def get_metrics
      metrics = @options[:metrics].split(',')
      metrics.each do |metric_name|
        case metric_name
        when "coverage"
          @coverage_metric = Coverage.new(@options)
          @coverage_metric.check
        when "coding_style"
          @coding_style_metric = CodingStyle.new(@options)
          @coding_style_metric.check
        when "statistics"
          @statistics_metric = Statistics.new(@options)
          @statistics_metric.check
        when "tags"
          @tags_metric = Tags.new(@options)
          @tags_metric.check
        when "complexity"
          @complexity_metric = Complexity.new(@options)
          @complexity_metric.check
        when "all"
          check_all
        else 
          puts "#{metric_name}: Unknown metric. Ignore it."
        end
      end
    end

    def check_all
      @coverage_metric = Coverage.new(@files, @excluded_files)
      @coverage_metric.check
      @coding_style_metric = CodingStyle.new(@files, @excluded_files)
      @coding_style_metric.check
      @statistics_metric = Statistics.new(@files, @excluded_files)
      @statistics_metric.check
      @tags_metric = Tags.new(@files, @excluded_files)
      @tags_metric.check
      @complexity_metric = Complexity.new(@files, @excluded_files)
      @complexity_metric.check
    end
    
    def run
      get_metrics
    end
    
  end
  
end
