# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"
require_relative "../constants"
require_relative "../models/calculator_response"

module EN14960
  module Calculators
    module SlideCalculator
      extend T::Sig
      extend self

      # Simple calculation method that returns just the numeric value
      sig { params(platform_height: Float, has_stop_wall: T::Boolean).returns(Float) }
      def calculate_runout_value(platform_height, has_stop_wall: false)
        return 0 if platform_height <= 0

        height_ratio = Constants::RUNOUT_CALCULATION_CONSTANTS[:platform_height_ratio]
        minimum_runout = Constants::RUNOUT_CALCULATION_CONSTANTS[:minimum_runout_meters]
        stop_wall_add = Constants::RUNOUT_CALCULATION_CONSTANTS[:stop_wall_addition]

        calculated_runout = platform_height * height_ratio
        base_runout = [calculated_runout, minimum_runout].max

        has_stop_wall ? base_runout + stop_wall_add : base_runout
      end

      sig { params(platform_height: Float, has_stop_wall: T::Boolean).returns(CalculatorResponse) }
      def calculate_required_runout(platform_height, has_stop_wall: false)
        # EN 14960-1:2019 Section 4.2.11 (Lines 930-939) - Runout requirements
        # Line 934-935: The runout distance must be at least half the height of the slide's
        # highest platform (measured from ground level), with an absolute minimum of 300mm
        # Line 936: If a stop-wall is installed at the runout's end, an additional
        # 50cm must be added to the total runout length
        return CalculatorResponse.new(value: 0, value_suffix: "m", breakdown: []) if platform_height <= 0

        # Get constants
        height_ratio = Constants::RUNOUT_CALCULATION_CONSTANTS[:platform_height_ratio]
        minimum_runout = Constants::RUNOUT_CALCULATION_CONSTANTS[:minimum_runout_meters]
        stop_wall_add = Constants::RUNOUT_CALCULATION_CONSTANTS[:stop_wall_addition]

        # Calculate values using the shared method
        calculated_runout = platform_height * height_ratio
        base_runout = calculate_runout_value(platform_height, has_stop_wall: false)
        final_runout = calculate_runout_value(platform_height, has_stop_wall: has_stop_wall)

        # Build breakdown
        breakdown = [
          ["50% calculation", "#{platform_height}m × 0.5 = #{calculated_runout}m"],
          ["Minimum requirement", "#{minimum_runout}m (300mm)"],
          ["Base runout", "Maximum of #{calculated_runout}m and #{minimum_runout}m = #{base_runout}m"]
        ]

        # Add stop-wall if applicable
        if has_stop_wall
          breakdown << ["Stop-wall addition", "#{base_runout}m + #{stop_wall_add}m = #{final_runout}m"]
        end

        CalculatorResponse.new(
          value: final_runout,
          value_suffix: "m",
          breakdown: breakdown
        )
      end

      sig { params(platform_height: Float, user_height: Float, containing_wall_height: Float, has_permanent_roof: T::Boolean).returns(T::Boolean) }
      def meets_height_requirements?(platform_height, user_height, containing_wall_height, has_permanent_roof)
        # EN 14960-1:2019 Section 4.2.9 (Lines 854-887) - Containment requirements
        # Lines 859-860: Containing walls become mandatory for platforms exceeding 0.6m in height
        # Lines 861-862: Platforms between 0.6m and 3.0m need walls at least as tall as the maximum user height
        # Lines 863-864: Platforms between 3.0m and 6.0m require walls at least 1.25 times the maximum user height OR a permanent roof
        # Lines 865-866: Platforms over 6.0m must have both containing walls and a permanent roof structure

        enhanced_multiplier = Constants::WALL_HEIGHT_CONSTANTS[:enhanced_height_multiplier]
        thresholds = Constants::SLIDE_HEIGHT_THRESHOLDS

        case platform_height
        when 0..thresholds[:no_walls_required]
          true # No containing walls required
        when (thresholds[:no_walls_required]..thresholds[:basic_walls])
          containing_wall_height >= user_height
        when (thresholds[:basic_walls]..thresholds[:enhanced_walls])
          # EITHER walls at 1.25x user height OR permanent roof
          has_permanent_roof || containing_wall_height >= (user_height * enhanced_multiplier)
        when (thresholds[:enhanced_walls]..thresholds[:max_safe_height])
          # BOTH containing walls AND permanent roof required
          has_permanent_roof && containing_wall_height >= (user_height * enhanced_multiplier)
        else
          false # Exceeds safe height limits
        end
      end

      sig { params(runout_length: Float, platform_height: Float, has_stop_wall: T::Boolean).returns(T::Boolean) }
      def meets_runout_requirements?(runout_length, platform_height, has_stop_wall: false)
        # EN 14960-1:2019 Section 4.2.11 (Lines 930-939) - Runout requirements
        # Lines 934-935: The runout area must extend at least half the platform's height
        # or 300mm (whichever is greater) to allow users to decelerate safely

        required_runout = calculate_runout_value(platform_height, has_stop_wall: has_stop_wall)
        runout_length >= required_runout
      end

      sig { returns(String) }
      def slide_runout_formula_text
        ratio_constant = Constants::RUNOUT_CALCULATION_CONSTANTS[:platform_height_ratio]
        height_ratio = (ratio_constant * 100).to_i
        min_constant = Constants::RUNOUT_CALCULATION_CONSTANTS[:minimum_runout_meters]
        min_runout = (min_constant * 1000).to_i
        "#{height_ratio}% of platform height, minimum #{min_runout}mm"
      end

      sig { params(platform_height: Float, user_height: Float, has_permanent_roof: T.nilable(T::Boolean)).returns(CalculatorResponse) }
      def calculate_wall_height_requirements(platform_height, user_height, has_permanent_roof = nil)
        # EN 14960-1:2019 Section 4.2.9 (Lines 854-887) - Containment requirements
        return CalculatorResponse.new(value: 0, value_suffix: "m", breakdown: []) if platform_height <= 0 || user_height <= 0

        # Get requirement details and breakdown
        requirement_details = get_wall_height_requirement_details(platform_height, user_height, has_permanent_roof)

        # Extract the required wall height from the details
        required_height = extract_required_wall_height(platform_height, user_height)

        CalculatorResponse.new(
          value: required_height,
          value_suffix: "m",
          breakdown: requirement_details[:breakdown]
        )
      end

      sig { params(platform_height: Float, user_height: Float, has_permanent_roof: T.nilable(T::Boolean)).returns(T::Hash[Symbol, T.untyped]) }
      def get_wall_height_requirement_details(platform_height, user_height, has_permanent_roof)
        thresholds = Constants::SLIDE_HEIGHT_THRESHOLDS
        enhanced_multiplier = Constants::WALL_HEIGHT_CONSTANTS[:enhanced_height_multiplier]

        case platform_height
        when 0..thresholds[:no_walls_required]
          {
            text: "No containing walls required",
            breakdown: [
              ["Height range", "Under 0.6m"],
              ["Requirement", "No containing walls required"]
            ]
          }
        when (thresholds[:no_walls_required]..thresholds[:basic_walls])
          {
            text: "Walls must be at least #{user_height}m (equal to user height)",
            breakdown: [
              ["Height range", "0.6m - 3.0m"],
              ["Calculation", "#{user_height}m (user height)"]
            ]
          }
        when (thresholds[:basic_walls]..thresholds[:enhanced_walls])
          required_height = (user_height * enhanced_multiplier).round(2)

          # Skip wall height requirement message if permanent roof is present
          if has_permanent_roof
            breakdown = [
              ["Height range", "3.0m - 6.0m"],
              ["Wall requirement", "#{required_height}m (1.25× user height) - skipped due to permanent roof"],
              ["Alternative requirement", "Permanent roof (can replace heightened walls)"],
              ["Permanent roof", "Fitted ✓"]
            ]
            text = "Permanent roof fitted - wall height requirement satisfied"
          else
            breakdown = [
              ["Height range", "3.0m - 6.0m"],
              ["Calculation", "#{user_height}m × #{enhanced_multiplier} = #{required_height}m"],
              ["Alternative requirement", "Permanent roof (can replace heightened walls)"]
            ]

            # Add roof status if known
            if !has_permanent_roof.nil?
              breakdown << ["Permanent roof", "Not fitted ✗"]
            end

            text = "Walls must be at least #{required_height}m (1.25× user height)"
          end

          {
            text: text,
            breakdown: breakdown
          }
        when (thresholds[:enhanced_walls]..thresholds[:max_safe_height])
          required_height = (user_height * enhanced_multiplier).round(2)
          breakdown = [
            ["Height range", "Over 6.0m"],
            ["Calculation", "#{user_height}m × #{enhanced_multiplier} = #{required_height}m"],
            ["Additional requirement", "Permanent roof required"]
          ]

          # Add roof status if known
          if !has_permanent_roof.nil?
            breakdown << if has_permanent_roof
              ["Permanent roof", "Required and fitted ✓"]
            else
              ["Permanent roof", "Required but not fitted ✗"]
            end
          end

          {
            text: "Walls must be at least #{required_height}m + permanent roof required",
            breakdown: breakdown
          }
        else
          {
            text: "Platform height exceeds safe limits",
            breakdown: [
              ["Status", "Platform height exceeds safe limits"]
            ]
          }
        end
      end

      sig { params(platform_height: Float).returns(T::Boolean) }
      def requires_permanent_roof?(platform_height)
        # EN 14960-1:2019 Section 4.2.9 (Lines 865-866)
        # Inflatable structures with platforms higher than 6.0m must be equipped
        # with both containing walls and a permanent roof
        threshold = Constants::SLIDE_HEIGHT_THRESHOLDS[:enhanced_walls]
        platform_height > threshold
      end

      sig { returns(String) }
      def wall_height_requirement
        multiplier = Constants::WALL_HEIGHT_CONSTANTS[:enhanced_height_multiplier]
        "Containing walls required #{multiplier} times user height"
      end

      sig { returns(T::Hash[Symbol, T::Hash[Symbol, String]]) }
      def slide_calculations
        # EN 14960:2019 - Comprehensive slide safety requirements
        {
          containing_wall_heights: {
            under_600mm: "No containing walls required",
            between_600_3000mm: "Containing walls required of user height",
            between_3000_6000mm: wall_height_requirement,
            over_6000mm: "Both containing walls AND permanent roof required"
          },
          runout_requirements: {
            minimum_length: "50% of highest platform height",
            absolute_minimum: "300mm in any case",
            maximum_inclination: "Not more than 10°",
            stop_wall_addition: "If fitted, adds 50cm to required run-out length",
            wall_height_requirement: "50% of user height on run-out sides"
          },
          safety_factors: {
            first_metre_gradient: "Special requirements for first metre of slope",
            surface_requirements: "Non-slip surface material required",
            edge_protection: "Rounded edges and smooth transitions"
          }
        }
      end

      private

      sig { params(platform_height: Float, user_height: Float).returns(Float) }
      def extract_required_wall_height(platform_height, user_height)
        thresholds = Constants::SLIDE_HEIGHT_THRESHOLDS
        enhanced_multiplier = Constants::WALL_HEIGHT_CONSTANTS[:enhanced_height_multiplier]

        case platform_height
        when 0..thresholds[:no_walls_required]
          0 # No walls required
        when (thresholds[:no_walls_required]..thresholds[:basic_walls])
          user_height # Equal to user height
        when (thresholds[:basic_walls]..thresholds[:enhanced_walls]),
             (thresholds[:enhanced_walls]..thresholds[:max_safe_height])
          (user_height * enhanced_multiplier).round(2) # 1.25× user height
        else
          0 # Exceeds safe limits
        end
      end
    end
  end
end
