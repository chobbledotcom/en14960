# frozen_string_literal: true

module EN14960
  # Data class for calculator responses
  # Provides a consistent structure for all calculator results
  class CalculatorResponse < Struct.new(:value, :value_suffix, :breakdown, keyword_init: true)
    def initialize(value:, value_suffix: "", breakdown: [])
      super(value: value, value_suffix: value_suffix, breakdown: breakdown)
    end

    def to_h
      {
        value: value,
        value_suffix: value_suffix,
        breakdown: breakdown
      }
    end

    alias_method :as_json, :to_h
  end
end
