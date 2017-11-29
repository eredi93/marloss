# frozen_string_literal: true
#
module Marloss
  class Locker

    attr_reader :store, :name

    def initialize(store, name)
      @store = store
      @name = name
    end

    def obtain_lock
      store.create_lock(name)
    end

    def refresh_lock
      store.refresh_lock(name)
    end

    def release_lock
      store.delete_lock(name)
    end

    def wait_until_lock_obtained(sleep_seconds: 3)
      store.create_lock(name)
    rescue LockNotObtainedError
      sleep(sleep_seconds)
      retry
    end

    def with_refreshed_lock
      thr = Thread.new do
        loop do
          begin
            store.refresh_lock(name)
          rescue Exception => e
            Thread.main.raise(e)
          end

          sleep(store.ttl / 3.0)
        end
      end

      yield

    ensure
      thr.kill
    end

  end
end
