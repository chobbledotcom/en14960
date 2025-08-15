# frozen_string_literal: true

require "spec_helper"

RSpec.describe EN14960::Calculators::UserCapacityCalculator do
  describe ".calculate" do
    context "with valid dimensions" do
      it "returns CalculatorResponse with correct capacity and breakdown" do
        # 10m x 10m = 100m² area
        result = described_class.calculate(10.0, 10.0)

        expect(result).to be_a(EN14960::CalculatorResponse)
        capacities = result.value
        expect(capacities[:users_1000mm]).to eq(100) # 100 ÷ 1.0 = 100
        expect(capacities[:users_1200mm]).to eq(75) # 100 ÷ 1.33 = 75.18 → 75
        expect(capacities[:users_1500mm]).to eq(60) # 100 ÷ 1.66 = 60.24 → 60
        expect(capacities[:users_1800mm]).to eq(50) # 100 ÷ 2.0 = 50

        # Check breakdown structure
        expect(result.breakdown).to include(
          ["Total area", "10m × 10m = 100m²"],
          ["Usable area", "100m²"]
        )
      end

      it "rounds down fractional users" do
        # 5m x 5m = 25m² area
        result = described_class.calculate(5.0, 5.0)
        capacities = result.value

        expect(capacities[:users_1000mm]).to eq(25) # 25 ÷ 1.0 = 25
        expect(capacities[:users_1200mm]).to eq(18) # 25 ÷ 1.33 = 18.79 → 18
        expect(capacities[:users_1500mm]).to eq(15) # 25 ÷ 1.66 = 15.06 → 15
        expect(capacities[:users_1800mm]).to eq(12) # 25 ÷ 2.0 = 12.5 → 12
      end
    end

    context "with negative adjustment area" do
      it "subtracts adjustment from total area" do
        # 10m x 10m = 100m², minus 20m² = 80m² usable
        result = described_class.calculate(10.0, 10.0, nil, 20.0)
        capacities = result.value

        expect(capacities[:users_1000mm]).to eq(80) # 80 ÷ 1.0 = 80
        expect(capacities[:users_1200mm]).to eq(60) # 80 ÷ 1.33 = 60.15 → 60
        expect(capacities[:users_1500mm]).to eq(48) # 80 ÷ 1.66 = 48.19 → 48
        expect(capacities[:users_1800mm]).to eq(40) # 80 ÷ 2.0 = 40

        # Check breakdown includes adjustment
        expect(result.breakdown).to include(
          ["Obstacles/adjustments", "- 20m²"],
          ["Usable area", "80m²"]
        )
      end

      it "handles adjustment larger than total area" do
        # 5m x 5m = 25m², minus 30m² = 0m² usable
        result = described_class.calculate(5.0, 5.0, nil, 30.0)
        capacities = result.value

        expect(capacities[:users_1000mm]).to eq(0)
        expect(capacities[:users_1200mm]).to eq(0)
        expect(capacities[:users_1500mm]).to eq(0)
        expect(capacities[:users_1800mm]).to eq(0)

        expect(result.breakdown).to include(
          ["Usable area", "0m²"]
        )
      end

      it "treats negative values as positive adjustments" do
        # Negative adjustment is converted to positive
        result = described_class.calculate(10.0, 10.0, nil, -15.0)
        capacities = result.value

        expect(capacities[:users_1000mm]).to eq(85) # (100 - 15) ÷ 1.0 = 85
        expect(result.breakdown).to include(
          ["Obstacles/adjustments", "- 15m²"]
        )
      end
    end

    context "with maximum user height restriction" do
      it "only calculates capacity for allowed heights" do
        result = described_class.calculate(10.0, 10.0, 1.2)
        capacities = result.value

        expect(capacities[:users_1000mm]).to eq(100) # Allowed
        expect(capacities[:users_1200mm]).to eq(75) # Allowed
        expect(capacities[:users_1500mm]).to eq(0) # Not allowed (1.5 > 1.2)
        expect(capacities[:users_1800mm]).to eq(0) # Not allowed (1.8 > 1.2)
      end

      it "calculates all heights when max_user_height is nil" do
        result = described_class.calculate(10.0, 10.0, nil)
        capacities = result.value

        expect(capacities[:users_1000mm]).to eq(100)
        expect(capacities[:users_1200mm]).to eq(75)
        expect(capacities[:users_1500mm]).to eq(60)
        expect(capacities[:users_1800mm]).to eq(50)
      end
    end


    context "EN 14960:2019 compliance" do
      it "uses correct space requirements per user height" do
        # Test the underlying constants match the standard
        result = described_class.calculate(2.0, 1.0) # 2m²

        # 1000mm users: 1m² per user → 2 users
        expect(result.value[:users_1000mm]).to eq(2)

        # 1200mm users: 1.33m² per user → 1 user
        expect(result.value[:users_1200mm]).to eq(1)

        # 1500mm users: 1.66m² per user → 1 user
        expect(result.value[:users_1500mm]).to eq(1)

        # 1800mm users: 2m² per user → 1 user
        expect(result.value[:users_1800mm]).to eq(1)
      end
    end
  end
end
