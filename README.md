## Marloss

[![Build Status](https://travis-ci.org/eredi93/marloss.svg?branch=master)](https://travis-ci.org/eredi93/marloss)
[![Gem Version](https://badge.fury.io/rb/marloss.svg)](http://badge.fury.io/rb/marloss)

Marloss is a general DynamoDB-based locking implementation.

### Installation

```sh
gem install marloss
```

### Usage

Firstly, we need to initialize a lock store:

```ruby
store = Marloss::Store.new("lock_table_name", "LockHashKeyName")
```

We can use this store to create a single lock

```ruby
locker = Marloss::Locker.new(store, "my_resource")

# raise exception if we fail to get a lock
locker.obtain_lock

# or we can block until we get a lock
locker.wait_until_lock_obtained

# refresh the lock once
locker.refresh

# or execute block with lock being refreshed
locker.with_refreshed_lock do
  # execute long running code
end

# delete the lock
locker.delete_lock
```

### Testing

`rspec`

### Logging

By default Marloss logs to STDOUT, you can override it with the following command.

```ruby
Marloss.logger = Logger.new("my_app.log")
```

### What's in a name?

"Marlòss" means lock, in Trentino's dialect. I'm from [Volano](https://en.wikipedia.org/wiki/Volano), and I liked the idea of using a word from my hometown.

### Contributing

This repository is [open to contributions](.github/CONTRIBUTING.md).
