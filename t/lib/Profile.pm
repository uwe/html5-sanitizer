package Profile;

# this is a stripped down profile of XING
# so if some things make no sense, it is because I removed some stuff

use Moose;

use Carp qw/croak/;
use URI;


my %CLASSES = ();
$CLASSES{'wysiwyg-clear-'.$_}           = 1 foreach (qw/right left both/);
$CLASSES{'wysiwyg-color-'.$_}           = 1 foreach (qw/black silver gray white maroon red purple fuchsia green lime olive yellow navy blue teal aqua xing/);
$CLASSES{'wysiwyg-float-'.$_}           = 1 foreach (qw/right left/);
$CLASSES{'wysiwyg-font-size-'.$_}       = 1 foreach (qw/large medium small x-large x-small xx-large xx-small larger smaller/);
$CLASSES{'wysiwyg-text-align-'.$_}      = 1 foreach (qw/right left center justify/);
$CLASSES{'wysiwyg-text-decoration-'.$_} = 1 foreach (qw/underline/);


# element transformation rules (or attribute checks)
# done in this order:
# - rename_tag         (rename the element, change tag)
# - set_attributes     (set fixed values for attributes)
# - check_attributes   (check and filter attribute values)
# - set_class          (set class value, first position)
# - add_class          (add class value, second position)
# - check_class        (allowed classes; existing class attributes becomes third position)
my %ELEMENT_SPEC = (
    a           => {set_attributes      => {rel => 'nofollow', target => '_blank'},
                    check_attributes    => {href => 'url'},
    },
    b           => {},
    big         => {rename_tag          => 'span',
                    set_class           => 'wysiwyg-font-size-larger',
    },
    blockquote  => {check_attributes    => {cite => 'url'},
    },
    br          => {add_class           => {clear => 'clear_br'},
    },
    caption     => {add_class           => {align => 'align_text'},
    },
    center      => {rename_tag          => 'div',
                    set_class           => 'wysiwyg-text-align-center',
    },
    cite        => {},
    code        => {},
    dir         => {rename_tag          => 'ul',
    },
    font        => {rename_tag          => 'span',
                    add_class           => {size => 'size_font'},
    },
    div         => {add_class           => {align => 'align_text'},
    },
    em          => {},
    h1          => {add_class           => {align => 'align_text'},
    },
    h2          => {add_class           => {align => 'align_text'},
    },
    h3          => {add_class           => {align => 'align_text'},
    },
    h4          => {add_class           => {align => 'align_text'},
    },
    h5          => {add_class           => {align => 'align_text'},
    },
    h6          => {add_class           => {align => 'align_text'},
    },
    hr          => {},
    i           => {},
    img         => {add_class           => {align => 'align_img'},
                    check_attributes    => {src => 'url', alt => 'alt', width => 'numbers', height => 'numbers'},
    },
    li          => {},
    map         => {rename_tag          => 'div',
    },
    menu        => {rename_tag          => 'ul',
    },
    q           => {check_attributes    => {cite => 'url'},
    },
    ol          => {},
    p           => {add_class           => {align => 'align_text'},
    },
    pre         => {},
    small       => {rename_tag          => 'span',
                    set_class           => 'wysiwyg-font-size-smaller',
    },
    span        => {},
    strong      => {},
    table       => {},
    tbody       => {add_class           => {align => 'align_text'},
    },
    td          => {add_class           => {align => 'align_text'},
                    check_attributes    => {colspan => 'numbers', rowspan => 'numbers'},
    },
    tfoot       => {add_class           => {align => 'align_text'},
    },
    th          => {add_class           => {align => 'align_text'},
                    check_attributes    => {colspan => 'numbers', rowspan => 'numbers'},
    },
    thead       => {add_class           => {align => 'align_text'},
    },
    tr          => {add_class           => {align => 'align_text'},
    },
    u           => {rename_tag          => 'span',
                    set_class           => 'wysiwyg-text-decoration-underline',
    },
    ul          => {},
);

# these elements (and all children) are completely removed
my @REMOVE_ELEMENTS = qw/applet audio canvas colgroup comment del frameset head iframe noembed noframes noscript object script strike style svg title video xml/;

$ELEMENT_SPEC{$_} = {remove => 1} foreach (@REMOVE_ELEMENTS);


sub element {
    my ($self, $tag) = @_;

    return $ELEMENT_SPEC{$tag};
}

sub classes {
    return \%CLASSES;
}


# check attributes
#------------------

# accept only http and https URLs
sub _check_url {
    my ($self, $value) = @_;
    return unless $value;

    return unless $value =~ m|^http[s]?://|i;

    my $uri = URI->new($value)->canonical;
    return unless $uri;

    return $uri->as_string;
}

# accept letters and numbers, but provide default value
sub _check_alt {
    my ($self, $value) = @_;
    return '' unless $value;

    $value =~ tr/ _a-zA-Z0-9-//cd;

    return $value || '';
}

# allow only numbers, do not allow '0'
sub _check_numbers {
    my ($self, $value) = @_;
    return unless $value;

    $value =~ s/\D//g;

    return $value || undef;
}


# add class attribute
#---------------------

sub _class_align_img {
    my ($self, $value, $attr) = @_;
    return unless $value;

    return 'wysiwyg-float-left'  if $value =~ /^left$/i;
    return 'wysiwyg-float-right' if $value =~ /^right$/i;

    return;
}

sub _class_align_text {
    my ($self, $value, $attr) = @_;
    return unless $value;

    return 'wysiwyg-text-align-center'  if $value =~ /^center$/i;
    return 'wysiwyg-text-align-justify' if $value =~ /^justify$/i;
    return 'wysiwyg-text-align-left'    if $value =~ /^left$/i;
    return 'wysiwyg-text-align-right'   if $value =~ /^right$/i;

    return;
}

sub _class_clear_br {
    my ($self, $value, $attr) = @_;
    return unless $value;

    return 'wysiwyg-clear-left'  if $value =~ /^left$/i;
    return 'wysiwyg-clear-right' if $value =~ /^right$/i;
    return 'wysiwyg-clear-both'  if $value =~ /^(all|both)$/i;

    return;
}

sub _class_size_font {
    my ($self, $value, $attr) = @_;
    return unless $value;

    return 'wysiwyg-font-size-xx-large' if $value eq '7';
    return 'wysiwyg-font-size-xx-large' if $value eq '6';
    return 'wysiwyg-font-size-x-large'  if $value eq '5';
    return 'wysiwyg-font-size-large'    if $value eq '4';
    return 'wysiwyg-font-size-medium'   if $value eq '3';
    return 'wysiwyg-font-size-small'    if $value eq '2';
    return 'wysiwyg-font-size-xx-small' if $value eq '1';

    return 'wysiwyg-font-size-larger'   if substr($value, 0, 1) eq '+';
    return 'wysiwyg-font-size-smaller'  if substr($value, 0, 1) eq '-';

    return;
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
