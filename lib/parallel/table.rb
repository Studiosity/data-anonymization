require 'parallel'

module DataAnon
  module Parallel
    class Table

      def anonymize tables
        ::Parallel.all?(tables, in_threads: 4) do |table|
          begin
            ActiveRecord::Base.connection_pool.with_connection do
              table.progress_bar_class DataAnon::Utils::ParallelProgressBar
              table.process
            end
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
