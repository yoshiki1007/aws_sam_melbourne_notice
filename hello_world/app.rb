require_relative 'weather'
require_relative 'crawler'
require_relative 'official_line'

def lambda_handler(event:, context:)
  # 天気 City
  lat = "-37.8165137"
  lon = "144.9497845"
  units = "metric"
  lang = "ja"
  exclude = "minutely"

  weather = Weather.new(lat: lat, lon: lon, units: units, lang: lang, exclude: exclude)
  weather_body = weather.get_weather
  weather_text = weather.get_text(weather_body)

  OfficialLine.send_weather(weather_text)

  # レント クローラー
  all_yesterday_posts = Crawler.get_yesterday_posts

  OfficialLine.send_yesterday_posts(all_yesterday_posts)
end
