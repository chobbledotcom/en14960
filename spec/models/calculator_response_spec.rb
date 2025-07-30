# frozen_string_literal: true

require "spec_helper"

RSpec.describe EN14960::CalculatorResponse do
  describe "initialization" do
    it "creates instance with all attributes" do
      breakdown = [["Step 1", "Value 1"], ["Step 2", "Value 2"]]
      response = described_class.new(
        value: 42,
        value_suffix: "m",
        breakdown: breakdown
      )

      expect(response.value).to eq(42)
      expect(response.value_suffix).to eq("m")
      expect(response.breakdown).to eq(breakdown)
    end

    it "has default values" do
      response = described_class.new(value: 42)
      expect(response.value_suffix).to eq("")
      expect(response.breakdown).to eq([])
    end
  end

  describe "#to_h" do
    it "returns hash representation" do
      breakdown = [["Step 1", "Value 1"]]
      response = described_class.new(
        value: 42,
        value_suffix: "m",
        breakdown: breakdown
      )

      expect(response.to_h).to eq({
        value: 42,
        value_suffix: "m",
        breakdown: breakdown
      })
    end
  end

  describe "#as_json" do
    it "is an alias for to_h" do
      response = described_class.new(value: 42)
      expect(response.as_json).to eq(response.to_h)
    end
  end
end
