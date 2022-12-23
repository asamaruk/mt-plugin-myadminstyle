package MyAdminStyle::L10N::ja;

use strict;
use base 'MyAdminStyle::L10N::en_us';
our %Lexicon;

%Lexicon = (
  'My Admin Style Description' => '管理画面に独自ファイルを読み込ませてカスタマイズします。ベータ版です。',
  'config__field-headclose--label' => 'head の閉じタグの直前',
  'config__field-headclose--hint--system'  => 'head の閉じタグ直前に挿入する内容を記述してください。',
  'config__field-headclose--hint--blog'  => 'head の閉じタグ直前に挿入する内容を記述してください。システムのプラグイン設定に登録がある場合は、システムに登録した内容の下に追加されます。',
  'config__field-bodyclose--label' => 'body の閉じタグの直前',
  'config__field-bodyclose--hint--system'  => 'body の閉じタグ直前に挿入する内容を記述してください。',
  'config__field-bodyclose--hint--blog'  => 'body の閉じタグ直前に挿入する内容を記述してください。システムのプラグイン設定に登録がある場合は、システムに登録した内容の下に追加されます。',

  'My Upload Path Description' => 'アップロード時のフォルダを指定してください。',
);

1;