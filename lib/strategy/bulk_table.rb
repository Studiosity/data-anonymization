module DataAnon
  module Strategy
    class BulkTable < DataAnon::Strategy::Base

      def initialize source_database, destination_database, name, user_strategies
        raise 'Incompatible request (destination database not supported)' if destination_database
        super
      end

      def batch_size size
        raise 'Does not compute'
      end

      def limit limit
        raise 'Does not compute'
      end

      def skip
        raise 'Does not compute'
      end

      def continue
        raise 'Does not compute'
      end

      def where(clause)
        @where_clause = clause
      end

      def process
        logger.debug "Bulk processing table #{@name} with fields strategies #{@fields}"
        total = source_table.count
        if total > 0
          progress = progress_bar.new(@name, total)
          progress.show total / 2

          process_table

          progress.show total
          progress.close
        end

        if source_table.respond_to?('clear_all_connections!')
          source_table.clear_all_connections!
        end
      end

      def process_table
        updates = @fields.each_with_object({}) do |(column, strategy), acc|
          field = DataAnon::Core::Field.new(column, random_string, 1, nil, @name)
          acc[column] = strategy.anonymize field
        end

        query = source_table
        query = query.where(@where_clause) if @where_clause
        query.update_all updates
      end

      def random_string
        rand(36**rand(1..50)).to_s(36)
      end

    end
  end
end
