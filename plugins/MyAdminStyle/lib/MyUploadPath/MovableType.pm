package MyUploadPath::MovableType;

use strict;
use warnings;
use MT::Util qw( encode_html );

use base 'Exporter';
our @EXPORT = qw(
  get_movabletype_content_field_upload_path
);

sub get_movabletype_content_field_upload_path {
  my ($app) = @_;
  my $my_upload_path;
  return $my_upload_path unless (my $content_field_id = $app->param('content_field_id')||$app->param('edit_field') =~ /^content-field/);
  if ($app->param('edit_field')){
    $content_field_id = $app->param('edit_field');
    $content_field_id =~ s/^editor-input-content-field-//;
  }
  my $content_field = $app->model('content_field')->load($content_field_id);
  my $content_type_id = $content_field->{column_values}->{content_type_id};
  my $content_types = $app->model('content_type')->load($content_type_id);
  # my $serialize = MT::Serialize->new('MT');
  # my $$content_types = $serialize->unserialize($content_types->{column_values});
  foreach my $field (values(@{$content_types->{__cached_fields}})){
    if ($field->{id} eq $content_field_id){
      next unless $field->{options}->{my_upload_path};
      $my_upload_path = encode_html($field->{options}->{my_upload_path});
      last;
    }
  }
  return $my_upload_path;
}

1;