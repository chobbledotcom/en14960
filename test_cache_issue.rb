#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/en14960"
require "benchmark"

# Test why calculate_anchors is slower on warm cache
puts "Investigating cache issue with calculate_anchors\n"
puts "=" * 60

# Clear cache and do first lookup
EN14960::SourceCode.clear_cache!
puts "\n1. First lookup (cold cache):"
time1 = Benchmark.realtime do
  result = EN14960::SourceCode.get_method_source(:calculate_anchors, EN14960)
  puts "Result length: #{result.length} chars"
end
puts "Time: #{(time1 * 1000).round(3)}ms"

# Second lookup (should be cached)
puts "\n2. Second lookup (warm cache):"
time2 = Benchmark.realtime do
  result = EN14960::SourceCode.get_method_source(:calculate_anchors, EN14960)
  puts "Result length: #{result.length} chars"
end
puts "Time: #{(time2 * 1000).round(3)}ms"

# Third lookup
puts "\n3. Third lookup (warm cache):"
time3 = Benchmark.realtime do
  result = EN14960::SourceCode.get_method_source(:calculate_anchors, EN14960)
  puts "Result length: #{result.length} chars"
end
puts "Time: #{(time3 * 1000).round(3)}ms"

# Multiple rapid lookups
puts "\n4. Ten rapid lookups (warm cache):"
10.times do |i|
  time = Benchmark.realtime do
    EN14960::SourceCode.get_method_source(:calculate_anchors, EN14960)
  end
  puts "  Lookup #{i + 1}: #{(time * 1000).round(3)}ms"
end

# Try a different method
puts "\n5. Different method (calculate_user_capacity):"
EN14960::SourceCode.clear_cache!
puts "First lookup (cold):"
time_cold = Benchmark.realtime do
  EN14960::SourceCode.get_method_source(:calculate_user_capacity, EN14960)
end
puts "  Time: #{(time_cold * 1000).round(3)}ms"

puts "Second lookup (warm):"
time_warm = Benchmark.realtime do
  EN14960::SourceCode.get_method_source(:calculate_user_capacity, EN14960)
end
puts "  Time: #{(time_warm * 1000).round(3)}ms"
