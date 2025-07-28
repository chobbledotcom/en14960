# frozen_string_literal: true

module EN14960
  module SourceCode
    def self.get_method_source(method_name, module_name, additional_methods = [])
      method_obj = module_name.method(method_name)
      source_location = method_obj.source_location

      return "Source code not available" unless source_location

      file_path, line_number = source_location
      return "Source file not found" unless File.exist?(file_path)

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
          additional_obj = module_name.method(additional_method)
          additional_location = additional_obj.source_location
          if additional_location && additional_location[0] == file_path
            additional_lines = extract_method_lines(lines, additional_location[1] - 1, additional_method)
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

    private_class_method def self.get_module_constants(module_name, method_name)
      module_name.constants.select do |const_name|
        module_name.const_get(const_name).is_a?(Hash)
      end
    end

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

    private_class_method def self.extract_method_lines(lines, start_line, method_name)
      method_lines = []
      current_line = start_line
      indent_level = nil

      while current_line < lines.length
        line = lines[current_line]
        if line.strip.start_with?("def #{method_name}")
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

        if line.strip == "end" && (line.index(/\S/) || 0) <= indent_level
          break
        end

        current_line += 1
      end

      method_lines
    end

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
