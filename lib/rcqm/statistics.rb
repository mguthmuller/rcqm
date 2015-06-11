require_relative 'metric.rb'
require 'json'

# Rcqm main module
module Rcqm

  # Statistics class, herited from Metric class
  class Statistics < Rcqm::Metric

    # Constructor
    # @param args [Hash] Hash containing options values 
    def initialize(*args)
      super(*args)
      unless @options[:quiet]
        puts
        puts '************************************************************'.bold
        puts '************************ Statistics ************************'.bold
        puts '************************************************************'.bold
      end
      @selected_statistics =
        @options[:stats].split(',') unless @options[:stats].nil?
    end

    # Get statistics about file given in paramater
    # @param filename [String] The path of the file to analyze
    def check_file(filename)
      @lines = File.readlines(filename)
      res = {
        :total => @lines.length,
        :empty_lines => 0,
        :comments => 0,
        :locs => 0,
        :modules => 0,
        :classes => 0,
        :methods => 0,
        :requires => 0
      }
      @lines.each do |line|
        if (line.strip).empty? then res[:empty_lines] += 1
        elsif line.strip =~ /^#/ then res[:comments] += 1
        else
          res[:locs] += 1
          if line.strip =~ /^module/ then res[:modules] += 1
          elsif line.strip =~ /^class/ then res[:classes] += 1
          elsif line.strip =~ /^require/ then res[:requires] += 1
          elsif line.strip =~ /^def/ then res[:methods] += 1
          end
        end
      end
      unless @options[:quiet]
        puts
        puts "=== #{filename} ===".bold
        print_statistics(res)
      end
      # Report results in the json file
      report_results(filename, res, 'statistics') if @options[:report]
    end

    # Check if statistic given in parameter is included
    # in the list of statistics to analyze
    # @param stat_name [String] Name of statistics
    def selected_stat(stat_name)
      if @options[:stats].nil? || @selected_statistics.include?('all')
        return true
      else
        return @selected_statistics.include?(stat_name)
      end
    end

    # Print statistics analysis results
    # @param res [Hash] Hash containing results
    def print_statistics(res)
      puts "Total lines: #{res[:total]}" if selected_stat('total')
      puts "Empty lines: #{res[:empty_lines]}" if selected_stat('empty')
      puts "Commented lines: #{res[:comments]}" if selected_stat('comments')
      puts "Lines of code: #{res[:locs]}" if selected_stat('locs')
      puts "Modules: #{res[:modules]}" if selected_stat('modules')
      puts "Classes: #{res[:classes]}" if selected_stat('classes')
      puts "Methods: #{res[:methods]}" if selected_stat('methods')
      puts "Requires: #{res[:requires]}" if selected_stat('requires')
    end

    # Append new results in the json file
    # @param reports [Array] Previous results
    # @param filename [String] Name/Path of the analyzed file
    # @param res [Hash] Hash containing the new results to append
    def append_results(reports, filename, res)
      reports[filename] ||= []
      new_hash = {'Date' => Time.now}
      new_hash['Total lines'] = res[:total] if selected_stat('total')
      new_hash['Empty lines'] = res[:empty_lines] if selected_stat('empty')
      new_hash['Commented lines'] = res[:comments] if selected_stat('comments')
      new_hash['Lines of code'] = res[:locs] if selected_stat('locs')
      new_hash['Modules'] = res[:modules] if selected_stat('modules')
      new_hash['Classes'] = res[:classes] if selected_stat('classes')
      new_hash['Requires'] = res[:methods] if selected_stat('methods')
      reports[filename] << new_hash
    end
  end

end
