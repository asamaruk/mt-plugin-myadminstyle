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
  description => '<__trans phrase="plugin__description">',
  blog_config_template => 'config_blog_template.tmpl',
  system_config_template => 'config_system_template.tmpl',
  settings => new MT::PluginSettings([
    ['head_close', {Default => ''}],
    ['body_close', {Default => ''}],
  ]),
  version => '0.0.1',
  schema_version => '0.0.1',
  l10n_class => 'MyAdminStyle::L10N',
});
MT->add_plugin($plugin);

sub init_registry {
  my ($plugin) = @_;
  $plugin->registry({
    callbacks => {
      'MT::App::CMS::template_source.header' => {
        handler  => '$MyAdminStyle::MyAdminStyle::Callbacks::template_source_header',
        priority => 11,
      },
      'MT::App::CMS::template_source.footer' => {
        handler  => '$MyAdminStyle::MyAdminStyle::Callbacks::template_source_footer',
        priority => 11,
      },
    },
  });
}

1;