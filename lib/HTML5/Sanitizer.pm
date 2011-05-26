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

HTML5::Sanitizer uses XML::LibXML to parse HTML into a DOM tree. Then, based
on the profile, it creates a new DOM tree (where it changes tags and
attributes). An optimizer for empty div and span elements is included.

=head1 METHODS

=head2 new

=head2 process

=head1 PROFILE



=head1 SEE ALSO

L<https://github.com/xing/html5-sanitizer>

=cut
