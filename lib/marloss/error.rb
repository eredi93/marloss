# frozen_string_literal: true

module Marloss
  class Error < StandardError; end

  class CreateTableError < Error; end

  class SetTableTtlError < Error; end

  class LockNotObtainedError < Error; end

  class LockNotRefreshedError < Error; end

  class MissingParameterError < Error; end
end
