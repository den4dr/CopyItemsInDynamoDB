#!/bin/bash

# 元テーブルに登録されているアイテム情報を、ファイルに出力する
get_items_data() {
  echo "get_items_data start from ${original_table_name}"
  aws dynamodb scan --table-name ${original_table_name} > ${original_items_file}
}

# 元テーブルのアイテム情報ファイルを元に、テスト用のテーブルにアイテムを登録する
put_items() {
	echo "put_items start"
  # 登録対象のアイテム数
  item_length=$(cat ${original_items_file} | jq ".Items | length")

  # アイテム数 > 0 の場合のみ、テスト用テーブルにアイテムを登録する
  # (アイテムが無いのに put-itemコマンド実行しようとするとエラーになるので)
  if [ ${item_length} -gt 0 ]; then
    for i in $( seq 0 $((${item_length} - 1)) ); do
      item=$(cat ${original_items_file} | jq ".Items[${i}]")
      aws dynamodb put-item --table-name ${dest_table_name} --item "${item}"
    done
  fi
}

# テーブル名
original_table_name=$1
dest_table_name=$2

# アイテム情報ファイル名
original_items_file=original_items_${original_table_name}.json
  
get_items_data
put_items