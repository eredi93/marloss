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

  describe ".included" do
    let(:marloss_store) { instance_double(Marloss::Store) }
    let(:marloss_locker) { instance_double(Marloss::Locker) }
    let(:lock_name) { "biz" }
    let(:marloss_options) do
      {
        table: "foo",
        hash_key: "ID",
        ttl: 40,
        client_options: { region: "eu-west-1" }
      }
    end

    before do
      @klass = ClassFixture
      allow(Marloss::Store).to receive(:new).and_return(marloss_store)
      allow(Marloss::Locker).to receive(:new).with(marloss_store, lock_name)
        .and_return(marloss_locker)
    end

    it "the fixture should include marloss" do
      expect(@klass.included_modules.include?(Marloss)).to eq(true)
    end

    context "with missing table" do
      let(:marloss_options) { { hash_key: "ID" } }

      it "should raise a validation error" do
        expect do
          ClassFixture.marloss_options(marloss_options)
        end.to raise_error(Marloss::MissingParameterError)
      end
    end

    context "with missing hash_key" do
      let(:marloss_options) { { table: "foo" } }

      it "should raise a validation error" do
        expect do
          ClassFixture.marloss_options(marloss_options)
        end.to raise_error(Marloss::MissingParameterError)
      end
    end

    context "with table and hash_key" do
      let(:class_instance) { @klass.new }

      before do
        @klass.marloss_options(marloss_options)
      end

      describe ".marloss_store" do
        it "should return the marloss store" do
          expect(class_instance.marloss_store).to eq(marloss_store)
        end
      end

      describe ".marloss_locker" do
        it "should return the marloss store" do
          expect(class_instance.marloss_locker(lock_name)).to eq(marloss_locker)
        end
      end

      describe ".with_marloss_locker" do
        it "should execute block with lock" do
          expect(marloss_locker).to receive(:wait_until_lock_obtained)
          expect(marloss_locker).to receive(:release_lock)

          class_instance.with_marloss_locker(lock_name) do |locker|
            expect(locker).to eq(marloss_locker)
          end
        end

        it "should not release lock if it was not obtained" do
          expect(marloss_locker).to receive(:wait_until_lock_obtained).and_raise Marloss::LockNotObtainedError
          expect(marloss_locker).not_to receive(:release_lock)

          expect do
            class_instance.with_marloss_locker(lock_name)
          end.to raise_error(Marloss::LockNotObtainedError)
        end
      end
    end
  end
end
