require "spec_helper"

describe Marloss do

  it "has a version number" do
    expect(Marloss::VERSION).not_to be(nil)
  end

  it "should return the logger" do
    Marloss.logger = nil # make sure it was not set before
    logger = Logger.new(STDOUT)

    allow(Logger).to receive(:new).with(STDOUT).and_return(logger)

    expect(Marloss.logger).to eq(logger)
  end

  it "should set the env and return the new env" do
    logger = Logger.new(STDERR)
    Marloss.logger = logger

    expect(Marloss.logger).to eq(logger)
  end

end
