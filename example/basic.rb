require "bundler/setup"
require "jebanni"

=begin
$ bundle exec ruby ./example/basic.rb
I, [2014-06-22T17:56:32.467348 #27470]  INFO -- : Listen on 0.0.0.0:63123


at other console
$ curl -vNH 'Accept: text/event-stream' -H 'Last-Event-ID: 1' -H 'Cache-Control: no-cache' 'http://127.0.0.1:63123/foo'
* Hostname was NOT found in DNS cache
*   Trying 127.0.0.1...
* Connected to 127.0.0.1 (127.0.0.1) port 63123 (#0)
> GET /foo HTTP/1.1
> User-Agent: curl/7.37.0
> Host: 127.0.0.1:63123
> Accept: text/event-stream
> Last-Event-ID: 1
> Cache-Control: no-cache
>
< HTTP/1.1 200 OK
< Content-Type: text/event-stream; charset=utf-8
< Cache-Control: no-cache
< X-Accel-Buffering: no
< Access-Control-Allow-Origin: *
< Transfer-Encoding: identity
* no chunk, no close, no size. Assume close to signal end
<
retry: 5000
id

id: 1
data: "2014-06-22 17:56:40 +0900"

id: 2
data: "2014-06-22 17:56:41 +0900"

id: 3
data: "2014-06-22 17:56:42 +0900"

: ping
id: 4
data: "2014-06-22 17:56:43 +0900"

id: 5
data: "2014-06-22 17:56:44 +0900"

id: 6
data: "2014-06-22 17:56:45 +0900"

^C


=end

class App < Jebanni::Base
  set :interval, 1
  set :port, 63123

  get "/:channel_id" do
    on_first_connect do
      every(1) do
        broadcast(Time.now)
      end
    end
  end
end

App.run
