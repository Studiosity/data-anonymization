require 'parallel'

module DataAnon
  module Parallel
    class Table

      def anonymize tables
        ::Parallel.each(tables, in_processes: 8) do |table|
          begin
            table.progress_bar_class DataAnon::Utils::ParallelProgressBar
            table.process
          rescue => e
            table.errors.log_error nil, e
            logger.error "\n#{e.message} \n #{e.backtrace}"
          end
        end
      end

    end
  end
end
