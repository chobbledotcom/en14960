# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"

module EN14960
  module API
    extend T::Sig

    class << self
      extend T::Sig

      sig { params(length: Float, width: Float, height: Float).returns(CalculatorResponse) }
      def calculate_anchors(length:, width:, height:)
        Calculators::AnchorCalculator.calculate(length: length, width: width, height: height)
      end

      sig { params(platform_height: Float, has_stop_wall: T::Boolean).returns(CalculatorResponse) }
      def calculate_slide_runout(platform_height, has_stop_wall: false)
        Calculators::SlideCalculator.calculate_required_runout(platform_height, has_stop_wall: has_stop_wall)
      end

      sig { params(platform_height: Float, user_height: Float, has_permanent_roof: T.nilable(T::Boolean)).returns(CalculatorResponse) }
      def calculate_wall_height(platform_height, user_height, has_permanent_roof = nil)
        Calculators::SlideCalculator.calculate_wall_height_requirements(
          platform_height,
          user_height,
          has_permanent_roof
        )
      end

      sig { params(length: Float, width: Float, max_user_height: T.nilable(Float), negative_adjustment_area: Float).returns(CalculatorResponse) }
      def calculate_user_capacity(length, width, max_user_height = nil, negative_adjustment_area = 0.0)
        Calculators::UserCapacityCalculator.calculate(
          length,
          width,
          max_user_height,
          negative_adjustment_area
        )
      end

      sig { params(diameter_mm: Float).returns(T::Boolean) }
      def valid_rope_diameter?(diameter_mm)
        Validators::MaterialValidator.valid_rope_diameter?(diameter_mm)
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def height_categories
        Constants::HEIGHT_CATEGORIES
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def material_standards
        Constants::MATERIAL_STANDARDS
      end

      sig {
        params(
          unit_length: Float,
          unit_width: Float,
          play_area_length: Float,
          play_area_width: Float,
          negative_adjustment_area: Float
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
end
