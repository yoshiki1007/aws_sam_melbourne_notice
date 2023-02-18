require 'json'
require 'uri'
require 'net/https'

require_relative 'website'

class OfficialLine
  class << self
    def send_yesterday_posts(all_yesterday_posts)
      return if all_yesterday_posts.empty? # 全てのサイトで投稿がなければ return

      uri = URI.parse('https://api.line.me/v2/bot/message/broadcast')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Post.new(uri.request_uri)
      req['Content-type'] = ENV['CONTENT_TYPE']
      req["Authorization"] = ENV['LINE_CHANNEL_ACCESS_TOKEN']

      text = make_text(all_yesterday_posts)

      body = {
        "messages": [
          {
            "type" => "text",
            "text" => text,
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
      alert = "※注意喚起※ \nレント詐欺について: https://nichigopress.jp/notice-item/51181/\n\n"
      sub_title = "◆ 昨日投稿されたレント情報\n\n"

      body = all_yesterday_posts.map do |yesterday_post|
        site_name = "サイト名: " + yesterday_post[:site_name] + "\n"
        post_count = "投稿数: " + yesterday_post[:count].to_s + "件\n"
        url = "URL: " + yesterday_post[:url] + "\n\n"

        site_name + post_count + url
      end.join # 配列を結合して文字列へ変更

      inner_title = "◆ 常に掲載があるサイト\n\n"

      not_crawling_websites = Website.all_new.reject { |w| w.crawling? }
      inner_body = not_crawling_websites.each_with_index.map do |not_crawling_website, index|
        inner_site_name = "サイト名: " + not_crawling_website.display_name + "\n"

        inner_body = if not_crawling_websites.count - 1 == index
                       "URL: " + not_crawling_website.url + "\n"
                     else
                       "URL: " + not_crawling_website.url + "\n\n"
                     end

        inner_site_name + inner_body
      end.join

      title + alert + sub_title + body + inner_title + inner_body
    end
  end
end
