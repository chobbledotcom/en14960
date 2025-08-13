# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"

module EN14960
  # Data class for calculator responses
  # Provides a consistent structure for all calculator results
  class CalculatorResponse < T::Struct
    extend T::Sig

    const :value, T.any(Integer, Float, String, T::Array[T.untyped])
    const :value_suffix, String, default: ""
    const :breakdown, T::Array[T::Array[String]], default: []

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h
      {
        value: value,
        value_suffix: value_suffix,
        breakdown: breakdown
      }
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def as_json
      to_h
    end
  end
end
