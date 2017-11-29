$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "marloss"

Marloss.logger = Logger.new("/dev/null")

class ClassFixture

  include Marloss

end
