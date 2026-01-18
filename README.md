# Labo

My home labo.

## diskの拡張

前提: LVMを利用していないこと

ubuntuをレスキューモードで起動する。
grub画面でeditし、linux行に`systemd.unit=rescue.target`を追加

partedコマンドでパーティションを拡張し、パーティションとファイルシステムを拡張する。

備考:

- https://ja.linux-terminal.com/?p=4448
- https://zenn.dev/yakumo/articles/aae5ea3a4d544adea7d3c06eadf6c714
