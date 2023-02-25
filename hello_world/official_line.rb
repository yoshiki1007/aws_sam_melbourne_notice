require 'json'
require 'uri'
require 'net/https'

class OfficialLine
  class << self
    def send_weather(weather_text)
      _send(text: weather_text, index: 23, product_id: "5ac21184040ab15980c9b43a", emoji_id: "024")
    end

    def send_yesterday_posts(crawler_text)
      _send(text: crawler_text, index: 23, product_id: "5ac21184040ab15980c9b43a", emoji_id: "102")
    end

    private

    def _send(text:, index:, product_id:, emoji_id:)
      uri = URI.parse('https://api.line.me/v2/bot/message/broadcast')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Post.new(uri.request_uri)
      req['Content-type'] = ENV['CONTENT_TYPE']
      req["Authorization"] = ENV['LINE_CHANNEL_ACCESS_TOKEN']

      body = {
        "messages": [
          {
            "type" => "text",
            "text" => text,
            "emojis" => [
              {
                "index": index,
                "productId": product_id,
                "emojiId": emoji_id
              }
            ]
          }
        ]
      }.to_json
      req.body = body

      begin
        res = http.request(req)
        res.body
      rescue => e
        pp e.message
      end
    end
  end
end
