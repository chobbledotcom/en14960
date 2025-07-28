# frozen_string_literal: true

module EN14960
  module Constants
    # Height category constants based on EN 14960:2019
    HEIGHT_CATEGORIES = {
      1000 => {label: "1.0m (Young children)", max_users: :calculate_by_area},
      1200 => {label: "1.2m (Children)", max_users: :calculate_by_area},
      1500 => {label: "1.5m (Adolescents)", max_users: :calculate_by_area},
      1800 => {label: "1.8m (Adults)", max_users: :calculate_by_area}
    }.freeze

    # Grounding test weights by user height (EN 14960:2019)
    GROUNDING_TEST_WEIGHTS = {
      height_1000mm: 25,               # kg test weight for 1.0m users
      height_1200mm: 35,               # kg test weight for 1.2m users
      height_1500mm: 65,               # kg test weight for 1.5m users
      height_1800mm: 85                # kg test weight for 1.8m users
    }.freeze

    # Reinspection interval
    REINSPECTION_INTERVAL_DAYS = 365  # days

    # Anchor calculation constants from EN 14960-1:2019
    # Line 450: Each anchor must withstand 1600N force
    # Lines 441-442: Minimum 6 anchorage points required
    # Lines 1194-1199: Cw=1.5, ρ=1.24 kg/m³, V=11.1 m/s
    # Pre-calculated: 0.5 × 1.5 × 1.24 × 11.1² ≈ 114
    ANCHOR_CALCULATION_CONSTANTS = {
      area_coefficient: 114.0,     # Pre-calculated wind force coefficient
      base_divisor: 1600.0,        # Force per anchor in Newtons (Line 450)
      safety_factor: 1.5,          # Safety factor multiplier
      minimum_anchors: 6           # Minimum required anchors (Lines 441-442)
    }.freeze

    # Slide safety thresholds
    SLIDE_HEIGHT_THRESHOLDS = {
      no_walls_required: 0.6,      # Under 600mm
      basic_walls: 3.0,            # 600mm - 3000mm
      enhanced_walls: 6.0,         # 3000mm - 6000mm
      max_safe_height: 8.0         # Maximum recommended height
    }.freeze

    # Slide runout calculation constants (EN 14960:2019)
    RUNOUT_CALCULATION_CONSTANTS = {
      platform_height_ratio: 0.5, # 50% of platform height
      minimum_runout_meters: 0.3,  # Absolute minimum 300mm (0.3m)
      stop_wall_addition: 0.5      # 50cm addition when stop-wall fitted (Line 936)
    }.freeze

    # Wall height calculation constants (EN 14960:2019)
    WALL_HEIGHT_CONSTANTS = {
      enhanced_height_multiplier: 1.25  # 1.25× multiplier for enhanced walls
    }.freeze

    # EN 14960-1:2019 Section 4.3 (Lines 940-961) - Number of users
    # Note: EN 14960 doesn't specify exact calculation formulas, only factors to consider:
    # - Height of user (Line 946)
    # - Size of playing area (Line 954)
    # - Type of activity (Line 956)
    # The calculation below is industry standard practice, not from EN 14960
    AREA_DIVISOR = {
      1000 => 1.0,   # 1 user per m² for 1.0m height
      1200 => 1.33,  # 0.75 users per m² for 1.2m height
      1500 => 1.66,  # 0.60 users per m² for 1.5m height
      1800 => 2.0    # 0.5 users per m² for 1.8m height
    }.freeze

    # Material safety standards (EN 14960:2019 & EN 71-3)
    MATERIAL_STANDARDS = {
      fabric: {
        min_tensile_strength: 1850,    # Newtons minimum
        min_tear_strength: 350,        # Newtons minimum
        fire_standard: "EN 71-3"       # Fire retardancy standard
      },
      thread: {
        min_tensile_strength: 88      # Newtons minimum
      },
      rope: {
        min_diameter: 18,              # mm minimum
        max_diameter: 45,              # mm maximum
        max_swing_percentage: 20       # % maximum swing
      },
      netting: {
        max_vertical_mesh: 30,         # mm maximum for >1m height
        max_roof_mesh: 8               # mm maximum
      }
    }.freeze
  end
end