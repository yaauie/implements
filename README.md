# Implements

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'implements'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install implements

## Usage

`Implements` was created as a dependency of my [`redis-copy`][] gem, which
provides multiple implementations of each of multiple interfaces in order to
provide support for new features in redis, while falling back gracefully
(sometimes multiple steps) to less-optimal implementations when
the underlying support is not present.

[redis-copy]: https://github.com/yaauie/redis-copy

The goal of this library in particular is to provide an implementation
registry that is attached to the interface, and can be used to provide
the best-possible implementation for a given scenario. It also allows
third-party libraries to provide their own implementations of an interface
without having to touch the library that contains their upstream interface.

Below you will find a simplified example:

``` ruby
require 'implements/global'

module RedisCopy
  module KeyEmitter
    extend Implements::Interface

    # @param redis_connection [Object]
    # @return [void]
    def intialize(redis_connection)
      @redis = redis_connection
    end

    # @param keys [String] - ('*') a glob-ish pattern
    # @return [Enumerable<String>]
    def keys(pattern = '*')
      raise NotImplementedError
    end

    # ...

    class Default
      implements KeyEmitter

      def keys(pattern = '*')
        @redis.keys(pattern)
      end
    end

    class Scanner
      # note how a block is given to `implements`.
      # this block is called with the class' initialize arguments
      # to determine whether or not this implementation is compatible
      # with the input and its state before initializing the object.
      implements KeyEmitter do |redis_connection|
        bin_version = Gem::Version.new(redis_connection.info['redis_version'])
        bin_requirement = Gem::Requirement.new('>= 2.7.105')

        break false unless bin_requirement.satisfied_by?(bin_version)

        redis_connection.respond_to?(:scan_each)
      end

      def keys(pattern = '*')
        @redis.scan_each(match: pattern, count: 1000)
      end
    end
  end
end
```

The consumer of this interface, then, can get the best available implementation,
given their environment and the object(s) passed to `#initialize`, without
having to know anything about the implementations themselves:

``` ruby
source_redis = Redis.new(port: 9736) # a scanner-compatible redis process
key_emitter = RedisCopy::KeyEmitter.implementation.new(source_redis)
# => <RedisCopy::KeyEmitter::Scanner: ... >
key_emitter.keys('schedule:*').to_enum
# => <Enumerator ...>

source_redis = Redis.new(port: 9737) # a scanner-incompatible redis process
key_emitter = RedisCopy::KeyEmitter.implementation.new(source_redis)
# => <RedisCopy::KeyEmitter::Default: ... >
key_emitter.keys('schedule:*').to_enum
# => <Enumerator ...>
```

The consumer can choose to favor a particular implementation by name:

``` ruby
key_emitter = RedisCopy::KeyEmitter.implementation(:scanner).new(source_redis)
# => <RedisCopy::KeyEmitter::Scanner: ... >
```

And if a compatible implementation cannot be found, an appropriate exception
is raised:

``` ruby
key_emitter = RedisCopy::KeyEmitter.implementation(:scanner).new(source_redis)
# Implements::implementation::NotFound: no compatible implementation for RedisCopy::KeyEmitter>
```

The implementation finder assumes that implementations loaded later are
somehow better than those loaded before them, but a consumer can specify
first preference and fallback groups:

``` ruby
key_emitter = RedisCopy::KeyEmitter.implementation(:scanner, :auto).new(source_redis)
# => <RedisCopy::KeyEmitter::Default: ... >
```

And implementations can be added which are not in the auto load order and have
to be explicitly asked for:

``` ruby
class RedisCopy::KeyEmitter::WhackAMole
  Implements RedisCopy::KeyEmitter, as: 'shuffle', auto: false

  def keys(pattern = '*')
    return enum_for(__method__, pattern) unless block_given?
    while(key = redis.randomkey)
      yield key if glob_match?(pattern, key)
    end
  end

  # ...
end
```

``` ruby
key_emitter = RedisCopy::KeyEmitter.implementation(:whack_a_mole).new(source_redis)
# => <RedisCopy::KeyEmitter::WhackAMole: ... >
# But it doesn't come back unless you ask for it.
key_emitter = RedisCopy::KeyEmitter.implementation.new(source_redis)
# => <RedisCopy::KeyEmitter::Scanner: ... >
```

# TODO:

 - Provide tools for testing *all* implementations of an interface.
 - Finalize syntax for the check. A block alone is convenient, but not clear.
 - Finalize scope of check. Allocate and instance_exec? Run all as hooks before `#initialize`?

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
