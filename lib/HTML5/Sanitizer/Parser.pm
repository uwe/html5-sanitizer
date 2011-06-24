package HTML5::Sanitizer::Parser;
# ABSTRACT: parse HTML into DOM tree

use Moose;

use XML::LibXML;


has parser => (is => 'ro', lazy_build => 1);

has parser_options     => (is => 'ro', isa => 'HashRef', lazy_build => 1);
has parse_html_options => (is => 'ro', isa => 'HashRef', lazy_build => 1);


sub _build_parser {
    my ($self) = @_;

    return XML::LibXML->new($self->parser_options);
}

sub _build_parser_options {
    return {
        encoding          => 'UTF-8',
        recover           => 2,
        keep_blanks       => 1,
        no_cdata          => 1,
        expand_entities   => 1,
        no_network        => 1,
        suppress_errors   => 1,
        suppress_warnings => 1,
    };
}

sub _build_parse_html_options {
    return {
        no_cdata          => 1,
        suppress_errors   => 1,
        suppress_warnings => 1,
    };
}


sub process {
    my ($self, $input) = @_;

    return $self->parser->parse_html_string(
        '<body>' . $input,
        $self->parse_html_options,
    );
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 DESCRIPTION

Parses a HTML string into a L<XML::LibXML> document.

=head1 METHODS

=head2 new

Constructor. You may pass in C<parser_options> and C<parse_html_options>.
Both are hashrefs. The first one is used for C<< XML::LibXML->new >>, the
latter for C<< $parser->parse_html_string >>.

=head2 process

Given a HTML string it returns a L<XML::LibXML> document.

=cut
