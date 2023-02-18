WEBSITES = {
  nichigo_press: {
    name: "NICHIGO PRESS",
    crawling: true,
    url: "https://nichigopress.jp/classified/accommo/?jsf=jet-engine:items&tax=classified-states:1659;classified-city:1673",
    target_element: ".elementor-element.elementor-widget.elementor-widget-jet-listing-grid .jet-listing-grid__items > .jet-listing-grid__item .jet-listing-dynamic-field__content:contains('作成日')",
  },
  dengon_net: {
    name: "DENGON NET",
    crawling: true,
    url: "https://www.dengonnet.net/melbourne/classifieds/sharehouse/224%2C76",
    target_element: ".view-content > .views-row .cls_date",
  },
  gogo_melbourne: {
    name: "GO豪メルボルン",
    crawling: true,
    url: "https://www.gogomelbourne.com.au/classifieds/accom",
    target_element: ".cl-12.row .clsfdlst.row.clearfix .col-xs-8.col-sm-8.col-md-9.col-lg-9 p:contains('更新日付')",
  },
  gumtree: {
    name: "Gumtree",
    crawling: false,
    url: "https://www.gumtree.com.au/s-flatshare-houseshare/melbourne/c18294l3001317",
  },
  flatmates: {
    name: "Flatmates",
    crawling: false,
    url: "https://flatmates.com.au/",
  },
}

class Website
  attr_accessor :name, :display_name, :crawling, :url, :target_element

  def initialize(name:, display_name:, crawling:, url:, target_element:)
    @name = name
    @display_name = display_name
    @crawling = crawling
    @url = url
    @target_element = target_element
  end

  class << self
    def all_new
      WEBSITES.map do |k, v|
        Website.new(name: k, display_name: v[:name], crawling: v[:crawling], url: v[:url], target_element: v[:target_element])
      end
    end
  end

  def crawling?
    crawling
  end

  def nichigo_press?
    display_name == WEBSITES[:nichigo_press][:name]
  end

  def gogo_melbourne?
    display_name == WEBSITES[:gogo_melbourne][:name]
  end

  def dengon_net?
    display_name == WEBSITES[:dengon_net][:name]
  end
end
