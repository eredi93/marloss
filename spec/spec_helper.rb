# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "marloss"

Marloss.logger = Logger.new("/dev/null")

class ClassFixture
  include Marloss
end
