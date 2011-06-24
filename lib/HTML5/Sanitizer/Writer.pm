package HTML5::Sanitizer::Writer;
# ABSTRACT: transform DOM tree to HTML

use Moose;

use Carp qw/croak/;


has specification => (is => 'rw');


my %NODE_TYPE = (
    XML::LibXML::XML_ELEMENT_NODE => 'handle_element',
    XML::LibXML::XML_TEXT_NODE    => 'handle_text',
);


sub process {
    my ($self, $input_doc, $spec) = @_;

    my $root = $input_doc->documentElement or return '';

    $self->specification($spec);

    my $html = '';
    foreach my $node ($root->childNodes) {
        $html .= $self->write($node);
    }

    return $html;
}

sub write {
    my ($self, $node) = @_;

    my $method = $NODE_TYPE{$node->nodeType};
    unless ($method) {
        die sprintf("Unknown node type (%s): %s", $node->nodeType, $node->toStringC14N);
    }

    return $self->$method($node);
}

sub handle_element {
    my ($self, $node) = @_;

    my $tag = $node->nodeName;

    # start tag
    my $html = '<' . $tag;

    # attributes?
    if ($node->hasAttributes) {
        foreach my $attr ($node->attributes) {
            $html .= sprintf(' %s="%s"',
                $attr->nodeName,
                $attr->serializeContent || '',
            );
        }
    }

    $html .= '>';

    # no children allowed?
    my $cm = $self->specification->content_model($tag) || '';
    return $html if $cm eq 'empty';

    # children?
    foreach my $child ($node->childNodes) {
        $html .= $self->write($child);
    }

    # close tag
    $html .= '</' . $tag . '>';

    return $html;
}

sub handle_text {
    my ($self, $node) = @_;

    my $text = $node->data;

    # entities (& has to go first)
    # some additional escapes for security reasons
    $text =~ s/&/&amp;/g;
    $text =~ s/'/&#39;/g;
    $text =~ s/"/&quot;/g;
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;
    $text =~ s/`/&#96;/g;
    $text =~ s/{/&#123;/g;
    $text =~ s/}/&#125;/g;

    return $text;
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 DESCRIPTION

Convert a L<XML::LibXML> document into a HTML string.

=head1 METHODS

=head2 new

Constructor. Doesn't take any parameters.

=head2 process

Walks through the L<XML::LibXML> document (given as parameter) and writes HTML.

This class was mainly necessary for some additional escapes (and I could not
find a way to integrate this nicely in L<XML::LibXML>).

=cut
