# frozen_string_literal: true

require "spec_helper"

RSpec.describe EN14960::Calculators::SlideCalculator do
  describe ".calculate_runout_value" do
    context "without stop-wall" do
      it "calculates 50% of platform height" do
        result = described_class.calculate_runout_value(2.0, has_stop_wall: false)
        expect(result).to eq(1.0)
      end

      it "enforces 0.3m minimum runout" do
        result = described_class.calculate_runout_value(0.5, has_stop_wall: false)
        expect(result).to eq(0.3)
      end

      it "returns 0.3m for very low platforms" do
        result = described_class.calculate_runout_value(0.1, has_stop_wall: false)
        expect(result).to eq(0.3)
      end
    end

    context "with stop-wall" do
      it "adds 0.5m to calculated runout" do
        result = described_class.calculate_runout_value(2.0, has_stop_wall: true)
        expect(result).to eq(1.5) # 1.0m + 0.5m
      end

      it "adds 0.5m to minimum runout when applicable" do
        result = described_class.calculate_runout_value(0.5, has_stop_wall: true)
        expect(result).to eq(0.8) # 0.3m minimum + 0.5m
      end
    end

    context "edge cases" do
      it "handles nil platform height" do
        result = described_class.calculate_runout_value(nil, has_stop_wall: false)
        expect(result).to eq(0)
      end

      it "handles negative platform height" do
        result = described_class.calculate_runout_value(-1.0, has_stop_wall: false)
        expect(result).to eq(0)
      end
    end
  end

  describe ".calculate_required_runout" do
    context "basic calculation" do
      it "returns detailed breakdown for standard case" do
        result = described_class.calculate_required_runout(2.0, has_stop_wall: false)

        expect(result.value).to eq(1.0)
        expect(result.value_suffix).to eq("m")
        expect(result.breakdown).to include(
          ["50% calculation", "2.0m × 0.5 = 1.0m"],
          ["Minimum requirement", "0.3m (300mm)"],
          ["Base runout", "Maximum of 1.0m and 0.3m = 1.0m"]
        )
      end

      it "shows minimum applied when calculation is below 0.3m" do
        result = described_class.calculate_required_runout(0.5, has_stop_wall: false)

        expect(result.value).to eq(0.3)
        expect(result.breakdown).to include(
          ["50% calculation", "0.5m × 0.5 = 0.25m"],
          ["Base runout", "Maximum of 0.25m and 0.3m = 0.3m"]
        )
      end
    end

    context "with stop-wall" do
      it "includes stop-wall addition in breakdown" do
        result = described_class.calculate_required_runout(2.0, has_stop_wall: true)

        expect(result.value).to eq(1.5)
        expect(result.breakdown).to include(
          ["Stop-wall addition", "1.0m + 0.5m = 1.5m"]
        )
      end
    end
  end

  describe ".calculate_wall_height_requirements" do
    context "platform height ranges (EN 14960-1:2019)" do
      it "requires 1× user height for platforms 0.6m - 3.0m" do
        result = described_class.calculate_wall_height_requirements(2.0, 1.5)

        expect(result.value).to eq(1.5)
        expect(result.value_suffix).to eq("m")
        expect(result.breakdown).to include(
          ["Height range", "0.6m - 3.0m"],
          ["Calculation", "1.5m (user height)"]
        )
      end

      it "requires 1.25× user height for platforms 3.0m - 6.0m" do
        result = described_class.calculate_wall_height_requirements(4.0, 2.0)

        expect(result.value).to eq(2.5)
        expect(result.value_suffix).to eq("m")
        expect(result.breakdown).to include(
          ["Height range", "3.0m - 6.0m"],
          ["Calculation", "2.0m × 1.25 = 2.5m"]
        )
      end

      it "requires 1.5× user height for platforms above 6.0m" do
        result = described_class.calculate_wall_height_requirements(7.0, 2.0)

        expect(result.value).to eq(2.5)
        expect(result.value_suffix).to eq("m")
        expect(result.breakdown).to include(
          ["Height range", "Over 6.0m"],
          ["Calculation", "2.0m × 1.25 = 2.5m"]
        )
      end
    end

    context "permanent roof alternative" do
      it "mentions permanent roof option for high platforms" do
        result = described_class.calculate_wall_height_requirements(4.0, 2.0)

        expect(result.breakdown).to include(
          ["Alternative requirement", "Permanent roof (can replace heightened walls)"]
        )
      end

      it "doesn't mention permanent roof for low platforms" do
        result = described_class.calculate_wall_height_requirements(2.0, 1.5)

        breakdown_text = result.breakdown.map(&:last).join(" ")
        expect(breakdown_text).not_to include("Permanent roof")
      end

      context "when permanent roof is fitted" do
        it "shows skipped wall requirement in breakdown for 3-6m platforms" do
          result = described_class.calculate_wall_height_requirements(4.0, 2.0, true)

          expect(result.breakdown).to include(
            ["Wall requirement", "2.5m (1.25× user height) - skipped due to permanent roof"]
          )
          expect(result.breakdown).to include(["Permanent roof", "Fitted ✓"])
        end

        it "still returns the calculated wall height value" do
          result = described_class.calculate_wall_height_requirements(4.0, 2.0, true)

          expect(result.value).to eq(2.5)
          expect(result.value_suffix).to eq("m")
        end
      end

      context "when permanent roof is not fitted" do
        it "shows standard wall requirement for 3-6m platforms" do
          result = described_class.calculate_wall_height_requirements(4.0, 2.0, false)

          expect(result.breakdown).to include(
            ["Calculation", "2.0m × 1.25 = 2.5m"]
          )
          expect(result.breakdown).to include(["Permanent roof", "Not fitted ✗"])
        end
      end
    end

    context "edge cases" do
      it "handles nil platform height" do
        result = described_class.calculate_wall_height_requirements(nil, 1.5)
        expect(result.value).to eq(0)
      end

      it "handles nil user height" do
        result = described_class.calculate_wall_height_requirements(2.0, nil)
        expect(result.value).to eq(0)
      end
    end
  end

  describe ".get_wall_height_requirement_details" do
    context "for platforms between 3.0m and 6.0m" do
      context "with permanent roof fitted" do
        it "skips wall height requirement message" do
          result = described_class.get_wall_height_requirement_details(4.0, 2.0, true)

          expect(result[:text]).to eq("Permanent roof fitted - wall height requirement satisfied")
          expect(result[:text]).not_to include("Walls must be at least")
        end

        it "shows wall requirement was skipped in breakdown" do
          result = described_class.get_wall_height_requirement_details(4.0, 2.0, true)

          expect(result[:breakdown]).to include(
            ["Wall requirement", "2.5m (1.25× user height) - skipped due to permanent roof"]
          )
          expect(result[:breakdown]).to include(["Permanent roof", "Fitted ✓"])
        end

        it "calculates correct skipped wall height for different user heights" do
          result = described_class.get_wall_height_requirement_details(5.0, 1.6, true)

          expect(result[:breakdown]).to include(
            ["Wall requirement", "2.0m (1.25× user height) - skipped due to permanent roof"]
          )
        end
      end

      context "without permanent roof" do
        it "shows wall height requirement" do
          result = described_class.get_wall_height_requirement_details(4.0, 2.0, false)

          expect(result[:text]).to eq("Walls must be at least 2.5m (1.25× user height)")
          expect(result[:breakdown]).to include(["Permanent roof", "Not fitted ✗"])
        end
      end

      context "with unknown permanent roof status" do
        it "shows wall height requirement without roof status" do
          result = described_class.get_wall_height_requirement_details(4.0, 2.0, nil)

          expect(result[:text]).to eq("Walls must be at least 2.5m (1.25× user height)")
          expect(result[:breakdown]).not_to include(["Permanent roof", "Fitted ✓"])
          expect(result[:breakdown]).not_to include(["Permanent roof", "Not fitted ✗"])
        end
      end
    end

    context "for platforms under 3.0m" do
      it "is not affected by permanent roof status" do
        result_with_roof = described_class.get_wall_height_requirement_details(2.0, 1.5, true)
        result_without_roof = described_class.get_wall_height_requirement_details(2.0, 1.5, false)

        expect(result_with_roof[:text]).to eq("Walls must be at least 1.5m (equal to user height)")
        expect(result_without_roof[:text]).to eq("Walls must be at least 1.5m (equal to user height)")
      end
    end

    context "for platforms over 6.0m" do
      it "requires both walls and permanent roof" do
        result = described_class.get_wall_height_requirement_details(7.0, 2.0, true)

        expect(result[:text]).to include("2.5m + permanent roof required")
        expect(result[:breakdown]).to include(
          ["Permanent roof", "Required and fitted ✓"]
        )
      end
    end
  end

  describe "predicate methods" do
    describe ".meets_height_requirements?" do
      it "returns true when wall height meets requirement" do
        expect(described_class.meets_height_requirements?(2.0, 1.5, 1.5, false)).to be true
      end

      it "returns false when wall height is below requirement" do
        expect(described_class.meets_height_requirements?(4.0, 2.0, 2.0, false)).to be false
      end

      it "returns true when permanent roof fitted for high platforms" do
        expect(described_class.meets_height_requirements?(4.0, 2.0, 2.0, true)).to be true
      end
    end

    describe ".meets_runout_requirements?" do
      it "returns true when runout meets or exceeds requirement" do
        expect(described_class.meets_runout_requirements?(1.5, 2.0, has_stop_wall: false)).to be true
      end

      it "returns false when runout is below requirement" do
        expect(described_class.meets_runout_requirements?(0.8, 2.0, has_stop_wall: false)).to be false
      end

      it "accounts for stop-wall in requirement" do
        expect(described_class.meets_runout_requirements?(1.5, 2.0, has_stop_wall: true)).to be true
        expect(described_class.meets_runout_requirements?(1.2, 2.0, has_stop_wall: true)).to be false
      end
    end

    describe ".requires_permanent_roof?" do
      it "returns true for platforms above 6m" do
        expect(described_class.requires_permanent_roof?(6.1)).to be true
        expect(described_class.requires_permanent_roof?(7.0)).to be true
      end

      it "returns false for platforms 6m and below" do
        expect(described_class.requires_permanent_roof?(6.0)).to be false
        expect(described_class.requires_permanent_roof?(3.0)).to be false
        expect(described_class.requires_permanent_roof?(1.0)).to be false
      end
    end
  end

  describe "formula text methods" do
    describe ".slide_runout_formula_text" do
      it "returns the standard formula text" do
        expect(described_class.slide_runout_formula_text).to eq(
          "50% of platform height, minimum 300mm"
        )
      end
    end
  end
end
