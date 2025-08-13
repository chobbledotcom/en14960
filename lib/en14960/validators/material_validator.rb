# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"
require_relative "../constants"

module EN14960
  module Validators
    module MaterialValidator
      extend T::Sig
      extend self

      sig { params(diameter_mm: Float).returns(T::Boolean) }
      def valid_rope_diameter?(diameter_mm)
        # EN 14960:2019 - Rope diameter range prevents finger entrapment while
        # ensuring adequate grip and structural strength

        min_diameter = Constants::MATERIAL_STANDARDS[:rope][:min_diameter]
        max_diameter = Constants::MATERIAL_STANDARDS[:rope][:max_diameter]
        diameter_mm.between?(min_diameter, max_diameter)
      end

      sig { returns(String) }
      def fabric_tensile_requirement
        fabric_standards = Constants::MATERIAL_STANDARDS[:fabric]
        "#{fabric_standards[:min_tensile_strength]} Newtons minimum"
      end

      sig { returns(String) }
      def fabric_tear_requirement
        fabric_standards = Constants::MATERIAL_STANDARDS[:fabric]
        "#{fabric_standards[:min_tear_strength]} Newtons minimum"
      end

      # Additional validation methods
      sig { params(strength_n: Float).returns(T::Boolean) }
      def valid_fabric_tensile_strength?(strength_n)
        strength_n >= Constants::MATERIAL_STANDARDS[:fabric][:min_tensile_strength]
      end

      sig { params(strength_n: Float).returns(T::Boolean) }
      def valid_fabric_tear_strength?(strength_n)
        strength_n >= Constants::MATERIAL_STANDARDS[:fabric][:min_tear_strength]
      end

      sig { params(strength_n: Float).returns(T::Boolean) }
      def valid_thread_tensile_strength?(strength_n)
        strength_n >= Constants::MATERIAL_STANDARDS[:thread][:min_tensile_strength]
      end

      sig { params(mesh_mm: Float, is_roof: T::Boolean).returns(T::Boolean) }
      def valid_netting_mesh?(mesh_mm, is_roof: false)

        max_mesh = is_roof ?
          Constants::MATERIAL_STANDARDS[:netting][:max_roof_mesh] :
          Constants::MATERIAL_STANDARDS[:netting][:max_vertical_mesh]

        mesh_mm <= max_mesh
      end
    end
  end
end
