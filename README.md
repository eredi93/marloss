## Marloss

[![Build Status](https://travis-ci.org/eredi93/marloss.svg?branch=master)](https://travis-ci.org/eredi93/marloss)
[![Gem Version](https://badge.fury.io/rb/marloss.svg)](http://badge.fury.io/rb/marloss)

Marloss is a general DynamoDB-based lock implementation.

![rusty-lock](https://user-images.githubusercontent.com/10990391/33243215-aa602a6c-d2d9-11e7-8fc6-d4a0c2a5b30d.jpg)

### Installation

Add this line to your application's Gemfile:

```ruby
gem "marloss"
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install marloss
```

### Usage

Marloss can be use as module, with some useful heplers, or plain for more specific use cases

#### Module

Include the module to your class and set the options

```ruby
class MyClass

  include Marloss

  marloss_options table: "my_table", hash_key: "ID"

end
```

now you can simply wrap the code that needs to be locked

```ruby
with_marloss_locker("my_lock") do |locker|
  # execute code
  # ...
  # refresh lock if needed
  locker.refresh
end
```

#### Plain

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

# delete the lock
locker.release_lock
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
