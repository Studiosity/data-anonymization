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
        total = @fields.count
        if total > 0
          progress = progress_bar.new("#{@name} (bulk)", total)
          process_table progress
          progress.close
        end

        if source_table.respond_to?("connection_handler")
          source_table.connection_handler.clear_all_connections!
        end
      end

      def process_table(progress)
        index = 0

        @fields.each do |column, strategy|
          progress.show index += 1, force: true
          next if is_primary_key? column

          unless column_exists? column
            @errors.log_warning "#{@name}.#{column} does not exist"
            next
          end

          field = DataAnon::Core::Field.new(column, random_string, 1, nil, @name)
          value = strategy.anonymize field

          query = source_table.where.not(column => nil)
          query = query.where(@where_clause) if @where_clause
          if strategy.unsafe?
            query.update_all "#{column} = #{value}"
          else
            query.update_all column => value
          end
        end
      end

      def random_string
        rand(36**rand(5..50)).to_s(36)
      end

      def column_exists?(column)
        column_names.include? column.to_s
      end

      def column_names
        return @column_names if defined? @column_names

        @column_names =
          source_table.
            from('information_schema.columns').
            where('table_name = ?', @name).
            pluck(:column_name)
      rescue PG::UndefinedTable
        []
      rescue StandardError => e
        puts "Unexpected error occurred: #{e}"
        []
      end

    end
  end
end
