package HTML5::Sanitizer;
# ABSTRACT: sanitize HTML(5) (based on whitelisting)

use Moose;

use HTML5::Sanitizer::Converter;
use HTML5::Sanitizer::Parser;
use HTML5::Sanitizer::Preprocessor;
use HTML5::Sanitizer::Result;
use HTML5::Sanitizer::Specification;
use HTML5::Sanitizer::Writer;


has specification => (is => 'ro', required => 1, builder => '_build_specification');
has profile       => (is => 'ro', required => 1);
has preprocessor  => (is => 'ro', required => 1, builder => '_build_preprocessor');
has parser        => (is => 'ro', required => 1, builder => '_build_parser');
has converter     => (is => 'ro', required => 1, builder => '_build_converter');
has writer        => (is => 'ro', required => 1, builder => '_build_writer');

has return_result => (is => 'ro', isa => 'Bool');


sub _build_specification { HTML5::Sanitizer::Specification->new }
sub _build_preprocessor  { HTML5::Sanitizer::Preprocessor->new  }
sub _build_parser        { HTML5::Sanitizer::Parser->new        }
sub _build_converter     { HTML5::Sanitizer::Converter->new     }
sub _build_writer        { HTML5::Sanitizer::Writer->new        }


sub process {
    my ($self, $input, $opt) = @_;
    $opt ||= {};

    my %result        = ();
    my $return_result = $opt->{return_result} || $self->return_result;

    # get specification (default should be sufficient)
    my $spec = $opt->{specification} || $self->specification;

    # get profile
    my $profile = $opt->{profile} || $self->profile;

    if ($return_result) {
        $result{specification} = $spec;
        $result{profile}       = $profile;
        $result{input}         = $input;
    }

    # step 1: pre processing (optional)
    # ---------------------------------
    my $preprocessor = $opt->{preprocessor} || $self->preprocessor;
    my $preprocessed = $preprocessor->process($input);

    if ($return_result) {
        $result{preprocessed} = $preprocessed;
    } else {
        $input = undef;
    }

    # step 2: parse HTML into XML::LibXML DOM tree
    # --------------------------------------------
    my $parser     = $opt->{parser} || $self->parser;
    my $parsed_doc = $parser->process($preprocessed);

    if ($return_result) {
        $result{parsed_doc} = $parsed_doc;
    }
    else {
        $preprocessed = undef;
    }

    # step 3: convert DOM tree according to profile
    # ---------------------------------------------
    my $converter     = $opt->{converter} || $self->converter;
    my $converted_doc = $converter->process($parsed_doc, $spec, $profile);

    if ($return_result) {
        $result{converted_doc} = $converted_doc;
    }
    else {
        $parsed_doc = undef;
    }

    # step 4: write HTML
    # ------------------
    my $writer = $opt->{writer} || $self->writer;
    my $output = $writer->process($converted_doc, $spec);

    if ($return_result) {
        $result{output} = $output;
        return HTML5::Sanitizer::Result->new(%result);
    }
    else {
        return $output;
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

  use HTML5::Sanitizer;
  use MyProfile;

  my $sanitizer  = HTML5::Sanitizer->new(profile => MyProfile->new);
  my $clean_html = $sanitizer->process($html);

=head1 DESCRIPTION

This module sanitizes HTML based on whitelisting. You have to provide your own
profile (whitelist). It is suited for HTML5, but works with older versions and
XHTML too. It also accepts (mildly) broken HTML.

HTML5::Sanitizer uses L<XML::LibXML> to parse HTML into a DOM tree. Then,
based on the L<profile|/PROFILE>, it creates a new DOM tree (where it changes
tags and attributes). An optimizer for empty div and span elements is included.

=head1 METHODS

=head2 new

Constructor. You have to pass in a L<profile|/PROFILE>. Optional parameters are
L<preprocessor|HTML5::Sanitizer::Preprocessor>,
L<parser|HTML5::Sanitizer::Parser>, L<converter|HTML5::Sanitizer::Converter>,
L<writer|HTML5::Sanitizer::Writer> and
L<specification|HTML5::Sanitizer::Specification>.

=head2 process

Sanitize HTML. It takes a HTML string as first argument and optional parameters
(hashref) as second. It returns the sanitized HTML as string (scalar).

The optional parameters are the same as L</new>. They can be used to override
the default setting (object construction) at runtime (calling the process
method). Usually you don't need that. Setting these things via L</new> should
be enough.

For debugging purposes you can set C<return_result> to true. The output is
then a L<HTML5::Sanitizer::Result> object, which gives you access to the
intermediate results.

=head1 PROFILE

You have to write your own profile class. It has to have the following
methods:

=over 4

=item classes

Return a hashref of allowed classes. The keys are valid class names (and the
value should always be true).

Warning: This might change to an arrayref in later versions.

=item element (tag)

Given the tag name it returns a hashref with instructions how to transform
this element, or C<undef> if this tag is unknown.

The instructions hashref may contain the following keys:

=over 4

=item remove [boolean]

Remove this element and all child elements completely.

=item rename_tag [string]

Rename the tag.

=item set_attributes [hashref]

Set these attributes (keys) to these values (values).

=item check_attributes [hashref]

Check existing attributes (keys) on the element. The values of the hashref
are named constraints (strings), which get converted into a method name by
prefixing it with C<_check_>. So the constrint C<url> becomes C<_check_url>.
This method is called with the old value of the attribute as parameter. It
returns the new (maybe modified) value or C<undef>. In the latter case, the
attribute is removed.

=item set_class [string]

Set the class attribute.

Warning: This might change to an arrayref in later versions.

=item add_class [hashref]

Add something to the class attribute depending on the values of other
attributes. The keys specify the name of the other attribute, the values
are used to build the method, prefixed with C<_class_>. This method gets
the value of the other attribute as parameter.

=back

The order for the class attribute is as follows:

=over 4

=item set_class

=item add_class

=item any existing value of the class attribute

=back

All of theses classes are checked against the allowed values returned by the
L<classes> method.

Have a look at the example profile in the t/lib directory. The font tag is
a good example for C<add_class>.

=back

=head1 SEE ALSO

L<https://github.com/xing/html5-sanitizer>

=head1 AUTHOR

Uwe Voelker uwe@uwevoelker.de

=head1 COPYRIGHT

(c) 2011 by XING AG, http://corporate.xing.com/

=cut
