package MT::Plugin::MyAdminStyle;

use strict;
use warnings;
use MT;
use base qw(MT::Plugin);
use MyAdminStyle::Util;

my $plugin = MT::Plugin::MyAdminStyle->new({
  id => 'MyAdminStyle',
  key => __PACKAGE__,
  name => 'MyAdminStyle',
  author_name => "CMS NOTE",
  author_link => 'https://cms-note.com/',
  doc_link => 'https://cms-note.com/',
  plugin_link => 'https://cms-note.com/',
  description => '<__trans phrase="My Admin Style Description">',
  blog_config_template => 'config_blog_template.tmpl',
  system_config_template => 'config_system_template.tmpl',
  settings => new MT::PluginSettings([
    ['head_close', {Default => ''}],
    ['body_close', {Default => ''}],
  ]),
  version => '0.0.4',
  schema_version => '0.01',
  l10n_class => 'MyAdminStyle::L10N',
});
MT->add_plugin($plugin);

sub init_registry {
  my ($plugin) = @_;
  my $pkg = '$MyAdminStyle';
  $plugin->registry({
    object_types => {
      field => {
        my_upload_path => 'text',
      },
    },
    callbacks => {
      'MT::App::CMS::template_source.header' => {
        handler  => "${pkg}::MyAdminStyle::CMS::callback_template_source_header",
        priority => 11,
      },
      'MT::App::CMS::template_source.footer' => {
        handler  => "${pkg}::MyAdminStyle::CMS::callback_template_source_footer",
        priority => 11,
      },
      'MT::App::CMS::template_param.edit_field' => {
        handler  => "${pkg}::MyUploadPath::CMS::callback_template_param_edit_field",
        priority => 11,
      },
      'MT::App::CMS::template_param.asset_modal' => {
        handler  => "${pkg}::MyUploadPath::CMS::callback_template_param_asset_upload",
        priority => 11,
      },
      'MT::App::CMS::template_output.asset_modal' => {
        handler  => "${pkg}::MyUploadPath::CMS::callback_template_output_asset_upload",
        priority => 11,
      },
      
    },
    applications => {
      cms => {
        methods => {
          my_permission_blogs => "${pkg}CMS::method_myadminstyle_permission_blogs",
        }
      }
    },
    content_field_types => {
      multi_line_text => {
        options_html => 'content_field_type_options/multi_line_text.tmpl',
        options => 'my_upload_path',
      },
      asset => {
        options_html => 'content_field_type_options/asset.tmpl',
        options => 'my_upload_path',
      },
      asset_image => {
        options_html => 'content_field_type_options/asset_image.tmpl',
        options => 'my_upload_path',
      },
      asset_video => {
        options_html => 'content_field_type_options/asset_video.tmpl',
        options => 'my_upload_path',
      },
      asset_audio => {
        options_html => 'content_field_type_options/asset_audio.tmpl',
        options => 'my_upload_path',
      },
    },
  });
}

1;