# frozen_string_literal: true

module EN14960
  module Validators
    module PlayAreaValidator
      extend self

      def validate(unit_length:, unit_height:, play_area_length:, play_area_width:, negative_adjustment_area:)
        errors = []

        # Check for nil values
        if [unit_length, unit_height, play_area_length, play_area_width, negative_adjustment_area].any?(&:nil?)
          errors << "All measurements must be provided (non-nil)"
        end

        # Return early if we have nil values
        return build_response(false, errors) unless errors.empty?

        # Convert all to floats for comparison
        unit_length = unit_length.to_f
        unit_height = unit_height.to_f
        play_area_length = play_area_length.to_f
        play_area_width = play_area_width.to_f
        negative_adjustment_area = negative_adjustment_area.to_f

        # Check play area length is less than unit height
        if play_area_length >= unit_height
          errors << "Play area length (#{play_area_length}) must be less than unit height (#{unit_height})"
        end

        # Check play area width is less than unit length
        if play_area_width >= unit_length
          errors << "Play area width (#{play_area_width}) must be less than unit length (#{unit_length})"
        end

        # Calculate total play area
        total_play_area = play_area_length * play_area_width

        # Check total play area is more than negative adjustment area
        if total_play_area <= negative_adjustment_area
          errors << "Total play area (#{total_play_area}) must be greater than negative adjustment area (#{negative_adjustment_area})"
        end

        build_response(errors.empty?, errors, {
          unit_length: unit_length,
          unit_height: unit_height,
          play_area_length: play_area_length,
          play_area_width: play_area_width,
          total_play_area: total_play_area,
          negative_adjustment_area: negative_adjustment_area
        })
      end

      private

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
