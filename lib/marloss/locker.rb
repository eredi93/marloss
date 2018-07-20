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

    def wait_until_lock_obtained(sleep_seconds: 3, retries: 3)
      store.create_lock(name)
    rescue LockNotObtainedError
      raise if retries.zero?

      retries -= 1
      sleep(sleep_seconds)
      retry
    end

  end
end
