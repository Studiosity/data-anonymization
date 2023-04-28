require 'parallel'

module DataAnon
  module Parallel
    class Table

      def anonymize tables
        ::Parallel.all?(tables, in_threads: 4) do |table|
          begin
            table.source_table.connection.reconnect!
            table.progress_bar_class DataAnon::Utils::ParallelProgressBar
            table.process
            true
          rescue => e
            table.errors.log_error nil, e
            logger.error "\n#{e.message} \n #{e.backtrace}"
            false
          end
        end
      end

    end
  end
end
