# frozen_string_literal: true

require_relative "../constants"
require_relative "../models/calculator_response"

module EN14960
  module Calculators
    module UserCapacityCalculator
      extend self

      def calculate(length, width, max_user_height = nil, negative_adjustment_area = 0)
        return default_result if length.nil? || width.nil?

        total_area = (length * width).round(2)
        negative_adjustment_area = negative_adjustment_area.to_f.abs
        usable_area = [total_area - negative_adjustment_area, 0].max.round(2)

        breakdown = build_breakdown(length, width, total_area, negative_adjustment_area, usable_area)
        capacities = calculate_capacities(usable_area, max_user_height, breakdown)

        CalculatorResponse.new(
          value: capacities,
          value_suffix: "",
          breakdown: breakdown
        )
      end

      private

      def build_breakdown(length, width, total_area, negative_adjustment_area, usable_area)
        breakdown = []
        formatted_length = format_number(length)
        formatted_width = format_number(width)
        formatted_total = format_number(total_area)
        formatted_usable = format_number(usable_area)

        breakdown << ["Total area", "#{formatted_length}m × #{formatted_width}m = #{formatted_total}m²"]

        if negative_adjustment_area > 0
          formatted_adjustment = format_number(negative_adjustment_area)
          breakdown << ["Obstacles/adjustments", "- #{formatted_adjustment}m²"]
        end

        breakdown << ["Usable area", "#{formatted_usable}m²"]
        breakdown << ["Capacity calculations", "Based on usable area"]

        breakdown
      end

      def calculate_capacities(usable_area, max_user_height, breakdown)
        capacities = {}

        Constants::AREA_DIVISOR.each do |height_mm, divisor|
          height_m = height_mm / 1000.0
          key = :"users_#{height_mm}mm"

          if max_user_height.nil? || height_m <= max_user_height
            capacity = (usable_area / divisor).floor
            capacities[key] = capacity
            formatted_area = format_number(usable_area)
            formatted_divisor = format_number(divisor)
            calculation = "#{formatted_area} ÷ #{formatted_divisor} = #{capacity} "
            calculation += (capacity == 1) ? "user" : "users"
            breakdown << ["#{format_number(height_m)}m users", calculation]
          else
            capacities[key] = 0
            breakdown << ["#{format_number(height_m)}m users", "Not allowed (exceeds height limit)"]
          end
        end

        capacities
      end

      def default_result
        CalculatorResponse.new(
          value: default_capacity,
          value_suffix: "",
          breakdown: [["Invalid dimensions", ""]]
        )
      end

      def default_capacity
        {
          users_1000mm: 0,
          users_1200mm: 0,
          users_1500mm: 0,
          users_1800mm: 0
        }
      end

      def format_number(number)
        # Remove trailing zeros after decimal point
        formatted = sprintf("%.1f", number)
        formatted.sub(/\.0$/, "")
      end
    end
  end
end
