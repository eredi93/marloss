# frozen_string_literal: true
#
require "aws-sdk-dynamodb"

require "marloss/version"
require "marloss/error"
require "marloss/store"
require "marloss/locker"

module Marloss

  def self.logger
    @logger ||= ::Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.included(base)
    base.define_singleton_method(:marloss_options) do |opts|
      if opts[:table].nil?
        raise(MissingParameterError, "DynamoDB Hash Key not set")
      elsif opts[:hash_key].nil?
        raise(MissingParameterError, "DynamoDB Table not set")
      end

      define_method(:marloss_options_hash) { opts }

      nil
    end

    base.send(:include, InstanceMethods)
  end

  module InstanceMethods

    def marloss_store
      @marloss_store ||=begin
        table = marloss_options_hash[:table]
        hash_key = marloss_options_hash[:hash_key]
        options = marloss_options_hash.reject do |k, v|
          k == :table || k == :hash_key
        end

        Store.new(table, hash_key, options)
      end
    end

    def marloss_locker(name)
      Locker.new(marloss_store, name)
    end

    def with_marloss_locker(name, opts = {})
      locker = marloss_locker(name)

      locker.wait_until_lock_obtained(opts)

      yield(locker)

      locker.release_lock
    end

  end

end
