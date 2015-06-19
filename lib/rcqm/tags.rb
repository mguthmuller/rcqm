require_relative 'metric.rb'
require 'json'

#  Rcqm module
module Rcqm

  # Tags class, herited from metric class
  class Tags < Rcqm::Metric

    # Constructor
    # @param args [Hash] Hash containing options values 
    def initialize(*args)
      # Get options values
      super(*args)
      # Quiet mode disabled
      unless @options[:quiet]
        puts 
        puts '***********************************************************'.bold
        puts '********************** Tags matching **********************'.bold
        puts '***********************************************************'.bold
      end
    end

    # Define tags to track, including tags added on command line
    # @return [String] regexp pattern
    def define_regexp
      # Default pattern if there is no tags specified on command line
      if @options[:tags].nil?
        pattern = 'TODO|FIXME'
      else
        # Parse defined tags on command line
        pattern = ''
        tags_names = @options[:tags].split(',')
        tags_names.each do |tag_name|
          pattern << (pattern.empty?) ?  "#{tag_name}" : "|#{tag_name}"
        end
      end
      pattern
    end

    # Analyze each individual file, looking for lines containing defined tags
    # @param filename [String] The path of the file to analyze
    def check_file(filename)
      lines = [] 
      line_num = 0
      # Get tags to search in file
      pattern = define_regexp
      # Read lines of file
      File.open(filename, 'r') do |file|
        file.each_line do |line|
          line_num += 1
          lines << [line_num, line] if line =~ /#{pattern}/i
        end
      end
      # Report results in json file
      report_results(filename, lines, 'tags') if @options[:report]
      # Print results if required
      unless @options[:quiet] || lines.empty?
        puts
        puts "=== #{filename} ===".bold
        print_tags(lines)
      end
      0
    end

    # Print formatted tags tracking result
    # @param res [Array] Results array
    def print_tags(res)
      res.each do |line_num, line|
        puts "Line #{line_num}: #{line.strip}"
      end
    end

    # Format tags result
    # @param res [Array] Results array
    # @return [Array] Formatted results array
    def format_result(res)
      return nil if res.empty?
      result = []
      res.each do |line_num, line|
        result << "Line #{line_num}: #{line.strip}"
      end
      result
    end

    # Append new results in the json file
    # @param reports [Array] Previous results
    # @param filename [String] Name/Path of the analyzed file
    # @param res [Hash] Hash containing the new results to append
    def append_results(reports, filename, res)
      reports[filename] ||= []
      reports[filename] << {
        'Date' => Time.now,
        'Total' => res.length,
        'Tags' => format_result(res)
      }
    end
      
  end
  
end
