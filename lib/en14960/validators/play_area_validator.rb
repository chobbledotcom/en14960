# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"

module EN14960
  module Validators
    module PlayAreaValidator
      extend T::Sig
      extend self

      sig {
        params(
          unit_length: Float,
          unit_width: Float,
          play_area_length: Float,
          play_area_width: Float,
          negative_adjustment_area: Float
        ).returns(T::Hash[Symbol, T.untyped])
      }
      def validate(
        unit_length:,
        unit_width:,
        play_area_length:,
        play_area_width:,
        negative_adjustment_area:
      )
        errors = []

        # All parameters are required, no nil checks needed

        unit_length = unit_length.to_f
        unit_width = unit_width.to_f
        play_area_length = play_area_length.to_f
        play_area_width = play_area_width.to_f
        negative_adjustment_area = negative_adjustment_area.to_f

        if play_area_length > unit_length
          errors << "Play area length (#{play_area_length}) must be less than or equal to unit length (#{unit_length})"
        end

        # Check play area width is less than unit width
        if play_area_width > unit_width
          errors << "Play area width (#{play_area_width}) must be less than or equal to unit width (#{unit_width})"
        end

        # Calculate total play area
        total_play_area = play_area_length * play_area_width

        # Check total play area is more than negative adjustment area
        if total_play_area <= negative_adjustment_area
          errors << "Total play area (#{total_play_area}) must be greater than negative adjustment area (#{negative_adjustment_area})"
        end

        build_response(errors.empty?, errors, {
          unit_length: unit_length,
          unit_width: unit_width,
          play_area_length: play_area_length,
          play_area_width: play_area_width,
          total_play_area: total_play_area,
          negative_adjustment_area: negative_adjustment_area
        })
      end

      private

      sig { params(valid: T::Boolean, errors: T::Array[String], measurements: T::Hash[Symbol, Float]).returns(T::Hash[Symbol, T.untyped]) }
      def build_response(valid, errors, measurements = {})
        {
          valid: valid,
          errors: errors,
          measurements: measurements
        }
      end
    end
  end
end
