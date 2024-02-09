# StudyLine

## サービス概要
**StudyLine**は、ローカル環境のターミナルから学習記録をつけられるサービスです。簡易な学習記録を1日の学習終了後にすぐ記録でき、ブラウザ上ではグラフなどでわかりやすく可視化して表示します。Twitterへの投稿も、学習記録をつける際に同時に行える機能があります。

## サービスコンセプト
ユーザーにプログラミング学習をしている際に手軽に学習の記録をつけられるように設計しました。私がプログラミング学習を始めた当初、最初の2、3ヶ月は学習記録をつけていましたが、その後は面倒くささから記録をつけるのをやめてしまいました。そこで、1日の学習を終えた直後にそのままターミナルやエディタでGitのようにCLI操作で学習記録をつけられたら楽だと思い、このWebアプリを考案しました。

### CLI学習記録機能
- `start`, `finish` コマンドを使用して、学習時間の記録と計測を行う。

[![Image from Gyazo](https://i.gyazo.com/a9a12e0fad5f37858992795b158648a7.png)](https://gyazo.com/a9a12e0fad5f37858992795b158648a7)

- タグを作成して学習時時間の計測を行う。

[![Image from Gyazo](https://i.gyazo.com/c53dca943a4c1d475a5252762d35374c.png)](https://gyazo.com/c53dca943a4c1d475a5252762d35374c)

### 学習記録の編集・削除機能
- 学習記録の後からの編集や削除が可能です。

[![Image from Gyazo](https://i.gyazo.com/7eb6da2d28aff5eea147a351f0a0e43c.png)](https://gyazo.com/7eb6da2d28aff5eea147a351f0a0e43c)

### 勉強時間のグラフ表示
- 学習時間をchart.jsを使用してグラフで可視化します。

[![Image from Gyazo](https://i.gyazo.com/51ec9cbcac409ef9a8f9deb006e1b89c.png)](https://gyazo.com/51ec9cbcac409ef9a8f9deb006e1b89c)


### 検索機能
- タグによる検索機能と合計勉強時間の表示機能があります。

[![Image from Gyazo](https://i.gyazo.com/f585f73e8eff7378b2056fb7ae51f9d2.png)](https://gyazo.com/f585f73e8eff7378b2056fb7ae51f9d2)

## 使用技術

- **Rails** 7.0.8
- **JavaScript**
- **Heroku**
