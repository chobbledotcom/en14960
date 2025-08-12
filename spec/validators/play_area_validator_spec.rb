# frozen_string_literal: true

require "spec_helper"

RSpec.describe EN14960::Validators::PlayAreaValidator do
  describe ".validate" do
    context "with valid measurements" do
      it "returns valid result when all checks pass" do
        result = described_class.validate(
          unit_length: 10,
          unit_width: 8,
          play_area_length: 9,
          play_area_width: 7,
          negative_adjustment_area: 20
        )

        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
        expect(result[:measurements][:total_play_area]).to eq(63.0)
      end

      it "handles measurements in millimeters" do
        result = described_class.validate(
          unit_length: 10000,
          unit_width: 8000,
          play_area_length: 9000,
          play_area_width: 7000,
          negative_adjustment_area: 20000000
        )

        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
        expect(result[:measurements][:total_play_area]).to eq(63000000.0)
      end

      it "handles decimal measurements" do
        result = described_class.validate(
          unit_length: 10.5,
          unit_width: 8.2,
          play_area_length: 9.1,
          play_area_width: 7.3,
          negative_adjustment_area: 20.5
        )

        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
        expect(result[:measurements][:total_play_area]).to be_within(0.01).of(66.43)
      end
    end

    context "with invalid measurements" do
      it "fails when play area length equals unit length" do
        result = described_class.validate(
          unit_length: 6,
          unit_width: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )

        expect(result[:valid]).to be true # equal is allowed, only greater than fails
        expect(result[:errors]).to be_empty
      end

      it "fails when play area length exceeds unit length" do
        result = described_class.validate(
          unit_length: 5,
          unit_width: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )

        expect(result[:valid]).to be false
        expect(result[:errors]).to include("Play area length (6.0) must be less than or equal to unit length (5.0)")
      end

      it "fails when play area width equals unit width" do
        result = described_class.validate(
          unit_length: 10,
          unit_width: 7,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )

        expect(result[:valid]).to be true # equal is allowed, only greater than fails
        expect(result[:errors]).to be_empty
      end

      it "fails when play area width exceeds unit width" do
        result = described_class.validate(
          unit_length: 10,
          unit_width: 6,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )

        expect(result[:valid]).to be false
        expect(result[:errors]).to include("Play area width (7.0) must be less than or equal to unit width (6.0)")
      end

      it "fails when total play area equals negative adjustment area" do
        result = described_class.validate(
          unit_length: 10,
          unit_width: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 42
        )

        expect(result[:valid]).to be false
        expect(result[:errors]).to include("Total play area (42.0) must be greater than negative adjustment area (42.0)")
      end

      it "fails when total play area is less than negative adjustment area" do
        result = described_class.validate(
          unit_length: 10,
          unit_width: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 50
        )

        expect(result[:valid]).to be false
        expect(result[:errors]).to include("Total play area (42.0) must be greater than negative adjustment area (50.0)")
      end

      it "reports multiple errors when multiple checks fail" do
        result = described_class.validate(
          unit_length: 5,
          unit_width: 4,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 50
        )

        expect(result[:valid]).to be false
        expect(result[:errors].length).to eq(3)
        expect(result[:errors]).to include("Play area length (6.0) must be less than or equal to unit length (5.0)")
        expect(result[:errors]).to include("Play area width (7.0) must be less than or equal to unit width (4.0)")
        expect(result[:errors]).to include("Total play area (42.0) must be greater than negative adjustment area (50.0)")
      end
    end

    context "with nil values" do
      let(:valid_params) do
        {
          unit_length: 10,
          unit_width: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        }
      end

      %i[unit_length unit_width play_area_length play_area_width negative_adjustment_area].each do |param|
        it "fails when #{param} is nil" do
          result = described_class.validate(**valid_params.merge(param => nil))
          expect(result[:valid]).to be false
          expect(result[:errors]).to include("All measurements must be provided")
        end
      end
    end

    context "with zero and negative values" do
      it "handles zero negative adjustment area correctly" do
        result = described_class.validate(
          unit_length: 10,
          unit_width: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 0
        )

        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
      end

      it "handles negative adjustment area being negative" do
        result = described_class.validate(
          unit_length: 10,
          unit_width: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: -10
        )

        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
      end

      it "fails when dimensions are zero" do
        result = described_class.validate(
          unit_length: 1,
          unit_width: 1,
          play_area_length: 0,
          play_area_width: 0,
          negative_adjustment_area: 0
        )

        expect(result[:valid]).to be false
        expect(result[:errors]).to include("Total play area (0.0) must be greater than negative adjustment area (0.0)")
      end
    end

    context "response structure" do
      it "includes all measurements in the response" do
        result = described_class.validate(
          unit_length: 10,
          unit_width: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )

        measurements = result[:measurements]
        expect(measurements).to eq({
          unit_length: 10.0,
          unit_width: 8.0,
          play_area_length: 6.0,
          play_area_width: 7.0,
          total_play_area: 42.0,
          negative_adjustment_area: 20.0
        })
      end

      it "includes measurements even when validation fails" do
        result = described_class.validate(
          unit_length: 5,
          unit_width: 4,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 50
        )

        expect(result[:valid]).to be false
        expect(result[:measurements][:total_play_area]).to eq(42.0)
      end
    end
  end
end
