require 'parallel'

module DataAnon
  module Parallel
    class Table

      def anonymize tables
        ::Parallel.map(tables, in_processes: 4) do |table|
          begin
            ActiveRecord::Base.connection.reconnect!
            table.progress_bar_class DataAnon::Utils::ParallelProgressBar
            table.process
          rescue => e
            table.errors.log_error nil, e
            logger.error "\n#{e.message} \n #{e.backtrace}"
          end

          table.errors
        end
      end

    end
  end
end
