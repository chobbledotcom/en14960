# frozen_string_literal: true

require_relative "../constants"
require_relative "../models/calculator_response"

module EN14960
  module Calculators
    module AnchorCalculator
      extend self

      def calculate_required_anchors(area_m2)
        # EN 14960-1:2019 Annex A (Lines 1175-1210) - Anchor calculation formula
        # Force = 0.5 × Cw × ρ × V² × A
        # Where: Cw = 1.5, ρ = 1.24 kg/m³, V = 11.1 m/s (Lines 1194-1199)
        # Number of anchors = Force / 1600N (Line 450 - each anchor withstands 1600N)
        return 0 if area_m2.nil? || area_m2 <= 0

        # Pre-calculated: 0.5 × 1.5 × 1.24 × 11.1² ≈ 114
        area_coeff = Constants::ANCHOR_CALCULATION_CONSTANTS[:area_coefficient]
        base_div = Constants::ANCHOR_CALCULATION_CONSTANTS[:base_divisor]
        safety_mult = Constants::ANCHOR_CALCULATION_CONSTANTS[:safety_factor]

        ((area_m2.to_f * area_coeff * safety_mult) / base_div).ceil
      end

      def calculate(length:, width:, height:)
        # EN 14960-1:2019 Lines 1175-1210 (Annex A) - Calculate exposed surface areas
        front_area = (width * height).round(1)
        sides_area = (length * height).round(1)

        required_front = calculate_required_anchors(front_area)
        required_sides = calculate_required_anchors(sides_area)

        # EN 14960-1:2019 Line 1204 - Calculate for each side
        total_required = (required_front + required_sides) * 2

        # EN 14960-1:2019 Lines 441-442 - "Each inflatable shall have at least six anchorage points"
        minimum = Constants::ANCHOR_CALCULATION_CONSTANTS[:minimum_anchors]
        total_required = [total_required, minimum].max

        area_coeff = Constants::ANCHOR_CALCULATION_CONSTANTS[:area_coefficient]
        base_div = Constants::ANCHOR_CALCULATION_CONSTANTS[:base_divisor]
        safety_mult = Constants::ANCHOR_CALCULATION_CONSTANTS[:safety_factor]

        formula_front = "((#{front_area} × #{area_coeff} * #{safety_mult}) ÷ #{base_div} = #{required_front}"
        formula_sides = "((#{sides_area} × #{area_coeff} * #{safety_mult}) ÷ #{base_div} = #{required_sides}"

        calculated_total = (required_front + required_sides) * 2

        breakdown = [
          ["Front/back area", "#{width}m (W) × #{height}m (H) = #{front_area}m²"],
          ["Sides area", "#{length}m (L) × #{height}m (H) = #{sides_area}m²"],
          ["Front & back anchor counts", formula_front],
          ["Left & right anchor counts", formula_sides],
          ["Required anchors", "(#{required_front} + #{required_sides}) × 2 = #{calculated_total}"]
        ]

        # Add minimum requirement note if applicable
        if calculated_total < minimum
          breakdown << ["EN 14960 minimum", "Minimum #{minimum} anchors required, using #{minimum}"]
        end

        CalculatorResponse.new(
          value: total_required,
          value_suffix: "",
          breakdown: breakdown
        )
      end

      def anchor_formula_text
        area_coeff = Constants::ANCHOR_CALCULATION_CONSTANTS[:area_coefficient]
        base_div = Constants::ANCHOR_CALCULATION_CONSTANTS[:base_divisor]
        safety_fact = Constants::ANCHOR_CALCULATION_CONSTANTS[:safety_factor]
        "((Area × #{area_coeff} × #{safety_fact}) ÷ #{base_div})"
      end

      def anchor_calculation_description
        "Anchors must be calculated based on the play area to ensure adequate ground restraint for wind loads."
      end
    end
  end
end
