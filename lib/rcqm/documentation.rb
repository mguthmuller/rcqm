require_relative 'metric.rb'
require 'json'
require 'colorize'

module Rcqm

  # Documentation class, herited from metric class
  class Documentation < Rcqm::Metric

    # Constructor
    # @param args [Hash] Hash containing options values
    def initialize(*args)
      super(*args)
      @elsewhere_documentation = {}
      unless @options[:quiet]
        puts
        if @options[:jenkins]
          puts '***********************************************************'
          puts '******************* Documentation rates *******************'
          puts '***********************************************************'
        else
          puts '**********************************************************'.bold
          puts '******************* Documentation rates ******************'.bold
          puts '**********************************************************'.bold
        end
      end
    end

    # Launch `inch` one the file given in parameter and report results
    # @param filename [String] The path of the file to analyze
    # @return [Integer] Return code
    def check_file(filename)
      pwd = Dir.pwd
      Dir.chdir(File.dirname(filename))
      inch_res = `inch list --all #{File.basename(filename)}`
      Dir.chdir(pwd)
      results = parse_inch_output(uncolorize(inch_res))
      unless @options[:quiet] ||
             (results[:A].empty? &&
              results[:B].empty? &&
              results[:C].empty? &&
              results[:U].empty?)
        unless @options[:dev]
          puts
          @options[:jenkins] ?
            puts("=== #{filename} ===") :
            puts("=== #{filename} ===".bold)
        end
        print_documentation_rates(filename,results)
      end
      report_results(filename, results, 'documentation') if @options[:report]
      (results[:C].empty? && results[:U].empty?) ? 0 : 1
    end

    # Parse and format output returned by inch
    # @param output [String] Inch output
    # @return [Hash] Inch output formatted
    def parse_inch_output(output)
      grades = {
        :A => [],
        :B => [],
        :C => [],
        :U => [],
        :E => []
      }
      output.lines do |line|
        next if line.strip.empty?
        break if  (line =~ /^Nothing to suggest/) ||
                  (line =~ /^You might want to look at these files/)
        split_result = line.split(' ')
        case split_result[1]
        when 'A'
          grades[:A] << split_result[3]
        when 'B'
          grades[:B] << split_result[3]
        when 'C', 'U'
          global_grade = get_global_grade(split_result[3])
          case global_grade
          when 'A'
            grades[:A] << split_result[3]
          when 'B'
            grades[:B] << split_result[3]
          when 'C'
            grades[:C] << split_result[3]
          when 'U'
            grades[:U] << split_result[3]
          end
        end
      end
      grades
    end

    # Get global grade if object declared in several files
    # @param object_name [String] Object name
    # @return [String] Global grade
    def get_global_grade(object_name)
      inch_show_result = uncolorize(`inch  show #{object_name}`)
      inch_show_result.lines do |line|
        split_result = line.split(' ')
        next if split_result[1]  != 'Grade:'
        return split_result[2]
      end
    end

    # Append new results in the json file
    # @param reports [Array] Previous results
    # @param filename [String] Name/Path of the analyzed file
    # @param res [Hash] Hash containing the new results to append
    def append_results(reports, filename, res)
      reports[filename] ||= []
      reports[filename] << {
        'Date' => Time.now,
        'Good documentation' => (res[:A].empty?) ? nil : res[:A],
        'Could be improved documentation' => (res[:B].empty?) ? nil : res[:B],
        'Need work documentation' => (res[:C].empty?) ? nil : res[:C],
        'Undocumented' => (res[:U].empty?) ? nil : res[:U]
      }
    end

    # Print formatted results of documentation rates
    # @param filename [String] Name of the analyzed file
    # @param res [Hash] Hash containing the results to print
    def print_documentation_rates(filename, res)
      unless (res[:A].empty?) || (@options[:dev])
        @options[:jenkins] ?
          puts('# Good documentation:') :
          puts('# Good documentation:'.green)
        res[:A].each do |item|
          puts "  - #{item}"
        end
      end
      if (@options[:dev]) &&
         (!res[:B].empty? || !res[:C].empty? || !res[:U].empty?)
        puts
        @options[:jenkins] ?
          puts("=== #{filename} ===") :
          puts("=== #{filename} ===".bold)
      end
      unless res[:B].empty?
        @options[:jenkins] ?
          puts('# Properly documented, but could be improved:') :
          puts('# Properly documented, but could be improved:'.yellow)
        res[:B].each do |item|
          puts "  - #{item}"
        end
      end
      unless res[:C].empty?
        @options[:jenkins] ?
          puts('# Need work:') :
          puts('# Need work:'.red)
        res[:C].each do |item|
          puts "  - #{item}"
        end
      end
      unless res[:U].empty?
        @options[:jenkins] ?
          puts('# Undocumented:') :
          puts('# Undocumented:'.magenta)
        res[:U].each do |item|
          puts "  - #{item}"
        end
      end
    end

  end

end
