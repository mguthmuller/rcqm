require_relative 'metric.rb'
require 'json'
require 'colorize'

#  Rcqm module
module Rcqm

  # Complexity class, herited from metric class
  class Complexity < Rcqm::Metric

    # Constructor
    # @param args [Hash] Hash containing options values 
    def initialize(*args)
      super(*args)
      unless @options[:quiet]
        puts
        puts '************************************************************'.bold
        puts '************************ Complexity ************************'.bold
        puts '************************************************************'.bold
      end
    end

    # Launch `flog` one the file given in parameter and report results
    # @param filename [String] The path of the file to analyze
    def check_file(filename)
      flog_res = `flog -abcm #{filename}`
      results = parse_flog_output(flog_res)
      unless @options[:quiet] || (results[:total] == 0)
        puts
        puts "=== #{filename} ===".bold
        print_complexity_scores(results)
      end
      report_results(filename, results, 'complexity') if @options[:report]
    end

    # Parse and format output returned by flog
    # @param output [String] Flog output
    # @return res [Hash] Flog output formatted
    def parse_flog_output(output)
      res = {
        :total => 0,
        :per_method => []
      }
      output.lines do |line|
        next if line.strip.empty?
        splitted_line = line.split(' ')
        next if splitted_line[1].eql? 'flog/method'
        if splitted_line[1..2].join(' ').eql? 'flog total'
          res[:total] = splitted_line[0].gsub(/:/,'')
        else
          res[:per_method] << {
            :method => splitted_line[1],
            :complexity => splitted_line[0].gsub(/:/,'')
          }
        end
      end
      res
    end

    # Append new results in the json file
    # @param reports [Array] Previous results
    # @param filename [String] Name/Path of the analyzed file
    # @param results [Hash] Hash containing the new results to append
    def append_results(reports, filename, results)
      reports[filename] ||= []
      reports[filename] << {
        'Date' => Time.now,
        'Total' => results[:total],
        'Complexity per method' => results[:per_method] 
      }
    end
    
    # Print formatted results of complexity scores
    # @param scores [Hash] Hash containing the results to print
    def print_complexity_scores(scores)
      puts 'Complexity'.rjust(10) + ' | ' + 'Method name'.ljust(50)
      puts '-------------------------------------------------------------------'
      scores[:per_method].each do |res|
        if res[:complexity].to_i > 60
          puts "#{res[:complexity].rjust(10).red} | #{res[:method].red}"
        elsif res[:complexity].to_i > 25
          puts "#{res[:complexity].rjust(10).yellow} | #{res[:method].yellow}"
        else
          puts "#{res[:complexity].rjust(10)} | #{res[:method]}"
        end
      end
      puts '-------------------------------------------------------------------'
      puts "#{scores[:total]}".rjust(10) + ' | ' + 'Total'
    end
    
  end

end
