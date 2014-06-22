require "bundler/setup"
require "jebanni"

=begin
$ bundle exec ruby ./example/broadcast_by_post.rb
I, [2014-06-22T18:01:24.997142 #28625]  INFO -- : Listen on 0.0.0.0:63311

at console A:
A $ curl -vNH 'Accept: text/event-stream' -H 'Last-Event-ID: 1' -H 'Cache-Control: no-cache' 'http://127.0.0.1:63311/foo'
: ping
: ping

at console B:
B $ curl -d 'number=42' 'http://localhost:63311/foo'
B $ curl -d '{"json": "capable"}' -H 'Content-Type: application/json' 'http://localhost:63311/foo'
B $ curl -XPOST 'http://localhost:63311/foo/now'

at A:
: ping
: ping

id: 1
data: {"number":"42","channel_id":"foo"}

id: 2
data: {"json":"capable","channel_id":"foo"}

id: 3
data: "2014-06-22 18:04:38 +0900"


=end

class App < Jebanni::Base
  get "/:channel_id" do
  end

  post "/:channel_id" do
    broadcast(params)
    finish! # finish! means this connection doesn't require streaming. normal HTTP request/response operation
  end

  post "/:channel_id/now" do
    broadcast(Time.now)
    finish!
  end
end

App.run
