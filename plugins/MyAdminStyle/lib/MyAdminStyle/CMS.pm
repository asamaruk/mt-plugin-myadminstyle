package MyAdminStyle::CMS;

use strict;
use warnings;
use MyAdminStyle::Util;
use MyAdminStyle::MovableType;
use MyAdminStyle::PowerCMS;

sub callback_template_source_header {
  my ($cb, $app, $tmpl_ref, $fname) = @_;
  my $author_id = $app->user->id if (defined $app->user);
  my $blog_id   = $app->param('blog_id');

  my $plugin = plugin();
  my $output_myvars = {
    blog => get_cms_model_values('blog', $blog_id),
    cms => {
      product_code => MT->product_code,
      product_name => MT->product_name,
      version => MT->version_number,
      version_number => MT->version_id,
      static_path => '<mt:StaticFilePath>',
      static_plugin_path => '<mt:StaticFilePath>'.$plugin->envelope.'/',
      static_plugin_modules_path => '<mt:StaticFilePath>'.$plugin->envelope.'/modules/',
      debug_mode => MT->config->DebugMode || "0",
    },
    author_id => $author_id,
    blog_id => '<mt:BlogID>',
    html_title => '<mt:Var name=class-myadminstyle__plugin--html_title__output>',
    id => $app->param('id') || "0",
    mode => $app->param('__mode') || '',
    object_type => '<mt:Var name=object_type>',
    scope_type => '<mt:Var name=scope_type>',
    screen_id => '<mt:Var name=class-myadminstyle__plugin--screen_id__output>',
    type => $app->param('_type') || $app->param('datasource') || '',
  };
  $output_myvars->{author} = get_author_values($author_id) if (defined $app->user);
  $output_myvars = get_movabletype_mycms($output_myvars) if (MT->product_name =~ 'Movable Type');

  if (match_detail($app, 'entry_and_page')){
    $output_myvars = get_detail_values($app, $output_myvars) if ($app->param('id'));
    $output_myvars = get_detail_custom_fields_values($app, $output_myvars);
  }
  if (match_detail($app, 'content_data')){
    my ($content_type_id) = ($app->param('type') || '') =~ /^content_data_([0-9]+)$/;
    $content_type_id ||= $app->param('content_type_id');
    $content_type_id ||= "0";
    $output_myvars->{content_type_id} = $content_type_id || "0";
    $output_myvars = get_detail_contents_data_values($app, $content_type_id, $output_myvars) if ($app->param('id'));
    $output_myvars = get_detail_contents_field_values($app, $content_type_id, $output_myvars);
  }
  if (match_detail($app, 'custom_object')){
    $output_myvars = get_detail_custom_object_values($app, $output_myvars) if ($app->param('id'));
    $output_myvars = get_detail_custom_object_custom_fields_values($app, $output_myvars);
  }

  require JSON;
  my $insert_code = insert_code_in_header(
    JSON::to_json($output_myvars),
    get_plugin_config_values('head_close', $blog_id)
  );
  $$tmpl_ref =~ s!</head>!$insert_code</head>!g;
}

sub callback_template_source_footer {
  my ($cb, $app, $tmpl_ref) = @_;
  my $blog_id = $app->param('blog_id');
  my $values = get_plugin_config_values('body_close', $blog_id);
  $$tmpl_ref =~ s!</body>!$values\n</body>!g;
}

sub method_myadminstyle_permission_blogs {
  my ($app) = @_;
  my $author_id = $app->user->id if (defined $app->user);
  my @permitted_blogs = MT->model('blog')->load(
    undef, {
      'join' => ['MT::Permission', 'blog_id', {author_id => $author_id}],
      no_class => 1
    }
  );
  my $result= {};
  foreach (@permitted_blogs) {
    if (!$_->parent_id){
      $result = {%{$result}, $_->id => get_cms_model_values('blog', $_->id)};
      $result->{$_->id}{children} = {};
    }else{
      $result->{$_->parent_id}{children} = {
        %{$result->{$_->parent_id}{children}}, $_->id => get_cms_model_values('blog', $_->id)
      };
    }
  }
  return $app->json_result(JSON::to_json($result));
}

1;