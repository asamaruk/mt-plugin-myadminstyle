package MyAdminStyle::PowerCMS;

use strict;
use warnings;
use MyAdminStyle::Util;

use base 'Exporter';
our @EXPORT = qw(
  get_detail_custom_object_values
  get_detail_custom_object_custom_fields_values
);

sub get_detail_custom_object_values {
  my ($app, $result) = @_;
  my $type = $app->param('_type');
  my $detail_data = MT->model(get_model_label($type))->load($app->param('id'));
  if ($detail_data) {
    my $folder = $detail_data->folder;
    if ($folder){
      $result->{$type}{folders} = $detail_data->folder->{column_values}||'';
    }
    $result->{$type} = get_cms_model_values($type, $app->param('id'));
    $result->{$type} = $detail_data->{column_values};
  }
  return $result;
}

sub get_detail_custom_object_custom_fields_values {
  my ($app, $result) = @_;
  my $type = $app->param('_type');
  my $custom_fields = [];
  @{$custom_fields} = MT->model('field')->load({obj_type => get_model_label($type), blog_id => $app->param('blog_id')});
  $result->{$type}{custom_fields} = [];
  foreach my $custom_field (@{$custom_fields}) {
    $custom_field->{column_values}{html_wrap_id} = 'customfield_'.$custom_field->{column_values}{basename}.'-field';
    $custom_field->{column_values}{html_field_id} = 'customfield_'.$custom_field->{column_values}{basename};
    @{$result->{$type}{custom_fields}} = $custom_field->{column_values};
  }
  return $result;
}

1;