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
