# Melbourne Notice - 公式ライン

URL: https://lin.ee/DmK81lc

![line_oa_chat_230122_234024_group_0](https://user-images.githubusercontent.com/56143537/213916367-f27f5753-b03e-4ed8-84ea-242aa19e1e41.png)

## 概要

毎朝8時（日本時間10時）に

- 今日のメルボルン City の天気
- 昨日投稿された Rent 情報

が公式ラインから送信されます。

**使用サービス**

- Open Weather API
- LINE Messaging API
- AWS SAM, Lambda, CloudWatch Events
- Nokogiri, Robotex

### 天気情報

OpenWeather の One Call API 3.0を使用して天気情報を取得し、Lambda で公式ラインを送信

### Rent 情報

Robotex でクローラーを許可しているか判別

Nokogiri でクローリング、スクレイピングし、昨日投稿されたものがあれば Lambda で公式ラインを送信

**監視対象**

- NICHIGO PRESS
- DENGON NET
- GO豪メルボルン

**追加枠**

- Gumtree
- Flatmates

## DEVELOPMENT USAGE

```zsh
sam build --use-container 
```

```zsh
sam local invoke HelloWorldFunction --event events/event.json
```

**first**

```zsh
sam deploy --guided
```

**since next**

```zsh
sam deploy
```

**all in one**

```zsh
sam build --use-container && sam deploy 
```