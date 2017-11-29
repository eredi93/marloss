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
    end

    describe ".with_refreshed_lock" do
      let(:ttl) { 1 }
      let(:sleep_seconds) { ttl / 3.0 }

      it "should refresh the lock once" do
        allow(locker).to receive(:loop).and_yield
        allow(store).to receive(:ttl).and_return(ttl)

        expect(store).to receive(:refresh_lock).with(name)
        expect(locker).to receive(:sleep).with(sleep_seconds)

        # sleep 0.1 to allow Thread to call refresh_lock
        locker.with_refreshed_lock { sleep(0.1) }
      end

      it "should refresh the lock three times" do
        allow(locker).to receive(:loop).and_yield.and_yield.and_yield
        allow(store).to receive(:ttl).and_return(ttl)

        expect(store).to receive(:refresh_lock).with(name).exactly(3).times
        expect(locker).to receive(:sleep).with(sleep_seconds).exactly(3).times

        # sleep 0.1 to allow Thread to call refresh_lock
        locker.with_refreshed_lock { sleep(0.1) }
      end
    end

  end
end
