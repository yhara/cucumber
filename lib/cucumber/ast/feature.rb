module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature
      attr_accessor :file
      attr_writer :features, :lines

      def initialize(comment, tags, name, feature_elements)
        @comment, @tags, @name, @feature_elements = comment, tags, name, feature_elements
        feature_elements.each{|feature_element| feature_element.feature = self}
        @lines = []
      end

      def accept(visitor)
        visitor.current_feature_lines = @lines
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_feature_name(@name)
        @feature_elements.each do |feature_element|
          visitor.visit_feature_element(feature_element) if feature_element.at_lines?(*@lines)
        end
      end

      def scenario_executed(scenario)
        @features.scenario_executed(scenario) if @features
      end

      def step_executed(step)
        @features.step_executed(step) if @features
      end

      def backtrace_line(step_name, line)
        "#{file_line(line)}:in `#{step_name}'"
      end

      def file_line(line)
        "#{@file}:#{line}"
      end

      def to_sexp
        sexp = [:feature, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        sexp += @feature_elements.map{|e| e.to_sexp}
        sexp
      end
    end
  end
end