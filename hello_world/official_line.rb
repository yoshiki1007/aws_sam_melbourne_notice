require 'json'
require 'uri'
require 'net/https'

class OfficialLine
  class << self
    def line_send(all_yesterday_posts)
      return if all_yesterday_posts.empty? # 全てのサイトで投稿がなければ return

      uri = URI.parse('https://api.line.me/v2/bot/message/broadcast')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Post.new(uri.request_uri)
      req['Content-type'] = ENV['CONTENT_TYPE']
      req["Authorization"] = ENV['LINE_CHANNEL_ACCESS_TOKEN']

      result = make_text(all_yesterday_posts)

      body = {
        "messages": [
          {
            "type" => "text",
            "text" => result,
            "emojis" => [
              {
                "index": 23,
                "productId": "5ac21184040ab15980c9b43a",
                "emojiId": "102"
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

    private

    def make_text(all_yesterday_posts)
      title = "Melbourne Rent Crawler $\n"
      sub_title = "昨日投稿されたレント情報\n\n"

      body = all_yesterday_posts.each_with_index.map do |yesterday_post, index|
        site_name = "サイト名: " + yesterday_post[:site_name] + "\n"
        post_count = "投稿数: " + yesterday_post[:count].to_s + "件\n"
        url = "URL: " + yesterday_post[:url] + "\n\n"

        site_name + post_count + url
      end.join # 配列を結合して文字列へ変更

      inner_title = "おそらく常に掲載があるサイト\n\n"

      inner_body = NOT_CRAWLING_URLS.map do |not_crawling_url|
        inner_site_name = "サイト名: " + not_crawling_url[:site_name] + "\n"
        inner_body = "URL: " + not_crawling_url[:url] + "\n\n"

        inner_site_name + inner_body
      end.join

      title + sub_title + body + inner_title + inner_body
    end
  end
end
