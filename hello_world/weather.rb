require 'json'
require 'uri'
require 'net/https'

AREAS = {
  city: {
    lat: "-37.8165137",
    lon: "144.9497845",
    units: "metric",
    lang: "ja",
    exclude: "minutely"
  }
}

class Weather
  attr_accessor :lat, :lon, :units, :lang, :exclude

  def initialize(lat:, lon:, units:, lang:, exclude:)
    @lat = lat
    @lon = lon
    @units = units
    @lang = lang
    @exclude = exclude
  end

  class << self
    def city_new
      Weather.new(
        lat: AREAS[:city][:lat],
        lon: AREAS[:city][:lon],
        units: AREAS[:city][:units],
        lang: AREAS[:city][:lang],
        exclude: AREAS[:city][:exclude]
      )
    end
  end

  def get_weather
    api_key = ENV['WEATHER_API_KEY']
    uri = URI("https://api.openweathermap.org/data/3.0/onecall?lat=#{lat}&lon=#{lon}&units=#{units}&lang=#{lang}&exclude=#{exclude}&appid=#{api_key}")

    res = Net::HTTP.get_response(uri)
    JSON.parse(res.body)
  end

  def make_text(weather_body)
    <<~"EOS"
      Melbourne Weather City $
      
      ◆ #{Time.at(weather_body["current"]["dt"], in: "+11:00").strftime("%m/%d %A")} 天気
      #{weather_body["daily"][0]["weather"][0]["main"]}: #{weather_body["daily"][0]["weather"][0]["description"]}
      日の出: #{Time.at(weather_body["current"]["sunrise"], in: "+11:00").strftime("%H:%M")}
      日没: #{Time.at(weather_body["current"]["sunset"], in: "+11:00").strftime("%H:%M")}

      最高気温: #{weather_body["daily"][0]["temp"]["max"].floor.to_s}℃
      最低気温: #{weather_body["daily"][0]["temp"]["min"].floor.to_s}℃
      朝の気温: #{weather_body["daily"][0]["temp"]["morn"].floor.to_s}℃
      日中の気温: #{weather_body["daily"][0]["temp"]["day"].floor.to_s}℃
      夕方の気温: #{weather_body["daily"][0]["temp"]["eve"].floor.to_s}℃
      夜の気温: #{weather_body["daily"][0]["temp"]["night"].floor.to_s}℃
    EOS
  end
end
