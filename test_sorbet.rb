#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script to verify Sorbet type signatures work correctly

require_relative "lib/en14960"

puts "Testing EN14960 with Sorbet type signatures..."
puts "=" * 50

# Test anchor calculation
puts "\n1. Testing anchor calculation:"
result = EN14960.calculate_anchors(length: 10.5, width: 8.2, height: 3.5)
puts "   Result: #{result.value} anchors needed"
puts "   Breakdown: #{result.breakdown.first}"

# Test slide runout
puts "\n2. Testing slide runout calculation:"
result = EN14960.calculate_slide_runout(2.5, has_stop_wall: true)
puts "   Result: #{result.value}#{result.value_suffix}"

# Test wall height requirements
puts "\n3. Testing wall height requirements:"
result = EN14960.calculate_wall_height(4.0, 1.8, false)
puts "   Result: #{result.value}#{result.value_suffix}"

# Test user capacity
puts "\n4. Testing user capacity calculation:"
result = EN14960.calculate_user_capacity(12, 10, 1.5, 5)
puts "   Result: #{result.value}"

# Test rope diameter validation
puts "\n5. Testing rope diameter validation:"
valid = EN14960.valid_rope_diameter?(25)
puts "   25mm rope: #{valid ? 'Valid' : 'Invalid'}"

# Test play area validation
puts "\n6. Testing play area validation:"
validation = EN14960.validate_play_area(
  unit_length: 15,
  unit_width: 12,
  play_area_length: 14,
  play_area_width: 11,
  negative_adjustment_area: 10
)
puts "   Valid: #{validation[:valid]}"

puts "\n" + "=" * 50
puts "All tests completed successfully with Sorbet types!"