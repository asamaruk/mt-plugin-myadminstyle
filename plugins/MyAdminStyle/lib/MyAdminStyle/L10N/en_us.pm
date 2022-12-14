package MyAdminStyle::L10N::en_us;

use strict;
use base 'MyAdminStyle::L10N';
use vars qw( %Lexicon );

%Lexicon = (
  'plugin__description' => 'Customize by loading your own files into the admin panel. Beta version.',
  'config__field-headclose--label' => 'Just before the closing tag in head',
  'config__field-headclose--hint--system' => 'Describe what to insert just before the closing tag in head',
  'config__field-headclose--hint--blog' => 'Describe what to insert just before the closing tag of head. If there is a registration in the system plugin settings, it will be added under the content registered in the system.',
  'config__field-bodyclose--label' => 'Just before the closing tag of body',
  'config__field-bodyclose--hint--system' => 'Describe the content to be inserted just before the closing tag of body',
  'config__field-bodyclose--hint--blog' => 'Describe what to insert just before the closing tag of body. If there is a registration in the system plugin settings, it will be added under the content registered in the system.',
);

1;