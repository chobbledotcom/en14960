#!/usr/bin/env ruby
# frozen_string_literal: true

require "benchmark"
require_relative "lib/en14960"

# Methods to test
methods_to_test = [
  [:calculate_anchors, EN14960],
  [:calculate_user_capacity, EN14960],
  [:calculate_slide_runout, EN14960],
  [:calculate_required_anchors, EN14960::Calculators::AnchorCalculator],
  [:calculate, EN14960::Calculators::UserCapacityCalculator],
  [:validate, EN14960::Validators::PlayAreaValidator]
]

puts "Cache Performance Comparison for EN14960::SourceCode"
puts "=" * 70
puts

# Test 1: Cold cache (first run)
puts "1. COLD CACHE (first lookup of each method):"
puts "-" * 70

EN14960::SourceCode.clear_cache!
cold_times = {}
methods_to_test.each do |method_name, module_name|
  time = Benchmark.realtime do
    EN14960::SourceCode.get_method_source(method_name, module_name)
  end
  cold_times[method_name] = time * 1000
  puts "#{method_name.to_s.ljust(30)} => #{(time * 1000).round(3)}ms"
end

# Test 2: Warm cache (second run)
puts "\n2. WARM CACHE (second lookup of same methods):"
puts "-" * 70

warm_times = {}
methods_to_test.each do |method_name, module_name|
  time = Benchmark.realtime do
    EN14960::SourceCode.get_method_source(method_name, module_name)
  end
  warm_times[method_name] = time * 1000
  puts "#{method_name.to_s.ljust(30)} => #{(time * 1000).round(3)}ms"
end

# Test 3: Performance improvement
puts "\n3. SPEEDUP WITH CACHE:"
puts "-" * 70

methods_to_test.each do |method_name, _|
  speedup = cold_times[method_name] / warm_times[method_name]
  reduction = ((1 - warm_times[method_name] / cold_times[method_name]) * 100).round(1)
  puts "#{method_name.to_s.ljust(30)} => #{speedup.round(1)}x faster (#{reduction}% reduction)"
end

# Test 4: Repeated lookups benchmark
puts "\n4. REPEATED LOOKUPS (1000 iterations):"
puts "-" * 70

# Without cache (clear before each lookup)
time_no_cache = Benchmark.realtime do
  1000.times do
    EN14960::SourceCode.clear_cache!
    EN14960::SourceCode.get_method_source(:calculate_anchors, EN14960)
  end
end
puts "Without cache: #{(time_no_cache * 1000).round(2)}ms total, #{(time_no_cache / 1000 * 1000).round(3)}ms avg"

# With cache (clear only at start)
EN14960::SourceCode.clear_cache!
time_with_cache = Benchmark.realtime do
  1000.times do
    EN14960::SourceCode.get_method_source(:calculate_anchors, EN14960)
  end
end
puts "With cache:    #{(time_with_cache * 1000).round(2)}ms total, #{(time_with_cache / 1000 * 1000).round(3)}ms avg"

speedup = time_no_cache / time_with_cache
puts "Speedup:       #{speedup.round(1)}x faster with cache"

# Test 5: Mixed access patterns
puts "\n5. MIXED ACCESS PATTERNS (600 random lookups):"
puts "-" * 70

# Without cache
time_mixed_no_cache = Benchmark.realtime do
  600.times do
    EN14960::SourceCode.clear_cache!
    method_name, module_name = methods_to_test.sample
    EN14960::SourceCode.get_method_source(method_name, module_name)
  end
end
puts "Without cache: #{(time_mixed_no_cache * 1000).round(2)}ms"

# With cache
EN14960::SourceCode.clear_cache!
time_mixed_with_cache = Benchmark.realtime do
  600.times do
    method_name, module_name = methods_to_test.sample
    EN14960::SourceCode.get_method_source(method_name, module_name)
  end
end
puts "With cache:    #{(time_mixed_with_cache * 1000).round(2)}ms"
puts "Speedup:       #{(time_mixed_no_cache / time_mixed_with_cache).round(1)}x faster"

# Summary
puts "\n6. SUMMARY:"
puts "-" * 70
avg_cold = cold_times.values.sum / cold_times.length
avg_warm = warm_times.values.sum / warm_times.length
puts "Average cold cache lookup: #{avg_cold.round(3)}ms"
puts "Average warm cache lookup: #{avg_warm.round(3)}ms"
puts "Average speedup: #{(avg_cold / avg_warm).round(1)}x"
puts "\nRecommendation: Caching provides #{(avg_cold / avg_warm).round(0)}x speedup for repeated lookups."
puts "This is especially beneficial for applications that repeatedly query the same methods."
