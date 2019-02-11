## 0.5.0 11/02/2019

IMPROVEMENTS:

* Add the option to specify a `custom_process_id` [#15](https://github.com/eredi93/marloss/pull/15)

## 0.4.0 01/09/2018

IMPROVEMENTS:

* Custom ttl attribute name instead of hardcoding `Expires` [#12](https://github.com/eredi93/marloss/pull/12)
* Add possiblity to pass retries to `wait_until_lock_obtained` preventing spin lock [#11](https://github.com/eredi93/marloss/pull/11)

## 0.3.1 01/09/2018

IMPROVEMENTS:

* Make `create_table` wait for table [#8](https://github.com/eredi93/marloss/pull/8)

## 0.3.0 29/11/2017

IMPROVEMENTS:

* remove `with_refreshed_lock` as is not safe [#4](https://github.com/eredi93/marloss/pull/4)

## 0.2.1 29/11/2017

IMPROVEMENTS:

* Log when deleting the lock

## 0.2.0 29/11/2017

IMPROVEMENTS:

* Add the possibility to include `Marloss`. This adds some healpers that makes it really easy to use the lock in your class

BUG FIXES:

* Add the possibility of deleting the lock, it was documented but never implemented
