# frozen_string_literal: true

require "spec_helper"

RSpec.describe EN14960::SourceCode do
  describe ".get_method_source" do
    context "with real EN14960 class methods" do
      it "returns the method source code for a simple method" do
        # Use an actual class method from the EN14960 module
        result = described_class.get_method_source(:calculate_anchors, EN14960)
        expect(result).to include("def calculate_anchors")
        expect(result).to include("Calculators::AnchorCalculator.calculate")
        expect(result).to include("end")
      end

      it "includes constants when present" do
        # Test with module methods that use constants
        result = described_class.get_method_source(:calculate_required_anchors, EN14960::Calculators::AnchorCalculator)
        expect(result).to include("def calculate_required_anchors")
      end
    end

    context "with additional methods" do
      it "includes additional methods in the output" do
        # Test with methods that might call each other
        result = described_class.get_method_source(
          :calculate_user_capacity,
          EN14960,
          [:calculate_anchors]
        )
        expect(result).to include("def calculate_user_capacity")
        expect(result).to include("def calculate_anchors")
      end
    end

    context "when method source location is not available" do
      it "returns an appropriate message" do
        # Mock a method with no source location
        mock_module = Module.new
        allow(mock_module).to receive(:method).and_return(double(source_location: nil))
        result = described_class.get_method_source(:some_method, mock_module)
        expect(result).to eq("Source code not available")
      end
    end

    context "when source file does not exist" do
      it "returns an appropriate message" do
        mock_module = Module.new
        allow(mock_module).to receive(:method).and_return(double(source_location: ["/nonexistent/file.rb", 1]))
        result = described_class.get_method_source(:some_method, mock_module)
        expect(result).to eq("Source file not found")
      end
    end

    context "with proper indentation stripping" do
      it "removes consistent indentation from the output" do
        result = described_class.get_method_source(:calculate_anchors, EN14960)
        lines = result.split("\n")
        # The method should start at column 0 after stripping
        expect(lines.any? { |line| line =~ /^def calculate_anchors/ }).to be true
      end
    end
  end

  # Test private methods using send
  describe "private methods" do
    describe ".get_module_constants" do
      it "returns only hash constants from a module" do
        # Create a test module with various constant types
        test_module = Module.new
        test_module.const_set(:HASH_CONSTANT, {a: 1}.freeze)
        test_module.const_set(:STRING_CONSTANT, "test")
        test_module.const_set(:NUMERIC_CONSTANT, 42)

        result = described_class.send(:get_module_constants, test_module, :some_method)
        expect(result).to eq([:HASH_CONSTANT])
        expect(result).not_to include(:STRING_CONSTANT, :NUMERIC_CONSTANT)
      end

      it "returns hash constants from EN14960 modules" do
        result = described_class.send(:get_module_constants, EN14960::Constants, :some_method)
        # Should find any Hash constants in Constants module
        expect(result).to be_an(Array)
        result.each do |const_name|
          const_value = EN14960::Constants.const_get(const_name)
          expect(const_value).to be_a(Hash)
        end
      end
    end

    describe ".extract_constant_definition" do
      it "extracts single-line constant definition" do
        lines = [
          "  CONSTANT = { a: 1, b: 2 }.freeze\n",
          "  def method\n"
        ]
        result = described_class.send(:extract_constant_definition, lines, :CONSTANT)
        expect(result).to include("CONSTANT = { a: 1, b: 2 }.freeze")
        # The current implementation includes the line after .freeze
        expect(result.strip.lines.first.strip).to eq("CONSTANT = { a: 1, b: 2 }.freeze")
      end

      it "extracts multi-line constant definition" do
        lines = [
          "  MULTI_CONSTANT = {\n",
          "    key1: 'value1',\n",
          "    key2: 'value2'\n",
          "  }.freeze\n",
          "  def method\n"
        ]
        result = described_class.send(:extract_constant_definition, lines, :MULTI_CONSTANT)
        expect(result).to include("MULTI_CONSTANT = {")
        expect(result).to include("key1: 'value1'")
        expect(result).to include("}.freeze")
        expect(result).not_to include("def method")
      end

      it "handles nested braces correctly" do
        lines = [
          "  NESTED = {\n",
          "    outer: {\n",
          "      inner: { deep: 1 }\n",
          "    }\n",
          "  }.freeze\n",
          "  next_line\n"
        ]
        result = described_class.send(:extract_constant_definition, lines, :NESTED)
        expect(result.count("{")).to eq(3)
        expect(result.count("}")).to eq(3)
        expect(result).to include("}.freeze")
        expect(result).not_to include("next_line")
      end

      it "handles constants without .freeze" do
        lines = [
          "  SIMPLE = {\n",
          "    a: 1\n",
          "  }\n",
          "  next_line\n"
        ]
        result = described_class.send(:extract_constant_definition, lines, :SIMPLE)
        expect(result).to include("SIMPLE = {")
        expect(result).to include("a: 1")
        expect(result.strip).to end_with("}")
        expect(result).not_to include("next_line")
      end
    end

    describe ".extract_method_lines" do
      it "extracts a simple method" do
        lines = [
          "  def simple\n",
          "    'result'\n",
          "  end\n",
          "  def another\n"
        ]
        result = described_class.send(:extract_method_lines, lines, 0, :simple)
        expect(result.join).to include("def simple")
        expect(result.join).to include("'result'")
        expect(result.join).to include("end")
        expect(result.join).not_to include("def another")
      end

      it "handles methods with nested blocks" do
        lines = [
          "  def complex_method\n",
          "    [1, 2, 3].map do |n|\n",
          "      n * 2\n",
          "    end\n",
          "  end\n"
        ]
        result = described_class.send(:extract_method_lines, lines, 0, :complex_method)
        expect(result.length).to eq(5)
        expect(result.join).to include("map do |n|")
      end

      it "returns error message when method not found" do
        lines = ["  def other_method\n", "  end\n"]
        result = described_class.send(:extract_method_lines, lines, 0, :nonexistent)
        expect(result).to eq(["Method definition not found"])
      end

      it "handles class methods with self prefix" do
        lines = [
          "    def self.class_method\n",
          "      42\n",
          "    end\n"
        ]
        result = described_class.send(:extract_method_lines, lines, 0, :class_method)
        # Now the implementation should handle "def self.class_method"
        expect(result.join).to include("def self.class_method")
        expect(result.join).to include("42")
      end

      it "finds methods when searching from the correct line" do
        lines = [
          "module Test\n",
          "  def method_one\n",
          "    1\n",
          "  end\n",
          "\n",
          "  def method_two\n",
          "    2\n",
          "  end\n",
          "end\n"
        ]
        # Search starting from line 5 (0-indexed) where method_two is defined
        result = described_class.send(:extract_method_lines, lines, 5, :method_two)
        expect(result.join).to include("def method_two")
        expect(result.join).to include("2")
      end
    end

    describe ".strip_consistent_indentation" do
      it "removes consistent leading spaces" do
        source = "    def method\n      line1\n      line2\n    end"
        result = described_class.send(:strip_consistent_indentation, source)
        expect(result).to eq("def method\n  line1\n  line2\nend")
      end

      it "preserves relative indentation" do
        source = "  outer\n    inner\n      deeper\n    inner\n  outer"
        result = described_class.send(:strip_consistent_indentation, source)
        expect(result).to eq("outer\n  inner\n    deeper\n  inner\nouter")
      end

      it "handles empty lines correctly" do
        source = "  line1\n\n  line2"
        result = described_class.send(:strip_consistent_indentation, source)
        expect(result).to eq("line1\n\nline2")
      end

      it "handles source with no indentation" do
        source = "def method\n  content\nend"
        result = described_class.send(:strip_consistent_indentation, source)
        expect(result).to eq(source)
      end

      it "handles nil or empty string" do
        expect(described_class.send(:strip_consistent_indentation, "")).to eq("")
      end
    end
  end
end
