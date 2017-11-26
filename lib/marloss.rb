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

end
