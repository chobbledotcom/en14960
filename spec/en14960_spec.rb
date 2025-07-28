# frozen_string_literal: true

require "spec_helper"

RSpec.describe EN14960 do
  it "has a version number" do
    expect(EN14960::VERSION).not_to be nil
  end

  describe "public API" do
    describe ".calculate_anchors" do
      it "calculates required anchors" do
        result = described_class.calculate_anchors(length: 5, width: 4, height: 3)

        expect(result).to be_a(EN14960::CalculatorResponse)
        expect(result.value).to eq(8)
        expect(result.breakdown).to be_an(Array)
      end
    end

    describe ".calculate_slide_runout" do
      it "calculates required runout distance" do
        result = described_class.calculate_slide_runout(2.5)

        expect(result).to be_a(EN14960::CalculatorResponse)
        expect(result.value).to eq(1.25)
        expect(result.value_suffix).to eq("m")
      end

      it "includes stop wall addition when specified" do
        result = described_class.calculate_slide_runout(2.5, has_stop_wall: true)

        expect(result.value).to eq(1.75)
      end
    end

    describe ".calculate_wall_height" do
      it "calculates wall height requirements" do
        result = described_class.calculate_wall_height(2.0, 1.5)

        expect(result).to be_a(EN14960::CalculatorResponse)
        expect(result.value).to eq(1.5)
        expect(result.breakdown).to include(
          ["Height range", "0.6m - 3.0m"]
        )
      end
    end

    describe ".calculate_user_capacity" do
      it "calculates user capacity" do
        result = described_class.calculate_user_capacity(10, 8)

        expect(result).to be_a(EN14960::CalculatorResponse)
        expect(result.value).to be_a(Hash)
        expect(result.value[:users_1000mm]).to eq(80)
        expect(result.value[:users_1200mm]).to eq(60)
        expect(result.value[:users_1500mm]).to eq(48)
        expect(result.value[:users_1800mm]).to eq(40)
      end

      it "respects max user height" do
        result = described_class.calculate_user_capacity(10, 8, 1.5)

        expect(result.value[:users_1000mm]).to eq(80)
        expect(result.value[:users_1200mm]).to eq(60)
        expect(result.value[:users_1500mm]).to eq(48)
        expect(result.value[:users_1800mm]).to eq(0)
      end
    end

    describe ".valid_rope_diameter?" do
      it "validates rope diameter" do
        expect(described_class.valid_rope_diameter?(20)).to be true
        expect(described_class.valid_rope_diameter?(15)).to be false
        expect(described_class.valid_rope_diameter?(50)).to be false
        expect(described_class.valid_rope_diameter?(nil)).to be false
      end
    end

    describe ".height_categories" do
      it "returns height categories" do
        categories = described_class.height_categories

        expect(categories).to be_a(Hash)
        expect(categories[1000][:label]).to eq("1.0m (Young children)")
        expect(categories[1800][:label]).to eq("1.8m (Adults)")
      end
    end

    describe ".material_standards" do
      it "returns material standards" do
        standards = described_class.material_standards

        expect(standards).to be_a(Hash)
        expect(standards[:fabric][:min_tensile_strength]).to eq(1850)
        expect(standards[:rope][:min_diameter]).to eq(18)
      end
    end
  end
end
