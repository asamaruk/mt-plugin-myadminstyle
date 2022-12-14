package MyAdminStyle::Util;

use strict;
use warnings;
use CustomFields::Util qw(get_meta);
use base 'Exporter';

our @EXPORT = qw(
  plugin
  get_plugin_config_values
  get_cms_model_values
  get_my_author_values
  get_my_blog_values
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
  my $result;
  my $model = MT->model($model_label)->load({id => $load_id});
  my $customfields = get_meta($model);
  $result->{$model_label} = $model->{column_values};
  $result->{$model_label}{customfields} = $customfields;
  return $result;
}

sub get_my_author_values {
  my ($author_id) = @_;
  my $author_permission = MT->model('permission')->load({author_id => $author_id});
  my $author = get_cms_model_values('author', $author_id);
  delete $author->{author}{password};
  delete $author->{author}{api_password};
  my $output_myvars = {
    user => $author->{author},
    permission => $author_permission->{column_values},
  };
  return $output_myvars;
}

sub get_my_blog_values {
  my $author_id = @_;
  my ($my_blogs, $my_blogs_nest);
  my @permitted_blogs = MT->model('blog')->load(
    undef, {
      'join' => ['MT::Permission', 'blog_id', {author_id => $author_id}],
      no_class => 1
    }
  );
  foreach (@permitted_blogs) {
    my $blog_id = $_->id;
    $my_blogs->{$blog_id} = get_cms_model_values('blog', $blog_id)->{blog};
    if(!$_->parent_id){
      $my_blogs_nest->{$blog_id} = [];
    }else{
      push @{$my_blogs_nest->{$_->parent_id}}, $blog_id;
    }
  }
  my $output_myvars = {
    blog => $my_blogs,
    nest => $my_blogs_nest,
  };
  return $output_myvars;
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