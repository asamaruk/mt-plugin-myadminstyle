package MyUploadPath::CMS;

use strict;
use warnings;
use MT;
use MT::Asset;
use MT::Util qw( encode_html );
use MyUploadPath::MovableType;

sub callback_template_param_edit_field {
  my ($cb, $app, $param, $tmpl) = @_;
  return unless ($app->param('id'));

  my $custom_field = $app->model('field')->load($app->param('id'));
  return unless ($custom_field->{column_values}->{type} =~ /file|audio|image|video/);
  my $my_upload_path = encode_html($custom_field->my_upload_path)||'';

  my $host_element = $tmpl->getElementById('required');
  my $new_element = $tmpl->createElement('app:setting');
  $new_element->setAttribute('id', 'my_upload_path');
  $new_element->setAttribute('label', $app->translate('Upload Destination'));
  my $description = $app->translate('My Upload Path Description');
  my $inner_html = <<EOS;
  <input type="text" name="my_upload_path" value="${my_upload_path}" id="my_upload_path" class="form-control text" placeholder="myuploadpath">
  <div class="hint"><small id="basenameHelp" class="form-text text-muted last-child">${description}</small></div>
EOS
  $new_element->innerHTML($inner_html);
  $tmpl->insertAfter($new_element, $host_element);
}

sub callback_template_output_asset_upload {
  my ($cb, $app, $output, $param, $tmpl) = @_;
  my $plugins = MT->config->pluginschemaversion;
  my $nofollow_switch = $plugins->{'UploadDir/mt-uploaddir.pl'};

  # UploadDir M-Logic, Inc.
  if ($nofollow_switch){
    my $old_element = quotemeta('fd.append(\'extra_path\', dn );');
    my $new_element = 'fd.append(\'extra_path\', jQuery(\'#extra_path\').val() + \'/\' + dn);';
    $$output =~ s!($old_element)!$new_element!;
  }
}

sub callback_template_param_asset_upload {
  my ( $cb, $app, $param, $tmpl ) = @_;
  return unless (my $blog_id = $app->param('blog_id'));

  my $my_upload_path;
  if ($app->param('edit_field') =~ /customfield_/){
    my $blog_id = $app->param('blog_id');
    my $custom_field_name = $app->param('edit_field');
    $custom_field_name =~ s/^customfield_//;
    my $terms = {
      blog_id => $blog_id,
      basename => $custom_field_name,
      type => [qw(file audio image video)],
    };
    my $custom_field = $app->model('field')->load( $terms );
    $my_upload_path = $custom_field->column_values->{my_upload_path};
  }else{
    $my_upload_path = get_movabletype_content_field_upload_path($app) if (MT->product_name =~ 'Movable Type' && MT->version_number >= 7);
  }
  if (my $extra_path = $param->{extra_path}){
    $param->{extra_path} = $extra_path."/".$my_upload_path;
  }else{
    $param->{extra_path} = $my_upload_path;
  }
}

1;