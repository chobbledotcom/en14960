# frozen_string_literal: true

require "spec_helper"

RSpec.describe EN14960::Constants do
  describe "USER_CAPACITY_CONSTANTS" do
    it "requires more space per user as height increases" do
      constants = described_class::USER_CAPACITY_CONSTANTS
      
      expect(constants[:space_per_user_1000mm]).to be < constants[:space_per_user_1200mm]
      expect(constants[:space_per_user_1200mm]).to be < constants[:space_per_user_1500mm]
      expect(constants[:space_per_user_1500mm]).to be < constants[:space_per_user_1800mm]
    end
  end

  describe "SLIDE_HEIGHT_THRESHOLDS" do
    it "has progressively stricter requirements at greater heights" do
      thresholds = described_class::SLIDE_HEIGHT_THRESHOLDS
      
      expect(thresholds[:no_walls_required]).to be < thresholds[:basic_walls]
      expect(thresholds[:basic_walls]).to be < thresholds[:enhanced_walls]
      expect(thresholds[:enhanced_walls]).to be < thresholds[:max_safe_height]
    end
  end

  describe "MATERIAL_STANDARDS" do
    it "requires stronger tensile than tear strength for fabric" do
      fabric = described_class::MATERIAL_STANDARDS[:fabric]
      expect(fabric[:min_tensile_strength]).to be > fabric[:min_tear_strength]
    end

    it "has stricter mesh requirements for roof than vertical netting" do
      netting = described_class::MATERIAL_STANDARDS[:netting]
      expect(netting[:max_roof_mesh]).to be < netting[:max_vertical_mesh]
    end
  end
end