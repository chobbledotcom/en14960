# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"
require_relative "en14960/version"
require_relative "en14960/models/calculator_response"
require_relative "en14960/constants"
require_relative "en14960/calculators/anchor_calculator"
require_relative "en14960/calculators/slide_calculator"
require_relative "en14960/calculators/user_capacity_calculator"
require_relative "en14960/validators/material_validator"
require_relative "en14960/validators/play_area_validator"
require_relative "en14960/source_code"

# EN14960 provides calculators and validators for BS EN 14960:2019
# the safety standard for inflatable play equipment
module EN14960
  extend T::Sig

  class Error < StandardError; end

  # Public API methods for easy access to calculators
  class << self
    extend T::Sig
    # Calculate required anchors for inflatable play equipment
    # @param length [Float] Length in meters
    # @param width [Float] Width in meters
    # @param height [Float] Height in meters
    # @return [CalculatorResponse] Response with anchor count and breakdown
    sig { params(length: T.any(Float, Integer), width: T.any(Float, Integer), height: T.any(Float, Integer)).returns(CalculatorResponse) }
    def calculate_anchors(length:, width:, height:)
      Calculators::AnchorCalculator.calculate(length: length, width: width, height: height)
    end

    # Calculate required slide runout distance
    # @param platform_height [Float] Platform height in meters
    # @param has_stop_wall [Boolean] Whether a stop wall is fitted
    # @return [CalculatorResponse] Response with runout distance and breakdown
    sig { params(platform_height: T.any(Float, Integer), has_stop_wall: T::Boolean).returns(CalculatorResponse) }
    def calculate_slide_runout(platform_height, has_stop_wall: false)
      Calculators::SlideCalculator.calculate_required_runout(platform_height, has_stop_wall: has_stop_wall)
    end

    # Calculate wall height requirements for slides
    # @param platform_height [Float] Platform height in meters
    # @param user_height [Float] Maximum user height in meters
    # @param has_permanent_roof [Boolean] Whether unit has permanent roof
    # @return [CalculatorResponse] Response with wall height requirements
    sig { params(platform_height: T.any(Float, Integer), user_height: T.any(Float, Integer), has_permanent_roof: T.nilable(T::Boolean)).returns(CalculatorResponse) }
    def calculate_wall_height(platform_height, user_height, has_permanent_roof = nil)
      Calculators::SlideCalculator.calculate_wall_height_requirements(
        platform_height,
        user_height,
        has_permanent_roof
      )
    end

    # Calculate user capacity based on play area
    # @param length [Float] Length in meters
    # @param width [Float] Width in meters
    # @param max_user_height [Float, nil] Maximum allowed user height
    # @param negative_adjustment_area [Float] Area to subtract for obstacles
    # @return [CalculatorResponse] Response with capacity by user height
    sig { params(length: T.any(Float, Integer), width: T.any(Float, Integer), max_user_height: T.nilable(T.any(Float, Integer)), negative_adjustment_area: T.any(Float, Integer)).returns(CalculatorResponse) }
    def calculate_user_capacity(length, width, max_user_height = nil, negative_adjustment_area = 0)
      Calculators::UserCapacityCalculator.calculate(
        length,
        width,
        max_user_height,
        negative_adjustment_area
      )
    end

    # Check if rope diameter meets safety requirements
    # @param diameter_mm [Float] Rope diameter in millimeters
    # @return [Boolean] Whether diameter is within safe range
    sig { params(diameter_mm: T.any(Float, Integer)).returns(T::Boolean) }
    def valid_rope_diameter?(diameter_mm)
      Validators::MaterialValidator.valid_rope_diameter?(diameter_mm)
    end

    # Get height categories defined by EN 14960:2019
    # @return [Hash] Height categories with labels and requirements
    sig { returns(T::Hash[Symbol, T.untyped]) }
    def height_categories
      Constants::HEIGHT_CATEGORIES
    end

    # Get material standards defined by EN 14960:2019
    # @return [Hash] Material requirements for fabrics, threads, ropes, and netting
    sig { returns(T::Hash[Symbol, T.untyped]) }
    def material_standards
      Constants::MATERIAL_STANDARDS
    end

    # Validate play area measurements
    # @param unit_length [Float] Unit length
    # @param unit_width [Float] Unit width
    # @param play_area_length [Float] Play area length
    # @param play_area_width [Float] Play area width
    # @param negative_adjustment_area [Float] Negative adjustment area
    # @return [Hash] Validation result with errors and measurements
    sig {
      params(
        unit_length: T.any(Float, Integer),
        unit_width: T.any(Float, Integer),
        play_area_length: T.any(Float, Integer),
        play_area_width: T.any(Float, Integer),
        negative_adjustment_area: T.any(Float, Integer)
      ).returns(T::Hash[Symbol, T.untyped])
    }
    def validate_play_area(
      unit_length:,
      unit_width:,
      play_area_length:,
      play_area_width:,
      negative_adjustment_area:
    )
      Validators::PlayAreaValidator.validate(
        unit_length: unit_length,
        unit_width: unit_width,
        play_area_length: play_area_length,
        play_area_width: play_area_width,
        negative_adjustment_area: negative_adjustment_area
      )
    end
  end
end
