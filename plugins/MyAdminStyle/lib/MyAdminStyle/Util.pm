package MyAdminStyle::Util;

use strict;
use warnings;
use CustomFields::Util qw(get_meta);
use base 'Exporter';

our @EXPORT = qw(
  plugin
  match_detail
  get_model_label
  get_plugin_config_values
  get_cms_model_values
  get_author_values
  get_detail_values
  get_detail_custom_fields_values
  insert_code_in_header
);

sub plugin {
  MT->instance->component('MyAdminStyle');
}

sub match_detail {
  my ($app, $word) = @_;
  my $type = $app->param('_type');
  my $mode = $app->param('__mode');
  my $id   = $app->param('id');
  my $result = 0;
  if (
    $word eq 'entry_and_page' && 
    $mode eq 'view' && $type eq 'entry' || $type eq 'page'){
    $result = 1;
  }
  if (
    $word eq 'content_data' && MT->product_name =~ 'Movable Type' && 
    $mode eq 'view' && $type eq 'content_data'){
    $result = 1;
  }
  if (
    $word eq 'custom_object' && MT->product_name =~ 'PowerCMS' && 
    $mode eq 'view' && $type eq 'customobject'){
    $result = 1;
  }
  return $result;
}

sub get_model_label {
  my ($type) = @_;
  my $model = MT->registry('object_types');
  my ($grep, $match) = [];
  @{$grep}  = grep { m/^\Q$type\E\.?/ } keys %$model;
  @{$match} = grep { $_ eq $type } @{$grep};
  return $match->[0];
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
  return '' if ($load_id eq '0');
  my $result;
  my $model = MT->model($model_label)->load({id => $load_id});
  my $custom_fields = get_meta($model); #basename
  $result = $model->{column_values};
  $result->{custom_field_values} = $custom_fields;
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
  my ($app, $result) = @_;
  my $type = $app->param('_type');
  my $detail_data = MT->model(get_model_label($type))->load($app->param('id'));
  if ($detail_data) {
    my $output_name_primary = $type eq 'entry'?'primary_category':'primary_folder';
    my $output_name = $type eq 'entry'?'categories':'folders';
    my $categories = $detail_data->categories;
    if (@{$categories}){
      $result->{$type}{$output_name_primary} = $detail_data->category->{column_values}||'';
      foreach my $category (@{$categories}) {
        @{$result->{$type}{$output_name}} = $category->{column_values};
      }
    }
    $result->{$type} = get_cms_model_values($type, $app->param('id'));
    $result->{$type} = $detail_data->{column_values};
  }
  return $result;
}

sub get_detail_custom_fields_values {
  my ($app, $result) = @_;
  my $type = $app->param('_type');
  my $custom_fields = [];
  @{$custom_fields} = MT->model('field')->load({obj_type => get_model_label($type), blog_id => $app->param('blog_id')});
  $result->{$type}{custom_fields} = [];
  foreach my $custom_field (@{$custom_fields}) {
    $custom_field->{column_values}{html_wrap_id} = 'customfield_'.$custom_field->{column_values}{basename}.'-field';
    $custom_field->{column_values}{html_field_id} = 'customfield_'.$custom_field->{column_values}{basename};
    push @{$result->{$type}{custom_fields}}, $custom_field->{column_values};
  }
  return $result;
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