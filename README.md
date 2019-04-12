## Name
datamix_PBL_telMarketing<br>

## Overview
データミックスのPBL、「銀行テレマーケティング」のプログラムです。<br>
このリポジトリには下記2つが含まれています。<br>
・ロジスティック回帰を使って銀行テレマーケティングが成功するor失敗するを判断します。<br>
・k-means法を使って、2つのデータをペルソナに分ける。<br>

## Description
・ロジスティック回帰を使ってテレマーケティングが成功するor失敗するを判断する<br>
　このプログラムには説明変数として、下記リンクにあるデータを入力します。<br>
　 https://archive.ics.uci.edu/ml/datasets/bank+marketing<br>
　このプログラムを実行すると、その説明変数から下記新規の説明変数を作ります。<br>
　・数値型の説明変数を標準化したもの<br>
　・durationが30秒未満かどうかを表したもの<br>
　・CPI,CCI,就職率を使って不況率を表したもの<br>
　そしてその説明変数を使ってyを予測し、正解データと比較します。<br>
・k-measn法を使って2つのデータのペルソナに分ける<br>
　今回は2つのデータをペルソナに分けた。<br>
　・durationが30秒未満。durationが30秒未満の場合、<br>
　　電話をとってすぐに切った人だと推測される。（学習データではこの条件を満たす人はテレマーケティングに失敗している）<br>
　　これをすることでより、電話をすぐに切った人のペルソナがわかる<br>
　・durationが30秒以上で、テレマーケティングに失敗した人<br>
　　durationが30秒以上なので、電話で話をしたが失敗した人となる。<br>
　　これを分類することで、失敗しやすい人をカテゴリー化でき対策を立てやすくなると思われる。<br>

## Requirement
・ロジスティック回帰を使ってテレマーケティングに成功するor失敗するを判断する<br>
　・プログラミング言語：R<br>
　・（R studio）<br>
・k-means法を使って2つのデータのペルソナに分ける<br>
　・jupyter notebook<br>

## Usage
・ロジスティック回帰を使ってテレマーケティングに成功するor失敗するを判断する<br>
　・R studioを起動し、「R/bank_marketing_sjis.R」を起動する<br>
　　（文字化けする場合、文字コードをsjisに変換する）<br>
　・Settonを「R」のディレクトリに設定する<br>
　・「bank_marketing_sjis.R」の全文を実行する<br>
・k-means法を使って2つのデータのペルソナに分ける<br>
　・jupyter notebookを起動し、「python/Untitled.pynb」を開く<br>
　・全文実行する<br>

## Author
Eiichi Takahashi<br>
