require "spec_helper"

module Marloss
  describe Store do

    let(:ddb_client) { instance_double(Aws::DynamoDB::Client) }
    let(:ddb_error) { Aws::DynamoDB::Errors::ConditionalCheckFailedException.new(nil, nil) }
    let(:table) { "my_table" }
    let(:hash_key) { "LockID" }
    let(:ttl) { 10 }
    let(:client_options) { {} }
    let(:store) { described_class.new(table, hash_key, ttl: ttl, client_options: client_options) }

    let(:name) { "my_resource" }
    let(:hostname) { "hostname.local" }
    let(:pid) { 86776 }
    let(:process_id) { "#{hostname}:86776" }
    let(:expires) { (Time.now + ttl).to_i }

    before do
      allow(Aws::DynamoDB::Client).to receive(:new).with(client_options)
        .and_return(ddb_client)
      allow(store).to receive(:`).with("hostname").and_return(hostname)
      allow(Process).to receive(:pid).and_return(pid)
    end

    describe ".create_table" do
      it "should create the DDB table" do
        expect(ddb_client).to receive(:create_table).with(
          attribute_definitions: [
            {
              attribute_name: hash_key, 
              attribute_type: "S", 
            }
          ], 
          key_schema: [
            {
              attribute_name: hash_key, 
              key_type: "HASH", 
            }
          ], 
          provisioned_throughput: {
            read_capacity_units: 5, 
            write_capacity_units: 5, 
          }, 
          table_name: table
        )
        expect(ddb_client).to receive(:update_time_to_live).with(
          table_name: table,
          time_to_live_specification: {
            enabled: true,
            attribute_name: "Expires"
          }
        )

        store.create_table
      end
    end

    describe ".delete_table" do
      it "should delete the DDB table" do
        expect(ddb_client).to receive(:delete_table).with(table_name: table)

        store.delete_table
      end
    end

    describe ".create_lock" do
      it "should create the lock" do
        expect(ddb_client).to receive(:put_item).with(
          table_name: table,
          item: {
            hash_key => name,
            "ProcessID" => process_id,
            "Expires" => expires
          },
          expression_attribute_names: {
            "#E" => "Expires",
            "#P" => "ProcessID"
          },
          expression_attribute_values: {
            ":now" => Time.now.to_i,
            ":process_id" => process_id,
          },
          condition_expression: "attribute_not_exists(#{hash_key}) OR #E < :now OR #P = :process_id"
        )

        store.create_lock(name)
      end

      it "should fail creating the lock and raise error" do
        allow(ddb_client).to receive(:put_item).with(
          table_name: table,
          item: {
            hash_key => name,
            "ProcessID" => process_id,
            "Expires" => expires
          },
          expression_attribute_names: {
            "#E" => "Expires",
            "#P" => "ProcessID"
          },
          expression_attribute_values: {
            ":now" => Time.now.to_i,
            ":process_id" => process_id,
          },
          condition_expression: "attribute_not_exists(#{hash_key}) OR #E < :now OR #P = :process_id"
        ).and_raise(ddb_error)

        expect { store.create_lock(name) }.to raise_error(LockNotObtainedError)
      end
    end

    describe ".refresh_lock" do
      it "should refresh the lock" do
        expect(ddb_client).to receive(:update_item).with(
          table_name: table,
          key: { hash_key => name },
          expression_attribute_names: {
            "#E" => "Expires",
            "#P" => "ProcessID"
          },
          expression_attribute_values: {
            ":expires" => (Time.now + ttl).to_i,
            ":now" => Time.now.to_i,
            ":process_id" => process_id,
          },
          update_expression: "SET #E = :expires", 
          condition_expression: "attribute_exists(#{hash_key}) AND (#E < :now OR #P = :process_id)"
        )

        store.refresh_lock(name)
      end

      it "should fail refreshing the lock and raise error" do
        allow(ddb_client).to receive(:update_item).with(
          table_name: table,
          key: { hash_key => name },
          expression_attribute_names: {
            "#E" => "Expires",
            "#P" => "ProcessID"
          },
          expression_attribute_values: {
            ":expires" => (Time.now + ttl).to_i,
            ":now" => Time.now.to_i,
            ":process_id" => process_id,
          },
          update_expression: "SET #E = :expires", 
          condition_expression: "attribute_exists(#{hash_key}) AND (#E < :now OR #P = :process_id)"
        ).and_raise(ddb_error)

        expect { store.refresh_lock(name) }.to raise_error(LockNotRefreshedError)
      end
    end

    describe ".delete_lock" do
      it "should delete item" do
        expect(ddb_client).to receive(:delete_item)
          .with(key: { hash_key => name }, table_name: table)

        store.delete_lock(name)
      end
    end

  end
end
