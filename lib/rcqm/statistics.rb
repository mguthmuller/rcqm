require_relative 'metric.rb'
require 'json'

# TODO : test

module Rcqm

  class Statistics < Rcqm::Metric

    def initialize(*args)
      super(*args)
      if !@options[:quiet]
        puts
        puts '*********************************************'.blue.bold
        puts '***************** Statistics ****************'.blue.bold
        puts '*********************************************'.blue.bold
      end
      @selected_statistics = @options[:stats].split(',') unless @options[:stats].nil?
      puts @selected_statistics
    end

    def check_file(filename)
      if !@options[:quiet]
        puts
        puts "*** Analyze file #{filename} ***".green
      end
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
      print_statistics(res) unless @options[:quiet]
      report_result(filename, res)
    end

    def selected_stat(stat_name)
      if @options[:stats].nil? || @selected_statistics.include?('all')
        return true
      else
        return @selected_statistics.include?(stat_name)
      end
    end
    
    def print_statistics(res)
      puts "Total lines:".red + " #{res[:total]}" unless !selected_stat('total')
      puts "Empty lines:".red + " #{res[:empty_lines]}" unless !selected_stat('empty')
      puts "Commented lines:".red + " #{res[:comments]}" unless !selected_stat('comments')
      puts "Lines of code:".red + " #{res[:locs]}" unless !selected_stat('locs')
      puts "Modules:".red + " #{res[:modules]}" unless !selected_stat('modules')
      puts "Classes:".red + " #{res[:classes]}" unless !selected_stat('classes')
      puts "Methods:".red + " #{res[:methods]}" unless !selected_stat('methods')
      puts "Requires:".red + " #{res[:requires]}" unless !selected_stat('requires')
    end

    def report_result(filename, res)
      # Create dir 'reports' if it does not exist yet
      Dir.mkdir('reports', 0755) unless Dir.exist?('reports')
      
      # Store analysis results
      if File.exist?('reports/statistics.json')
        reports = JSON.parse(IO.read('reports/statistics.json'))
      else
        reports = {}
      end
      reports[filename] ||= []
      new_hash = {'Date' => Time.now}
      new_hash['Total lines'] = res[:total] unless !selected_stat('total')
      new_hash['Empty lines'] = res[:empty_lines] unless !selected_stat('empty')
      new_hash['Commented lines'] = res[:comments] unless !selected_stat('comments')
      new_hash['Lines of code'] = res[:locs] unless !selected_stat('locs')
      new_hash['Modules'] = res[:modules] unless !selected_stat('modules')
      new_hash['Classes'] = res[:classes] unless !selected_stat('classes')
      new_hash['Requires'] = res[:methods] unless !selected_stat('methods')
      reports[filename] << new_hash
      File.open('reports/statistics.json', 'w') do |fd|
        fd.puts(JSON.pretty_generate(reports))
      end
    end
    
  end

end
