# coding: utf-8
require_relative 'metric.rb'
require 'json'
require 'colorize'

# Rcqm main module
module Rcqm

  # CodingStyle class, herited from Metric class
  class CodingStyle < Rcqm::Metric

    # Constructor
    # @param args [Hash] Hash containing options values 
    def initialize(*args)
      super(*args)
      unless @options[:quiet]
        puts 
        puts '************************************************************'.bold
        puts '*********************** Coding style ***********************'.bold
        puts '************************************************************'.bold
      end
    end

    # Check coding style with rubocop on file given in parameter
    # @param filename [String] The path to the file to analyze
    def check_file(filename)
      # set output format to 'simple' (easier to parse) and
      # include rubocop configuration file
      rubocop_res = `rubocop -f simple -c #{@options[:config]} #{filename}`
      results = parse_rubocop_output(rubocop_res)
      unless (results[:C].empty? &&
              results[:E].empty? &&
              results[:F].empty? &&
              results[:W].empty?) ||
             @options[:quiet]
        puts
        puts "=== #{filename} ===".bold
        print_offenses(results)
      end
      # Report results in a json file
      report_results(filename, results, 'coding_style') if @options[:report]
    end

    # Parse rubocop output to extract line, column, message and the offense type
    # @param output [String] Rubocop output
    def parse_rubocop_output(output)
      offenses = {
        :C => [],
        :E => [],
        :F => [],
        :W => []
      }
      output.lines do |line|
        next if line =~ /^==/
        break if line.strip.empty?
        splitted_line = line.split(' ')
        offense_level = splitted_line[0].gsub(/\:/,'')
        line_number = splitted_line[1].gsub(/\:/,'')
        column_number = splitted_line[2].gsub(/\:/,'')
        index_end = splitted_line.length
        msg = splitted_line[3..index_end-1].join(' ')
        complete_msg = "Line: #{line_number}, Column: #{column_number} - #{msg}"
        case offense_level
        when 'C'
          offenses[:C] << complete_msg
        when 'E'
          offenses[:E] << complete_msg
        when 'F'
          offenses[:F] << complete_msg
        when 'W'
          offenses[:W] << complete_msg
        end
      end
      offenses
    end

    # Print formatted rubocop results
    # @param res [Hash] Hash containing rubocop results
    def print_offenses(res)
      unless res[:C].empty?
        puts '# Issues with convention:'.red
        res[:C].each do |item|
          puts "  - #{item}" 
        end
      end
      unless res[:E].empty?
        puts '# Errors:'.red
        res[:E].each do |item|
          puts "  - #{item}" 
        end
      end
      unless res[:F].empty?
        puts '# Fatal errors:'.red 
        res[:F].each do |item|
          puts "  - #{item}" 
        end
      end
      unless res[:W].empty?
        puts '# Warnings:'.red 
        res[:W].each do |item|
          puts "  - #{item}" 
        end
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
        'Issues with convention' => (res[:C].empty?) ? nil : res[:C],
        'Errors' => (res[:E].empty?) ? nil : res[:E],
        'Fatal errors' => (res[:F].empty?) ? nil : res[:F],
        'Warnings' => (res[:W].empty?) ? nil : res[:W]
      }
    end
    
  end

end
