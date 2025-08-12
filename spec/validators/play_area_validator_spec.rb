# frozen_string_literal: true

require "spec_helper"

RSpec.describe EN14960::Validators::PlayAreaValidator do
  describe ".validate" do
    context "with valid measurements" do
      it "returns valid result when all checks pass" do
        result = described_class.validate(
          unit_length: 10,
          unit_height: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )
        
        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
        expect(result[:measurements][:total_play_area]).to eq(42.0)
      end
      
      it "handles measurements in millimeters" do
        result = described_class.validate(
          unit_length: 10000,
          unit_height: 8000,
          play_area_length: 6000,
          play_area_width: 7000,
          negative_adjustment_area: 20000000
        )
        
        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
        expect(result[:measurements][:total_play_area]).to eq(42000000.0)
      end
      
      it "handles decimal measurements" do
        result = described_class.validate(
          unit_length: 10.5,
          unit_height: 8.2,
          play_area_length: 6.1,
          play_area_width: 7.3,
          negative_adjustment_area: 20.5
        )
        
        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
        expect(result[:measurements][:total_play_area]).to be_within(0.01).of(44.53)
      end
    end
    
    context "with invalid measurements" do
      it "fails when play area length equals unit height" do
        result = described_class.validate(
          unit_length: 10,
          unit_height: 6,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )
        
        expect(result[:valid]).to be false
        expect(result[:errors]).to include("Play area length (6.0) must be less than unit height (6.0)")
      end
      
      it "fails when play area length exceeds unit height" do
        result = described_class.validate(
          unit_length: 10,
          unit_height: 5,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )
        
        expect(result[:valid]).to be false
        expect(result[:errors]).to include("Play area length (6.0) must be less than unit height (5.0)")
      end
      
      it "fails when play area width equals unit length" do
        result = described_class.validate(
          unit_length: 7,
          unit_height: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )
        
        expect(result[:valid]).to be false
        expect(result[:errors]).to include("Play area width (7.0) must be less than unit length (7.0)")
      end
      
      it "fails when play area width exceeds unit length" do
        result = described_class.validate(
          unit_length: 6,
          unit_height: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )
        
        expect(result[:valid]).to be false
        expect(result[:errors]).to include("Play area width (7.0) must be less than unit length (6.0)")
      end
      
      it "fails when total play area equals negative adjustment area" do
        result = described_class.validate(
          unit_length: 10,
          unit_height: 8,
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
          unit_height: 8,
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
          unit_height: 4,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 50
        )
        
        expect(result[:valid]).to be false
        expect(result[:errors].length).to eq(3)
        expect(result[:errors]).to include("Play area length (6.0) must be less than unit height (4.0)")
        expect(result[:errors]).to include("Play area width (7.0) must be less than unit length (5.0)")
        expect(result[:errors]).to include("Total play area (42.0) must be greater than negative adjustment area (50.0)")
      end
    end
    
    context "with nil values" do
      it "fails when unit_length is nil" do
        result = described_class.validate(
          unit_length: nil,
          unit_height: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )
        
        expect(result[:valid]).to be false
        expect(result[:errors]).to include("All measurements must be provided (non-nil)")
      end
      
      it "fails when unit_height is nil" do
        result = described_class.validate(
          unit_length: 10,
          unit_height: nil,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )
        
        expect(result[:valid]).to be false
        expect(result[:errors]).to include("All measurements must be provided (non-nil)")
      end
      
      it "fails when play_area_length is nil" do
        result = described_class.validate(
          unit_length: 10,
          unit_height: 8,
          play_area_length: nil,
          play_area_width: 7,
          negative_adjustment_area: 20
        )
        
        expect(result[:valid]).to be false
        expect(result[:errors]).to include("All measurements must be provided (non-nil)")
      end
      
      it "fails when play_area_width is nil" do
        result = described_class.validate(
          unit_length: 10,
          unit_height: 8,
          play_area_length: 6,
          play_area_width: nil,
          negative_adjustment_area: 20
        )
        
        expect(result[:valid]).to be false
        expect(result[:errors]).to include("All measurements must be provided (non-nil)")
      end
      
      it "fails when negative_adjustment_area is nil" do
        result = described_class.validate(
          unit_length: 10,
          unit_height: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: nil
        )
        
        expect(result[:valid]).to be false
        expect(result[:errors]).to include("All measurements must be provided (non-nil)")
      end
    end
    
    context "with zero and negative values" do
      it "handles zero negative adjustment area correctly" do
        result = described_class.validate(
          unit_length: 10,
          unit_height: 8,
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
          unit_height: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: -10
        )
        
        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
      end
      
      it "fails when dimensions are zero" do
        result = described_class.validate(
          unit_length: 0,
          unit_height: 0,
          play_area_length: 0,
          play_area_width: 0,
          negative_adjustment_area: 0
        )
        
        expect(result[:valid]).to be false
        # Zero play area (0) is not greater than zero negative adjustment (0)
        expect(result[:errors]).to include("Total play area (0.0) must be greater than negative adjustment area (0.0)")
      end
    end
    
    context "response structure" do
      it "includes all measurements in the response" do
        result = described_class.validate(
          unit_length: 10,
          unit_height: 8,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 20
        )
        
        measurements = result[:measurements]
        expect(measurements[:unit_length]).to eq(10.0)
        expect(measurements[:unit_height]).to eq(8.0)
        expect(measurements[:play_area_length]).to eq(6.0)
        expect(measurements[:play_area_width]).to eq(7.0)
        expect(measurements[:total_play_area]).to eq(42.0)
        expect(measurements[:negative_adjustment_area]).to eq(20.0)
      end
      
      it "includes measurements even when validation fails" do
        result = described_class.validate(
          unit_length: 5,
          unit_height: 4,
          play_area_length: 6,
          play_area_width: 7,
          negative_adjustment_area: 50
        )
        
        expect(result[:valid]).to be false
        expect(result[:measurements]).not_to be_empty
        expect(result[:measurements][:total_play_area]).to eq(42.0)
      end
    end
  end
end