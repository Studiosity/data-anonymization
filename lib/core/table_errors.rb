module DataAnon
  module Core

    class TableErrors
      include Utils::Logging

      attr_reader :errors, :warnings, :table_name

      def initialize table_name
        @table_name = table_name
        @errors = []
        @warnings = []
      end

      def log_error record, exception
        @errors << { :record => record, :exception => exception}
        raise 'Reached limit of error for a table' if @errors.length > 100
      end

      def log_warning(warning)
        @warnings << { :warning => warning}
        raise 'Reached limit of warning for a table' if @warnings.length > 100
      end

      def any?
        errors.length > 0
      end

      def none?
        errors.length == 0
      end

      def any_warnings?
        warnings.length > 0
      end

      def no_warnings?
        warnings.length == 0
      end

      def print
        return if none?

        logger.error("Errors while processing table '#{@table_name}':")
        errors.each do |error|
          logger.error(error[:exception].message)
          logger.error("\n\t" + error[:exception].backtrace.join("\n\t"))
        end
      end

      def print_warnings
        return if no_warnings?

        logger.warn "Warnings while processing table '#{@table_name}':"
        warnings.each do |warning|
          logger.warn warning[:warning]
        end
      end

    end

  end
end
