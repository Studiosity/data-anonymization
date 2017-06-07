module DataAnon
  module Core

    class TableErrors
      include Utils::Logging

      def initialize table_name
        @table_name = table_name
        @errors = []
      end

      def log_error record, exception
        @errors << { :record => record, :exception => exception}
        raise 'Reached limit of error for a table' if @errors.length > 100
      end

      def errors
        @errors
      end

      def any?
        @errors.length > 0
      end

      def none?
        @errors.length == 0
      end

      def print
        return if none?
        logger.error("Errors while processing table '#{@table_name}':")
        @errors.each do |error|
          logger.error(error[:exception])
          logger.error(error[:exception].backtrace.join("\n\t"))
        end
      end

    end

  end
end