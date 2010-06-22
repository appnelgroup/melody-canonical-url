package MT::Entry::Canonical;
use strict;
use warnings;

#--- transformer handlers

sub add_entry_canonical_url_input {
    my ($eh, $app, $param, $tmpl) = @_;
    return unless $tmpl->isa('MT::Template');
    my $q           = $app->can('query') ? $app->query : $app->param;
    my $entry_class = $app->model('entry');
    my $entry_id    = $q->param('id');
    my $entry;
    my $canonical = '';
    if ($entry_id) {
        $entry = $entry_class->load($entry_id, {cached_ok => 1});
        require MT::Util;
        $canonical = MT::Util::encode_html($entry->canonical_url);
    }
    my $innerHTML;
    $innerHTML =
      "<div class='textarea-wrapper'><input name='canonical_url' id='canonical_url' class='full-width' value='$canonical' mt:watch-change='1' autocomplete='off' /></div>";
    my $host_node = $tmpl->getElementById('keywords') # -fields if using emitted HTML
      or return $app->error('Cannot find the keywords field.'); # MT ignores these errors apparently
    my $block_node = $tmpl->createElement(
        'app:setting',
        {   id    => 'canonical_url',
            label => 'Canonical URL',
            label_class => 'top-label',
        }
    ) or return $app->error('cannot create the element');
    $block_node->innerHTML($innerHTML);
    $tmpl->insertAfter($block_node, $host_node)
      or return $app->error('failed to insertBefore.');
}

sub save_entry_canonical_url {
    my ($cb, $app, $obj, $orig) = @_;
    my $q = $app->can('query') ? $app->query : $app->param;
    my $canonical = $q->param('canonical_url');
    if ($canonical) {
        require URI;
        my $uri =
          URI->new_abs($canonical, 'http://example.com/');    # canonical base
        $canonical = $uri->canonical->as_string;
        $obj->canonical_url($canonical);
    }
    else {
        $obj->canonical_url('');
    }
    $obj->save;
}

#--- template tag handlers

sub entry_canonical_URL {
    my ($ctx, $args, $cond) = @_;
    my $entry = $ctx->stash('entry') or return '';                     # error if not entry
    my $canonical = $entry->canonical_url or return '';
    require URI;
    my $uri =
      URI->new_abs($canonical, 'http://example.com/');    # canonical base
    $canonical = $uri->canonical->as_string;
    return $canonical;
}

1;

__END__
