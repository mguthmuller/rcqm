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
        if @options[:jenkins]
          puts '************************************************************'
          puts '************************ Complexity ************************'
          puts '************************************************************'
        else
          puts '************************************************************'.bold
          puts '************************ Complexity ************************'.bold
          puts '************************************************************'.bold
        end
      end
    end

    # Launch `flog` one the file given in parameter and report results
    # @param filename [String] The path of the file to analyze
    # @return [Integer] Return code
    def check_file(filename)
      flog_res = `flog -abcm #{filename}`
      results = parse_flog_output(flog_res)
      unless @options[:quiet] || (results[:total].to_i == 0)
        unless @options[:dev]
          puts
          @options[:jenkins] ?
            puts("=== #{filename} ===") :
            puts("=== #{filename} ===".bold)
        end
        print_complexity_scores(filename, results)
      end
      report_results(filename, results, 'complexity') if @options[:report]
      (results[:total].to_i == 0) ? 0 : 1
    end

    # Parse and format output returned by flog
    # @param output [String] Flog output
    # @return [Hash] Flog output formatted
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
    # If dev mode enabled, print only methods with compelxity score > 25
    # @param filename [String] Name of the analyzed file
    # @param scores [Hash] Hash containing the results to print
    def print_complexity_scores(filename, scores)
      critical_scores = 0
      unless @options[:dev]
        puts 'Complexity'.rjust(10) + ' | ' + 'Method name'.ljust(50)
        puts '-----------------------------------------------------------------'
      end
      scores[:per_method].each do |res|
        if res[:complexity].to_i > 60
          if (critical_scores == 0) && (@options[:dev])
            puts
            @options[:jenkins] ?
              puts("=== #{filename} ===") :
              puts("=== #{filename} ===".bold)
            puts 'Complexity'.rjust(10) + ' | ' + 'Method name'.ljust(50)
            puts '-------------------------------------------------------------'
          end
          critical_scores += 1
          @options[:jenkins] ?
            puts("#{res[:complexity].rjust(10)} | #{res[:method]}") :
            puts("#{res[:complexity].rjust(10).red} | #{res[:method].red}")
        elsif res[:complexity].to_i > 25
          if (critical_scores) == 0 && (@options[:dev])
            puts
            @options[:jenkins] ?
              puts("=== #{filename} ===") :
              puts("=== #{filename} ===".bold)
            puts 'Complexity'.rjust(10) + ' | ' + 'Method name'.ljust(50)
            puts '--------------------------------------------------------------'
          end
          critical_scores += 1
          @options[:jenkins] ?
            puts("#{res[:complexity].rjust(10)} | #{res[:method]}") :
            puts("#{res[:complexity].rjust(10).yellow} | #{res[:method].yellow}")
        else
          unless @options[:dev]
            puts "#{res[:complexity].rjust(10)} | #{res[:method]}"
          end
        end
      end
      unless @options[:dev]
        puts '------------------------------------------------------------------'
        puts "#{scores[:total]}".rjust(10) + ' | ' + 'Total'
      end
    end
    
  end

end
