require_relative 'weather'
require_relative 'crawler'
require_relative 'official_line'

def lambda_handler(event:, context:)
  # 天気 City
  weather = Weather.city_new
  weather_body = weather.get_weather
  weather_text = weather.get_text(weather_body)
  OfficialLine.send_weather(weather_text)

  # レント クローラー
  all_yesterday_posts = Crawler.get_yesterday_posts
  OfficialLine.send_yesterday_posts(all_yesterday_posts)
end
