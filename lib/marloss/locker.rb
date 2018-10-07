# frozen_string_literal: true

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

    def wait_until_lock_obtained(sleep_seconds: 3, retries: nil)
      store.create_lock(name)
    rescue LockNotObtainedError
      sleep(sleep_seconds)

      unless retries.nil?
        retries -= 1
        raise if retries.zero?
      end

      retry
    end
  end
end
