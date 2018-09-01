# frozen_string_literal: true

module Marloss
  class Store # rubocop:disable Metrics/ClassLength
    attr_reader :client, :table, :hash_key, :ttl

    def initialize(table, hash_key, ttl: 30, client_options: {})
      @client = Aws::DynamoDB::Client.new(client_options)
      @table = table
      @hash_key = hash_key
      @ttl = ttl
    end

    def create_table
      create_ddb_table
      wait_until_ddb_table_exists
      set_ddb_table_ttl
    end

    private def create_ddb_table # rubocop:disable Metrics/MethodLength
      client.create_table(
        attribute_definitions: [
          {
            attribute_name: hash_key,
            attribute_type: "S"
          }
        ],
        key_schema: [
          {
            attribute_name: hash_key,
            key_type: "HASH"
          }
        ],
        provisioned_throughput: {
          read_capacity_units: 5,
          write_capacity_units: 5
        },
        table_name: table
      )

      Marloss.logger.info("DynamoDB table created successfully")
    rescue Aws::DynamoDB::Errors::ResourceInUseException => e
      case e.message
      when "Table already exists: #{table}"
        Marloss.logger.warn("DynamoDB table #{table} already exists")
      else
        raise(CreateTableError, e.message)
      end
    end

    private def wait_until_ddb_table_exists
      client.wait_until(:table_exists, table_name: table) do |w|
        w.max_attempts = 10
        w.delay = 1
      end
    rescue Aws::Waiters::Errors::WaiterFailed => e
      Marloss.logger.error("Failed waiting for initialization of table #{table}")
      raise(CreateTableError, e.message)
    end

    private def set_ddb_table_ttl # rubocop:disable Metrics/MethodLength
      client.update_time_to_live(
        table_name: table,
        time_to_live_specification: {
          enabled: true,
          attribute_name: "Expires"
        }
      )

      Marloss.logger.info("DynamoDB table TTL configured successfully")
    rescue Aws::DynamoDB::Errors::ValidationException => e
      case e.message
      when "TimeToLive is already enabled"
        Marloss.logger.warn("TTL attribute is already configured for table #{table}")
      else
        raise(SetTableTtlError, e.message)
      end
    end

    def delete_table
      client.delete_table(table_name: table)

      Marloss.logger.info("DynamoDB table deleted successfully")
    end

    def create_lock(name) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      client.put_item(
        table_name: table,
        item: {
          hash_key => name,
          "ProcessID" => process_id,
          "Expires" => (Time.now + ttl).to_i
        },
        expression_attribute_names: {
          "#E" => "Expires",
          "#P" => "ProcessID"
        },
        expression_attribute_values: {
          ":now" => Time.now.to_i,
          ":process_id" => process_id
        },
        condition_expression: "attribute_not_exists(#{hash_key}) OR #E < :now OR #P = :process_id"
      )

      Marloss.logger.info("Lock for #{name} created successfully, will expire in #{ttl} seconds")
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
      Marloss.logger.error("Failed to create lock for #{name}")

      raise(LockNotObtainedError, e.message)
    end

    def refresh_lock(name) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      client.update_item(
        table_name: table,
        key: { hash_key => name },
        expression_attribute_names: {
          "#E" => "Expires",
          "#P" => "ProcessID"
        },
        expression_attribute_values: {
          ":expires" => (Time.now + ttl).to_i,
          ":now" => Time.now.to_i,
          ":process_id" => process_id
        },
        update_expression: "SET #E = :expires",
        condition_expression: "attribute_exists(#{hash_key}) AND (#E < :now OR #P = :process_id)"
      )

      Marloss.logger.info("Lock for #{name} refreshed successfully, will expire in #{ttl} seconds")
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
      Marloss.logger.error("Failed to refresh lock for #{name}")

      raise(LockNotRefreshedError, e.message)
    end

    def delete_lock(name)
      client.delete_item(key: { hash_key => name }, table_name: table)

      Marloss.logger.info("Lock for #{name} deleted successfully")
    end

    private def process_id
      hostname = `hostname`.chomp
      pid = Process.pid

      "#{hostname}:#{pid}"
    end
  end
end
