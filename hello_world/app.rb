require_relative 'weather'
require_relative 'website'
require_relative 'crawler'
require_relative 'official_line'

def lambda_handler(event:, context:)
  # 天気 City
  weather = Weather.city_new
  weather_body = weather.get_weather
  weather_text = weather.make_text(weather_body)
  OfficialLine.send_weather(weather_text)

  # レント クローラー
  websites = Website.all_new
  all_yesterday_posts = Crawler.get_yesterday_posts(websites)
  OfficialLine.send_yesterday_posts(all_yesterday_posts)
end
