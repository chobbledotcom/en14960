#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "en14960"

puts "Testing wall height calculator with permanent roof logic:\n\n"

# Test case 1: Platform height 4.0m, user height 2.0m, WITH permanent roof
puts "Test 1: Platform 4.0m, User 2.0m, WITH permanent roof"
result = EN14960::Calculators::SlideCalculator.get_wall_height_requirement_details(4.0, 2.0, true)
puts "Text: #{result[:text]}"
puts "Breakdown:"
result[:breakdown].each { |item| puts "  - #{item[0]}: #{item[1]}" }
puts "\n"

# Test case 2: Platform height 4.0m, user height 2.0m, WITHOUT permanent roof
puts "Test 2: Platform 4.0m, User 2.0m, WITHOUT permanent roof"
result = EN14960::Calculators::SlideCalculator.get_wall_height_requirement_details(4.0, 2.0, false)
puts "Text: #{result[:text]}"
puts "Breakdown:"
result[:breakdown].each { |item| puts "  - #{item[0]}: #{item[1]}" }
puts "\n"

# Test case 3: Platform height 4.0m, user height 2.0m, permanent roof status UNKNOWN
puts "Test 3: Platform 4.0m, User 2.0m, permanent roof status UNKNOWN"
result = EN14960::Calculators::SlideCalculator.get_wall_height_requirement_details(4.0, 2.0, nil)
puts "Text: #{result[:text]}"
puts "Breakdown:"
result[:breakdown].each { |item| puts "  - #{item[0]}: #{item[1]}" }
puts "\n"

# Test case 4: Platform height 2.0m (below 3.0m threshold), shouldn't be affected by permanent roof
puts "Test 4: Platform 2.0m, User 1.5m, WITH permanent roof (below 3.0m threshold)"
result = EN14960::Calculators::SlideCalculator.get_wall_height_requirement_details(2.0, 1.5, true)
puts "Text: #{result[:text]}"
puts "Breakdown:"
result[:breakdown].each { |item| puts "  - #{item[0]}: #{item[1]}" }
