package MyAdminStyle::Util;

use strict;
use warnings;
use CustomFields::Util qw(get_meta);
use base 'Exporter';

our @EXPORT = qw(
  plugin
  get_plugin_config_values
  get_cms_model_values
  get_author_values
  get_detail_values
  get_unique_movabletype_values
  insert_code_in_header
);

sub plugin {
  MT->instance->component('MyAdminStyle');
}

sub get_plugin_config_values {
  my ($key, $blog_id) = @_;
  my $plugin = plugin();
  my $values = [$plugin->get_config_value($key, 'system')];
  push @{$values}, $plugin->get_config_value($key, 'blog:' . $blog_id) if $blog_id ne 0;
  return join "\n", @$values;
}

sub get_cms_model_values {
  my ($model_label, $load_id) = @_;
  return '' if($load_id eq '0');
  my $result;
  my $model = MT->model($model_label)->load({id => $load_id});
  my $customfields = get_meta($model);
  $result = $model->{column_values};
  $result->{customfields} = $customfields;
  return $result;
}

sub get_author_values {
  my ($author_id) = @_;
  my $author_permission = MT->model('permission')->load({author_id => $author_id});
  my $author = get_cms_model_values('author', $author_id);
  delete $author->{password};
  delete $author->{api_password};
  my $result = {
    user => $author,
    permission => $author_permission->{column_values},
  };
  return $result;
}

sub get_detail_values {
  my ($output_myvars, $app) = @_;
  my $type = $app->param('_type');
  my $result = $output_myvars;
  my $model = MT->registry('object_types');
  my ($grep, $match) = [];
  @{$grep}  = grep { m/^\Q$type\E\.?/ } keys %$model;
  @{$match} = grep { $_ eq $type } @{$grep};
  my $detail_data = MT->model($match->[0])->load($app->param('id'));
  if($detail_data) {
    if($type eq 'entry' || $type eq 'page') {
      my $output_name_primary = $type eq 'entry'?'primary_category':'primary_folder';
      my $output_name = $type eq 'entry'?'categories':'folders';
      my $categories = $detail_data->categories;
      if($categories){
        foreach (@{$categories}) {
          push @{$result->{$type}{$output_name}}, $_->{column_values};
          $result->{$type}{$output_name_primary} = $detail_data->category->{column_values}||'';
        }
      }
      $result->{$type} = get_cms_model_values('entry', $app->param('id'));
    }
    $result->{$type} = $detail_data->{column_values};
  }
  return $result;
}

sub get_unique_movabletype_values {
  my ($output_myvars, $app, $flag_detail) = @_;
  my $result = $output_myvars;
  my $type = $app->param('_type');
  my ($content_type_id) = ($app->param('type') || '') =~ /^content_data_([0-9]+)$/;
  $content_type_id ||= $app->param('content_type_id');
  $content_type_id ||= "0";

  if($flag_detail eq 3 && $type eq 'content_data' && $content_type_id) {
    my $field = [];
    @{$field} = MT->model('content_field')->load({content_type_id => $content_type_id});
    $result->{$type}{content_fields} = [];
    foreach (@{$field}) {
      $_->{column_values}{html_wrap_id} = 'contentField'.$_->{column_values}{id};
      $_->{column_values}{html_field_id} = 'content-field-'.$_->{column_values}{id};
      push @{$result->{$type}{content_fields}}, $_->{column_values};
    }
  }
  $result->{cms}{release_version} = MT->release_version_id if(MT->version_number >= 7);
  $result->{content_type_id} = $content_type_id || "0";
  return $result;
}

sub get_unique_powercms_values {
  return 1;
}

sub insert_code_in_header {
  my ($json, $head_close_code) = @_;
  my $result = <<"EOS";
  <mt:SetVarTemplate name="class-myadminstyle" note="MyAdminStyle Plugin MTML">
    <mt:SetVarTemplate name="class-myadminstyle__plugin--screen_id" note="Create JSON screen_id value">
      <mt:Unless name="screen_id">
        <mt:if name="template_filename" like="^list_">
          <mt:SetVarBlock name="screen_id" append="1"><mt:Var name="request.__mode">-</mt:SetVarBlock>
          <mt:SetVarBlock name="screen_id" append="1"><mt:Var name="object_type"></mt:SetVarBlock>
        </mt:if>
      </mt:Unless>
      <mt:SetVarTemplate name="class-myadminstyle__plugin--screen_id__render" note="Output"><mt:Var name="screen_id" escape="html"></mt:SetVarTemplate>
    </mt:SetVarTemplate>
    <mt:SetVarTemplate name="class-myadminstyle__plugin--html_title" note="Create JSON html_title value">
      <mt:SetVarTemplate name="class-myadminstyle__plugin--html_title__render" note="Output"><mt:if name="html_title"><mt:var name="html_title" escape="html"><mt:else><mt:var name="page_title" escape="html"></mt:if></mt:SetVarTemplate>
    </mt:SetVarTemplate>
  </mt:SetVarTemplate>

  <mt:Var name="class-myadminstyle">
  <mt:Var name="class-myadminstyle__plugin--screen_id">
  <mt:Var name="class-myadminstyle__plugin--html_title">

  <script id="myadminstyle-vars">const myadminstyle_vars = $json;</script>
  $head_close_code
EOS
  return $result;
}

1;