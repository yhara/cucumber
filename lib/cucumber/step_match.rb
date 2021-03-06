module Cucumber
  class StepMatch #:nodoc:
    attr_reader :step_definition

    def initialize(step_definition, step_name, formatted_step_name, step_arguments)
      @step_definition, @step_name, @formatted_step_name, @step_arguments = step_definition, step_name, formatted_step_name, step_arguments
    end

    def args
      @step_arguments.map{|g| g.val}
    end

    def name
      @formatted_step_name
    end

    def invoke(multiline_arg)
      all_args = args
      all_args << multiline_arg if multiline_arg
      @step_definition.invoke(all_args)
    end

    # Formats the matched arguments of the associated Step. This method
    # is usually called from visitors, which render output.
    #
    # The +format+ can either be a String or a Proc.
    #
    # If it is a String it should be a format string according to
    # <tt>Kernel#sprinf</tt>, for example:
    #
    #   '<span class="param">%s</span></tt>'
    #
    # If it is a Proc, it should take one argument and return the formatted
    # argument, for example:
    #
    #   lambda { |param| "[#{param}]" }
    #
    def format_args(format = lambda{|a| a}, &proc)
      @formatted_step_name || replace_arguments(@step_name, @step_arguments, format, &proc)
    end
    
    def file_colon_line
      @step_definition.file_colon_line
    end

    def backtrace_line
      @step_definition.backtrace_line
    end

    def text_length
      @step_definition.text_length
    end

    def replace_arguments(string, step_arguments, format, &proc)
      s = string.dup
      offset = 0
      step_arguments.each do |step_argument|
        next if step_argument.pos.nil?
        replacement = if block_given?
          proc.call(step_argument.val)
        elsif Proc === format
          format.call(step_argument.val)
        else
          format % step_argument.val
        end

        s[step_argument.pos + offset, step_argument.val.jlength] = replacement
        offset += replacement.length - step_argument.val.jlength
      end
      s
    end
  end
  
  class NoStepMatch #:nodoc:
    attr_reader :step_definition, :name

    def initialize(step, name)
      @step = step
      @name = name
    end
    
    def format_args(format)
      @name
    end

    def file_colon_line
      raise "No file:line for #{@step}" unless @step.file_colon_line
      @step.file_colon_line
    end

    def backtrace_line
      @step.backtrace_line
    end

    def text_length
      @step.text_length
    end
  end
end
