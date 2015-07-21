# coding: utf-8
require_relative 'metric.rb'
require 'json'
require 'colorize'

module Rcqm

  # CodingStyle class, herited from Metric class
  class CodingStyle < Rcqm::Metric

    # Constructor
    # @param args [Hash] Hash containing options values
    def initialize(*args)
      super(*args)
      unless @options[:quiet]
        puts
        if @options[:jenkins]
          puts '************************************************************'
          puts '*********************** Coding style ***********************'
          puts '************************************************************'
        else
          puts '**********************************************************'.bold
          puts '*********************** Coding style *********************'.bold
          puts '**********************************************************'.bold
        end
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
        @options[:jenkins] ?
          puts("=== #{filename} ===") :
          puts("=== #{filename} ===".bold)
        print_offenses(results)
      end
      # Report results in a json file
      report_results(filename, results, 'coding_style') if @options[:report]
      # Return code
      (results[:C].empty? && results[:E].empty? && results[:F].empty?) ? 0 : 1
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
        split_result = line.split(' ')
        offense_level = split_result[0].gsub(/\:/,'')
        line_number = split_result[1].gsub(/\:/,'')
        column_number = split_result[2].gsub(/\:/,'')
        index_end = split_result.length
        msg = split_result[3..index_end-1].join(' ')
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
        @options[:jenkins]  ?
          puts('# Issues with convention:') :
          puts('# Issues with convention:'.red)
        res[:C].each do |item|
          puts "  - #{item}"
        end
      end
      unless res[:E].empty?
        @options[:jenkins] ?
          puts('# Errors:') :
          puts('# Errors:'.red)
        res[:E].each do |item|
          puts "  - #{item}"
        end
      end
      unless res[:F].empty?
        @options[:jenkins] ?
          puts('# Fatal errors:') :
          puts('# Fatal errors:'.red)
        res[:F].each do |item|
          puts "  - #{item}"
        end
      end
      unless res[:W].empty?
        @options[:jenkins] ?
          puts('# Warnings:') :
          puts('# Warnings:'.red)
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
