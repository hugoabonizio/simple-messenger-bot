require 'sinatra'
require 'json'
require 'net/http'
require 'open-uri'
require 'dotenv'
Dotenv.load

set :bind, '0.0.0.0'
set :port, 8080

TOKEN = ENV['TOKEN']

get '/' do
  return params['hub.challenge'] if params['hub.verify_token'] == 'teste_token'
  "Hi!"
end

post '/' do
  request.body.rewind
  body = JSON.parse request.body.read
  puts "body: #{body}"

  entries = body['entry']
  entries.each do |entry|
    entry['messaging'].each do |message|
      if message['message'] && message['message']['text']
        text = message['message']['text']
        sender = message['sender']['id']
        # puts 'message', message
        puts "received: #{text}"
        send_message(sender, "echo: #{text}")
      end
    end
  end
  puts "=" * 20
  puts
end

def send_message(id, text)
  uri = URI("https://graph.facebook.com/v2.6/me/messages?access_token=#{TOKEN}")
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = {
    recipient: { id: id },
    message: { text: text }
  }.to_json
  Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end
end