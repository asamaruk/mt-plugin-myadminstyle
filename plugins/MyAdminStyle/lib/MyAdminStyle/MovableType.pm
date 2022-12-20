package MyAdminStyle::MovableType;

use strict;
use warnings;
use MyAdminStyle::Util;

use base 'Exporter';
our @EXPORT = qw(
  get_movabletype_mycms
  get_detail_contents_field_values
  get_detail_contents_data_values
);

sub get_movabletype_mycms {
  my ($output_myvars) = @_;
  my $result = $output_myvars;
  $result->{cms}{release_version} = MT->release_version_id if (MT->version_number >= 7);
  return $result;
}

sub get_detail_contents_field_values {
  my ($app, $content_type_id, $result) = @_;
  my $type = $app->param('_type');
  my $content_fields = [];
  @{$content_fields} = MT->model('content_field')->load({content_type_id => $content_type_id});
  $result->{$type}{content_fields} = [];
  foreach my $content_field (@{$content_fields}) {
    $content_field->{column_values}{html_wrap_id} = 'contentField'.$content_field->{column_values}{id};
    $content_field->{column_values}{html_field_id} = 'content-field-'.$content_field->{column_values}{id};
    @{$result->{$type}{content_fields}} = $content_field->{column_values};
  }
  return $result;
}

sub get_detail_contents_data_values {
  my ($app, $content_type_id, $result) = @_;
  my $type = $app->param('_type');
  my $detail_data = MT->model(get_model_label($type))->load($app->param('id'));
  $result->{$type} = $detail_data->{column_values} if ($detail_data);

  my $content_fields = [];
  @{$content_fields} = MT->model('content_field')->load({content_type_id => $content_type_id});
  $result->{$type}{content_fields} = [];
  foreach my $content_field (@{$content_fields}) {
    my $content_data_value = MT::ContentFieldIndex->load(
      {
        content_type_id  => $content_type_id,
        content_data_id  => $detail_data->{column_values}{id},
        content_field_id => $content_field->{column_values}{id},
      }
    );
    @{$result->{$type}{content_field_values}} = $content_data_value->{column_values};
  }
  
  return $result;
}

1;