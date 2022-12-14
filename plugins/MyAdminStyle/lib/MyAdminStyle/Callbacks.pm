package MyAdminStyle::Callbacks;

use strict;
use warnings;
use MyAdminStyle::Util;

sub template_source_header {
  my ( $cb, $app, $tmpl_ref, $fname ) = @_;
  my $author_id = $app->user->id if(defined $app->user);
  my $blog_id   = $app->param('blog_id');
  my $content_type_id = ( $app->param('type') || '' ) =~ /^content_data_([0-9]+)$/;
     $content_type_id ||= $app->param('content_type_id');

  my $plugin = plugin();
  my $output_myvars = {
    my_cms => {
      product_code => MT->product_code,
      product_name => MT->product_name,
      version => MT->version_number,
      version_number => MT->version_id,
      static_path => '<mt:StaticFilePath>',
      static_plugin_path => '<mt:StaticFilePath>' . $plugin->envelope . '/',
      static_plugin_modules_path => '<mt:StaticFilePath>' . $plugin->envelope . '/' . 'modules' . '/',
      debug_mode => MT->config->DebugMode || "0",
    },
    # requests => $app->param->{param},
    id => $app->param('id') || "0",
    author_id => $author_id,
    blog_id => '<mt:BlogID>',
    mode => $app->param('__mode') || '',
    type => $app->param('_type') || $app->param('datasource') || '',
    object_type => '<mt:Var name=object_type>',
    scope_type => '<mt:Var name=scope_type>',
    screen_id => '<mt:Var name=class-myadminstyle__plugin--screen_id__render>',
    html_title => '<mt:Var name=class-myadminstyle__plugin--html_title__render>',
  };
  $output_myvars->{my_author} = get_my_author_values($author_id) if(defined $app->user);
  $output_myvars->{my_blogs} = get_my_blog_values($author_id) if(defined $app->user);

  # Unique Movable Type
  if(MT->product_name =~ 'Movable Type'){
    $output_myvars->{my_cms}{release_version} = MT->release_version_id if(MT->version_number >= 7);
    $output_myvars->{content_type_id} = $content_type_id || "0";
  }

  # Unique PowerCMS
  # if(MT->product_name =~ 'PowerCMS'){}

  my $insert_code = insert_code_in_header(
    JSON::to_json($output_myvars),
    get_plugin_config_values('head_close', $blog_id)
  );
  $$tmpl_ref =~ s!</head>!$insert_code</head>!g;
}

sub template_source_footer {
  my ( $cb, $app, $tmpl_ref ) = @_;
  my $blog_id = $app->param( 'blog_id' );
  my $values = get_plugin_config_values( 'body_close', $blog_id );
  $$tmpl_ref =~ s!</body>!$values\n</body>!g;
}

1;