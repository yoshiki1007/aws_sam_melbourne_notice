require 'open-uri'
require "nokogiri"
require "robotex"

URLS = {
  nichigo_press: {
    site_name: "NICHIGO PRESS",
    url: 'https://nichigopress.jp/classified/accommo/?jsf=jet-engine:items&tax=classified-states:1659;classified-city:1673',
    target_element: ".elementor-element.elementor-widget.elementor-widget-jet-listing-grid .jet-listing-grid__items > .jet-listing-grid__item .jet-listing-dynamic-field__content:contains('作成日')"
  }
}

class Crawler
  class << self
    def get_yesterday_posts
      robotex = Robotex.new

      URLS.map do |key, value|
        next unless robotex.allowed?(value[:url]) # クローラーを許可していなければ next
        robotex.delay!(value[:url]) # クローラー待機時間が設定されていれば delay

        html = URI.open(value[:url]).read
        doc = Nokogiri::HTML.parse(html)

        created_dates = doc.css(value[:target_element])

        yesterday_post_counts = created_dates.select do |created_date|
          # Date.parse(created_date.child) == Date.today - 1 # 昨日の投稿なら true
          Date.parse(created_date.child) == Date.today # テスト
        end.count

        next if yesterday_post_counts == 0 # 投稿が0件なら next

        {
          site_name: value[:site_name],
          url: value[:url],
          count: yesterday_post_counts
        }

      end.compact # nilを削除
    end
  end
end
