require "spec_helper"

module Marloss
  describe Locker do

    let(:store) { instance_double(Store) }
    let(:name) { "my_resource" }
    let(:locker) { described_class.new(store, name) }

    describe ".obtain_lock" do
      it "should succeed" do
        expect(store).to receive(:create_lock).with(name)

        locker.obtain_lock
      end

      it "should raise error" do
        allow(store).to receive(:create_lock).with(name)
          .and_raise(LockNotObtainedError)

        expect { locker.obtain_lock }.to raise_error(LockNotObtainedError)
      end
    end

    describe ".refresh_lock" do
      it "should succeed" do
        expect(store).to receive(:refresh_lock).with(name)

        locker.refresh_lock
      end
    end

    describe ".release_lock" do
      it "should succeed" do
        expect(store).to receive(:delete_lock).with(name)

        locker.release_lock
      end
    end

    describe ".wait_until_lock_obtained" do
      it "should get the lock the first time" do
        expect(store).to receive(:create_lock).with(name)

        locker.wait_until_lock_obtained
      end

      it "should fail to get the lock and retry" do
        sleep_seconds = 3
        attempt = 0
        max_attempts = 3

        allow(store).to receive(:create_lock).with(name) do
          attempt += 1
          raise(LockNotObtainedError) unless attempt == max_attempts
        end
        allow(locker).to receive(:sleep).with(sleep_seconds)
          .and_return(sleep_seconds)

        expect(store).to receive(:create_lock).with(name)
          .exactly(max_attempts).times

        locker.wait_until_lock_obtained(sleep_seconds: sleep_seconds)
      end

      it "should take a configurable number of retries then fail" do

        allow(store).to receive(:create_lock).with(name)
          .exactly(5).times.and_raise(LockNotObtainedError)

        allow(locker).to receive(:sleep).with(3)
        expect {
          locker.wait_until_lock_obtained(retries: 5)
        }.to raise_error
      end
    end

  end
end
