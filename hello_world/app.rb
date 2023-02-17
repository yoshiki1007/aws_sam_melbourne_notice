require_relative 'crawler'
require_relative 'official_line'

def lambda_handler(event:, context:)
  # クローラー
  all_yesterday_posts = Crawler.get_yesterday_posts
  # 公式LINE
  OfficialLine.line_send(all_yesterday_posts)
end
