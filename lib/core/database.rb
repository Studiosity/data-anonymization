module DataAnon
  module Core

    class Database
      include Utils::Logging

      def initialize name
        @name = name
        @strategy = DataAnon::Strategy::Whitelist
        @user_defaults = {}
        @tables = []
        @execution_strategy = DataAnon::Core::Sequential
        ENV['parallel_execution'] = 'false'
        I18n.enforce_available_locales = false
      end

      def strategy strategy
        @strategy = strategy
      end

      def execution_strategy execution_strategy
        @execution_strategy = execution_strategy
        ENV['parallel_execution'] = 'true' if execution_strategy == DataAnon::Parallel::Table
      end

      def source_db connection_spec
        @source_database = connection_spec
      end

      def destination_db connection_spec
        @destination_database = connection_spec
      end

      def default_field_strategies default_strategies
        @user_defaults = default_strategies
      end

      def table (name, &block)
        table = @strategy.new(@source_database, @destination_database, name, @user_defaults).process_fields(&block)
        @tables << table
      end
      alias :collection :table

      def bulk_table(name, &block)
        @tables << DataAnon::Strategy::BulkTable.new(
          @source_database, @destination_database, name, @user_defaults
        ).process_fields(&block)
      end

      def anonymize
        errors = []
        warnings = []

        begin
          if !@execution_strategy.new.anonymize(@tables) && @execution_strategy == DataAnon::Parallel::Table
            errors << "Parallel anonymisation failed. See errors above"
          end
        rescue => e
          errors << e.message
          logger.error "\n#{e.message} \n #{e.backtrace}"
        end

        if @strategy.whitelist?
          @tables.each do |table|
            if table.fields_missing_strategy.present?
              errors << "Fields missing anonymisation strategy for #{table.name}"
              logger.info('Fields missing the anonymization strategy:')
              table.fields_missing_strategy.print
            end
          end
        end

        @tables.each do |table|
          if table.errors.any?
            errors << "Table errors for #{table.name}"
            table.errors.print
          end

          if table.errors.any_warnings?
            warnings << "Table warnings for #{table.name}:\n#{table.errors.warnings.map { |w| "* #{w}" }.join("\n")}"
            table.errors.print_warnings
          end
        end

        [errors, warnings]
      end

    end

    class Sequential
      def anonymize tables
        tables.each do |table|
          begin
            table.process
          rescue => e
            table.errors.log_error nil, e
            logger.error "\n#{e.message} \n #{e.backtrace}"
          end
        end
        true
      end
    end

  end
end
