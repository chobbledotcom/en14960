# frozen_string_literal: true

require "spec_helper"

RSpec.describe EN14960::Validators::MaterialValidator do
  describe ".valid_rope_diameter?" do
    context "with valid diameters" do
      it "returns true for diameters within EN14960 range" do
        expect(described_class.valid_rope_diameter?(18.0)).to be true
        expect(described_class.valid_rope_diameter?(30.0)).to be true
        expect(described_class.valid_rope_diameter?(45.0)).to be true
      end

      it "returns true for boundary values" do
        expect(described_class.valid_rope_diameter?(18.0)).to be true
        expect(described_class.valid_rope_diameter?(45.0)).to be true
      end
    end

    context "with invalid diameters" do
      it "returns false for diameters below minimum" do
        expect(described_class.valid_rope_diameter?(17.0)).to be false
        expect(described_class.valid_rope_diameter?(10.0)).to be false
      end

      it "returns false for diameters above maximum" do
        expect(described_class.valid_rope_diameter?(46.0)).to be false
        expect(described_class.valid_rope_diameter?(50.0)).to be false
      end
    end
  end

  describe ".valid_fabric_tensile_strength?" do
    context "with valid strengths" do
      it "returns true for strength at or above minimum" do
        expect(described_class.valid_fabric_tensile_strength?(1850.0)).to be true
        expect(described_class.valid_fabric_tensile_strength?(2000.0)).to be true
        expect(described_class.valid_fabric_tensile_strength?(3000.0)).to be true
      end
    end

    context "with invalid strengths" do
      it "returns false for strength below minimum" do
        expect(described_class.valid_fabric_tensile_strength?(1849.0)).to be false
        expect(described_class.valid_fabric_tensile_strength?(1000.0)).to be false
      end
    end
  end

  describe ".valid_fabric_tear_strength?" do
    context "with valid strengths" do
      it "returns true for strength at or above minimum" do
        expect(described_class.valid_fabric_tear_strength?(350.0)).to be true
        expect(described_class.valid_fabric_tear_strength?(500.0)).to be true
        expect(described_class.valid_fabric_tear_strength?(1000.0)).to be true
      end
    end

    context "with invalid strengths" do
      it "returns false for strength below minimum" do
        expect(described_class.valid_fabric_tear_strength?(349.0)).to be false
        expect(described_class.valid_fabric_tear_strength?(300.0)).to be false
      end
    end
  end

  describe ".valid_thread_tensile_strength?" do
    context "with valid strengths" do
      it "returns true for strength at or above minimum" do
        expect(described_class.valid_thread_tensile_strength?(88.0)).to be true
        expect(described_class.valid_thread_tensile_strength?(100.0)).to be true
        expect(described_class.valid_thread_tensile_strength?(200.0)).to be true
      end
    end

    context "with invalid strengths" do
      it "returns false for strength below minimum" do
        expect(described_class.valid_thread_tensile_strength?(87.0)).to be false
        expect(described_class.valid_thread_tensile_strength?(50.0)).to be false
      end
    end
  end

  describe ".valid_netting_mesh?" do
    context "for vertical netting" do
      it "returns true for mesh at or below maximum" do
        expect(described_class.valid_netting_mesh?(30.0, is_roof: false)).to be true
        expect(described_class.valid_netting_mesh?(20.0, is_roof: false)).to be true
        expect(described_class.valid_netting_mesh?(10.0, is_roof: false)).to be true
      end

      it "returns false for mesh above maximum" do
        expect(described_class.valid_netting_mesh?(31.0, is_roof: false)).to be false
        expect(described_class.valid_netting_mesh?(50.0, is_roof: false)).to be false
      end
    end

    context "for roof netting" do
      it "returns true for mesh at or below maximum" do
        expect(described_class.valid_netting_mesh?(8.0, is_roof: true)).to be true
        expect(described_class.valid_netting_mesh?(5.0, is_roof: true)).to be true
        expect(described_class.valid_netting_mesh?(3.0, is_roof: true)).to be true
      end

      it "returns false for mesh above maximum" do
        expect(described_class.valid_netting_mesh?(9.0, is_roof: true)).to be false
        expect(described_class.valid_netting_mesh?(20.0, is_roof: true)).to be false
      end
    end
  end

  describe "requirement text methods" do
    describe ".fabric_tensile_requirement" do
      it "returns the correct requirement text" do
        expect(described_class.fabric_tensile_requirement).to eq(
          "1850 Newtons minimum"
        )
      end
    end

    describe ".fabric_tear_requirement" do
      it "returns the correct requirement text" do
        expect(described_class.fabric_tear_requirement).to eq(
          "350 Newtons minimum"
        )
      end
    end
  end

  describe "EN 14960:2019 compliance" do
    it "uses correct material standards from Constants" do
      # Verify the constants match EN 14960:2019 requirements
      rope_standards = EN14960::Constants::MATERIAL_STANDARDS[:rope]
      expect(rope_standards[:min_diameter]).to eq(18)
      expect(rope_standards[:max_diameter]).to eq(45)

      fabric_standards = EN14960::Constants::MATERIAL_STANDARDS[:fabric]
      expect(fabric_standards[:min_tensile_strength]).to eq(1850)
      expect(fabric_standards[:min_tear_strength]).to eq(350)

      thread_standards = EN14960::Constants::MATERIAL_STANDARDS[:thread]
      expect(thread_standards[:min_tensile_strength]).to eq(88)

      netting_standards = EN14960::Constants::MATERIAL_STANDARDS[:netting]
      expect(netting_standards[:max_vertical_mesh]).to eq(30)
      expect(netting_standards[:max_roof_mesh]).to eq(8)
    end
  end
end
