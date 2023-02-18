require 'json'
require 'uri'
require 'net/https'

NOT_CRAWLING_URLS = {
  gumtree: {
    site_name: "Gumtree",
    url: "https://www.gumtree.com.au/s-flatshare-houseshare/melbourne/c18294l3001317",
  },
  flatmates: {
    site_name: "Flatmates",
    url: "https://flatmates.com.au/",
  },
}

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
      alert = "※注意喚起※\nレント詐欺について: https://nichigopress.jp/notice-item/51181/\n\n"
      sub_title = "◆ 昨日投稿されたレント情報\n\n"

      body = all_yesterday_posts.each_with_index.map do |yesterday_post, index|
        site_name = "サイト名: " + yesterday_post[:site_name] + "\n"
        post_count = "投稿数: " + yesterday_post[:count].to_s + "件\n"
        url = "URL: " + yesterday_post[:url] + "\n\n"

        site_name + post_count + url
      end.join # 配列を結合して文字列へ変更

      inner_title = "◆ 常に掲載があるサイト\n\n"

      inner_body = NOT_CRAWLING_URLS.each_with_index.map do |(key, value), index|
        inner_site_name = "サイト名: " + value[:site_name] + "\n"
        inner_body = if NOT_CRAWLING_URLS.count - 1 == index
                       "URL: " + value[:url] + "\n"
                     else
                       "URL: " + value[:url] + "\n\n"
                     end

        inner_site_name + inner_body
      end.join

      title + alert + sub_title + body + inner_title + inner_body
    end
  end
end
