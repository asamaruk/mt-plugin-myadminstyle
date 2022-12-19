package MyAdminStyle::CMS;

use strict;
use warnings;
use MyAdminStyle::Util;

sub callback_template_source_header {
  my ($cb, $app, $tmpl_ref, $fname) = @_;
  my $author_id = $app->user->id if(defined $app->user);
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
    html_title => '<mt:Var name=class-myadminstyle__plugin--html_title__render>',
    id => $app->param('id') || "0",
    mode => $app->param('__mode') || '',
    object_type => '<mt:Var name=object_type>',
    # requests => $app->param->{param},
    scope_type => '<mt:Var name=scope_type>',
    screen_id => '<mt:Var name=class-myadminstyle__plugin--screen_id__render>',
    type => $app->param('_type') || $app->param('datasource') || '',
  };
  my $author = get_cms_model_values('author', $author_id);
  $output_myvars->{author} = get_author_values($author_id) if(defined $app->user);
  my $flag_detail_page = grep { /^(_type||__mode||id)$/ } keys $app->param->{param};
  $output_myvars = get_detail_values($output_myvars, $app) if($flag_detail_page eq 3 );
  # Unique Movable Type
  $output_myvars = get_unique_movabletype_values($output_myvars, $app, $flag_detail_page) if(MT->product_name =~ 'Movable Type');
  # Unique PowerCMS
  # $output_myvars = get_unique_powercms_values() if(MT->product_name =~ 'PowerCMS');

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
  my $author_id = $app->user->id if(defined $app->user);
  my @permitted_blogs = MT->model('blog')->load(
    undef, {
      'join' => ['MT::Permission', 'blog_id', {author_id => $author_id}],
      no_class => 1
    }
  );
  my $result= {};
  foreach (@permitted_blogs) {
    if(!$_->parent_id){
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