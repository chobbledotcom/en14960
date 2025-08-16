#!/usr/bin/env ruby
# frozen_string_literal: true

require "benchmark"
require_relative "lib/en14960"

# Warm up - ensure everything is loaded
EN14960::SourceCode.get_method_source(:calculate_anchors, EN14960)

puts "Benchmarking EN14960::SourceCode.get_method_source performance\n"
puts "=" * 60

# Test with different methods
methods_to_test = [
  [:calculate_anchors, EN14960],
  [:calculate_user_capacity, EN14960],
  [:calculate_slide_runout, EN14960],
  [:calculate_required_anchors, EN14960::Calculators::AnchorCalculator],
  [:calculate, EN14960::Calculators::UserCapacityCalculator],
  [:validate, EN14960::Validators::PlayAreaValidator]
]

# Benchmark individual method lookups
puts "\n1. Individual method lookup times (100 iterations each):"
puts "-" * 60

methods_to_test.each do |method_name, module_name|
  time = Benchmark.realtime do
    100.times { EN14960::SourceCode.get_method_source(method_name, module_name) }
  end
  avg_ms = (time / 100 * 1000).round(3)
  puts "#{method_name.to_s.ljust(30)} => #{avg_ms}ms avg"
end

# Benchmark repeated lookups of the same method
puts "\n2. Repeated lookup of same method (1000 iterations):"
puts "-" * 60

time = Benchmark.realtime do
  1000.times { EN14960::SourceCode.get_method_source(:calculate_anchors, EN14960) }
end
puts "calculate_anchors x 1000: #{(time * 1000).round(2)}ms total, #{(time / 1000 * 1000).round(3)}ms avg"

# Benchmark different access patterns
puts "\n3. Different access patterns (500 iterations each):"
puts "-" * 60

puts "Sequential (same method repeatedly):"
time_sequential = Benchmark.realtime do
  500.times { EN14960::SourceCode.get_method_source(:calculate_anchors, EN14960) }
end
puts "  Total: #{(time_sequential * 1000).round(2)}ms"

puts "\nRound-robin (cycling through methods):"
time_round_robin = Benchmark.realtime do
  100.times do
    methods_to_test.each do |method_name, module_name|
      EN14960::SourceCode.get_method_source(method_name, module_name)
    end
  end
end
puts "  Total: #{(time_round_robin * 1000).round(2)}ms"

puts "\nRandom access:"
time_random = Benchmark.realtime do
  600.times do
    method_name, module_name = methods_to_test.sample
    EN14960::SourceCode.get_method_source(method_name, module_name)
  end
end
puts "  Total: #{(time_random * 1000).round(2)}ms"

# Analyze file system operations
puts "\n4. File system operation analysis:"
puts "-" * 60

base_dir = File.expand_path("lib/en14960", __dir__)
ruby_files = Dir.glob(File.join(base_dir, "**", "*.rb"))
puts "Number of Ruby files scanned: #{ruby_files.length}"
total_lines = ruby_files.sum { |f| File.readlines(f).length }
puts "Total lines of code scanned: #{total_lines}"

# Measure just the file scanning overhead
time_scan = Benchmark.realtime do
  100.times do
    Dir.glob(File.join(base_dir, "**", "*.rb"))
  end
end
puts "Dir.glob overhead (100x): #{(time_scan * 1000).round(2)}ms"

# Measure file reading overhead
time_read = Benchmark.realtime do
  100.times do
    ruby_files.each { |f| File.read(f, encoding: "UTF-8") }
  end
end
puts "File reading overhead (100x all files): #{(time_read * 1000).round(2)}ms"

puts "\n5. Recommendation:"
puts "-" * 60
avg_lookup_time = time_sequential / 500 * 1000
puts "Average lookup time: #{avg_lookup_time.round(3)}ms"
if avg_lookup_time < 1
  puts "Performance is already quite good (sub-millisecond)."
  puts "Caching may not provide significant benefits unless:"
  puts "  - The method is called in a tight loop"
  puts "  - The application is performance-critical"
else
  puts "Caching would likely provide performance benefits."
end

(time_sequential / time_sequential * 100).round(0)
puts "\nPotential speedup with caching: ~#{((time_scan + time_read) / time_sequential * 100).round(0)}% of current time could be eliminated"
