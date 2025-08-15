# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"

module EN14960
  module SourceCode
    extend T::Sig
    sig { params(method_name: Symbol, module_name: Module, additional_methods: T::Array[Symbol]).returns(String) }
    def self.get_method_source(method_name, module_name, additional_methods = [])
      base_dir = File.expand_path("..", __FILE__)
      
      ruby_files = Dir.glob(File.join(base_dir, "**", "*.rb"))
      
      file_path, line_number = find_method_in_files(ruby_files, method_name)
      
      unless file_path
        raise StandardError, "Source code not available for method: #{method_name}"
      end
      
      lines = File.readlines(file_path)

      constants_code = ""
      module_constants = get_module_constants(module_name, method_name)

      if module_constants.any?
        module_constants.each do |constant_name|
          constant_def = extract_constant_definition(lines, constant_name)
          constants_code += strip_consistent_indentation(constant_def) + "\n"
        end
      end

      methods_code = ""

      additional_methods.each do |additional_method|
        if module_name.respond_to?(additional_method)
          method_line_idx = lines.index { |line| line.strip =~ /^def\s+(self\.)?#{Regexp.escape(additional_method.to_s)}(\(|$|\s)/ }
          if method_line_idx
            additional_lines = extract_method_lines(lines, method_line_idx, additional_method)
            methods_code += strip_consistent_indentation(additional_lines.join("")) + "\n\n"
          end
        end
      end

      method_lines = extract_method_lines(lines, line_number - 1, method_name)
      methods_code += strip_consistent_indentation(method_lines.join(""))

      output = ""
      if constants_code.strip.length > 0
        output += "# Related Constants:\n"
        output += constants_code
        output += "\n# Method Implementation:\n"
      end
      output += methods_code

      output
    end

    sig { params(files: T::Array[String], method_name: Symbol).returns(T.nilable([String, Integer])) }
    private_class_method def self.find_method_in_files(files, method_name)
      files.each do |path|
        if File.exist?(path)
          content = File.read(path)
          if content.match?(/def\s+(self\.)?#{Regexp.escape(method_name.to_s)}(\(|\s|$)/)
            lines = File.readlines(path)
            line_idx = lines.index { |line| line.strip =~ /^def\s+(self\.)?#{Regexp.escape(method_name.to_s)}(\(|$|\s)/ }
            if line_idx
              return [path, line_idx + 1]
            end
          end
        end
      end
      nil
    end

    sig { params(module_name: Module, method_name: Symbol).returns(T::Array[Symbol]) }
    private_class_method def self.get_module_constants(module_name, method_name)
      module_name.constants.select do |const_name|
        module_name.const_get(const_name).is_a?(Hash)
      end
    end

    sig { params(lines: T::Array[String], constant_name: Symbol).returns(String) }
    private_class_method def self.extract_constant_definition(lines, constant_name)
      constant_lines = []
      in_constant = false
      brace_count = 0

      lines.each_with_index do |line, index|
        if line.strip.start_with?("#{constant_name} =")
          in_constant = true
          constant_lines << line
          brace_count += line.count("{") - line.count("}")
          next
        end

        if in_constant
          constant_lines << line
          brace_count += line.count("{") - line.count("}")

          if brace_count <= 0 && (line.strip.end_with?(".freeze") || line.strip == "}")
            break
          end
        end
      end

      constant_lines.join("")
    end

    sig { params(lines: T::Array[String], start_line: Integer, method_name: Symbol).returns(T::Array[String]) }
    private_class_method def self.extract_method_lines(lines, start_line, method_name)
      method_lines = []
      current_line = start_line
      indent_level = nil

      while current_line < lines.length
        line = lines[current_line]
        if line.strip =~ /^def\s+(self\.)?#{Regexp.escape(method_name.to_s)}(\(|$|\s)/
          indent_level = line.index("def")
          method_lines << line
          current_line += 1
          break
        end
        current_line += 1
      end

      return ["Method definition not found"] if indent_level.nil?

      while current_line < lines.length
        line = lines[current_line]
        method_lines << line

        if line.strip == "end" && indent_level && (line.index(/\S/) || 0) <= indent_level
          break
        end

        current_line += 1
      end

      method_lines
    end

    sig { params(source_code: String).returns(String) }
    private_class_method def self.strip_consistent_indentation(source_code)
      lines = source_code.split("\n")

      min_indent = lines.reject(&:empty?).map { |line| line.match(/^(\s*)/)[1].length }.min || 0

      lines.map { |line|
        line.empty? ?
          line :
          line[min_indent..] || ""
      }.join("\n")
    end
  end
end
