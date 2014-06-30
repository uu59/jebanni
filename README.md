# Jebanni

Jebanni is a Sinatra-style Server-Sent Event kit its based on [Reel](https://github.com/celluloid/reel).

## Installation

Add this line to your application's Gemfile:

    gem 'jebanni'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jebanni

## Usage

```ruby
class App < Jebanni::Base
  set :interval, 1
  set :port, 63123

  get "/:channel_id" do
    on_first_connect do
      every(settings[:interval]) do
        broadcast(Time.now)
      end
    end
  end
end

App.run
```

See [example](./example/) directory for more examples.

## Thanks

Jebanni is heavily inspired by [Angelo](https://github.com/kenichi/angelo).

If you looking for WebSocket stream server, try it!

## Contributing

1. Fork it ( https://github.com/[my-github-username]/jebanni/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
