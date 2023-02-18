require 'open-uri'
require "nokogiri"
require "robotex"

URLS = {
  nichigo_press: {
    site_name: "NICHIGO PRESS",
    url: "https://nichigopress.jp/classified/accommo/?jsf=jet-engine:items&tax=classified-states:1659;classified-city:1673",
    target_element: ".elementor-element.elementor-widget.elementor-widget-jet-listing-grid .jet-listing-grid__items > .jet-listing-grid__item .jet-listing-dynamic-field__content:contains('作成日')",
  },
  dengon_net: {
    site_name: "DENGON NET",
    url: "https://www.dengonnet.net/melbourne/classifieds/sharehouse/224%2C76",
    target_element: ".view-content > .views-row .cls_date",
  },
  gogo_melbourne: {
    site_name: "GO豪メルボルン",
    url: "https://www.gogomelbourne.com.au/classifieds/accom",
    target_element: ".cl-12.row .clsfdlst.row.clearfix .col-xs-8.col-sm-8.col-md-9.col-lg-9 p:contains('更新日付')",
  },
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

        # 昨日の投稿数を取得
        yesterday_post_counts = created_dates.select do |created_date|
          if value[:site_name] == URLS[:nichigo_press][:site_name] || value[:site_name] == URLS[:gogo_melbourne][:site_name]
            Date.parse(created_date.child) == Date.today - 1
          elsif value[:site_name] == URLS[:dengon_net][:site_name]
            Date.strptime(created_date.child, "%m月%d日") == Date.today - 1
          end
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
