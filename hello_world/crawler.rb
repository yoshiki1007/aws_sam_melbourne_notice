require 'open-uri'
require "nokogiri"
require "robotex"

class Crawler
  ALERT_URL = "https://nichigopress.jp/notice-item/51181/"

  class << self
    def get_yesterday_posts(websites)
      robotex = Robotex.new

      websites.map do |website|
        next unless website.crawling? # クローラーの対象でなければ next
        next unless robotex.allowed?(website.url) # クローラーを許可していなければ next
        robotex.delay!(website.url) # クローラー待機時間が設定されていれば delay

        html = URI.open(website.url).read
        doc = Nokogiri::HTML.parse(html)

        created_dates = doc.css(website.target_element)

        # 昨日の投稿数を取得
        yesterday_post_counts = created_dates.select do |created_date|
          if website.nichigo_press? || website.gogo_melbourne?
            Date.parse(created_date.child) == Date.today - 1
          elsif website.dengon_net?
            Date.strptime(created_date.child, "%m月%d日") == Date.today - 1
          end
        end.count

        {
          site_name: website.display_name,
          url: website.url,
          count: yesterday_post_counts
        }

      end.compact # nilを削除
    end

    def make_text(websites, all_yesterday_posts)
      body = all_yesterday_posts.map do |yesterday_post|
        <<~"EOS"
          サイト名: #{yesterday_post[:site_name]}
          投稿数: #{yesterday_post[:count].to_s}件
          URL: #{yesterday_post[:url]}\n
        EOS
      end.join # 配列を結合して文字列へ変更

      not_crawling_websites = websites.reject { |w| w.crawling? }
      inner_body = not_crawling_websites.each_with_index.map do |not_crawling_website, i|
        <<~"EOS"
          サイト名: #{not_crawling_website.display_name}
          URL: #{not_crawling_website.url}#{"\n" if not_crawling_websites.count - 1 == i}
        EOS
      end.join

      <<~"EOS"
        Melbourne Rent Crawler $
        レント詐欺について: #{ALERT_URL}
        ◆ 昨日投稿されたレント情報

        #{body}
        ◆ 常に掲載があるサイト

        #{inner_body}
      EOS
    end
  end
end
