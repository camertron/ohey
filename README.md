[![Build Status](https://travis-ci.com/camertron/ohey.svg?branch=master)](https://travis-ci.com/camertron/ohey)

## ohey
A rewrite of the platform detection logic in ohai, but with fewer dependencies and 100% less metaprogramming.

## Installation

Install ohey by running `gem install ohey` or by adding it to your Gemfile:

```ruby
gem 'ohey', '~> 1.0'
```

## Usage

### Detecting the current platform:

```ruby
platform = Ohey.current_platform

platform.name     # => "mac_os_x"
platform.family   # => "mac_os_x
platform.build    # => "19H1030"
platform.version  # => "10.15.7"
```

### Registering a new platform:

```ruby
Ohey.register_platform(:name, PlatformClass.new)
```

The second argument must respond to the `name`, `family`, `build`, and `version` methods.

### Listing Registered Plaforms

```ruby
Ohey.registered_platforms  # => {:darwin=>#<Ohey::Darwin:0x00007ff9d51f1ef0>, ...}
```

## License

Licensed under the MIT license. See LICENSE for details.

## Authors

* The numerous authors who contributed to https://github.com/chef/ohai.
* Adapted by Cameron C. Dutro: https://github.com/camertron
