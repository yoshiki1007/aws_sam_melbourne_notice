require 'open-uri'
require "nokogiri"
require "robotex"

class Crawler
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

        next if yesterday_post_counts == 0 # 投稿が0件なら next

        {
          site_name: website.display_name,
          url: website.url,
          count: yesterday_post_counts
        }

      end.compact # nilを削除
    end
  end
end
