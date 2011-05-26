package HTML5::Sanitizer::Converter;
# ABSTRACT: convert/sanitize DOM tree

use Moose;

use Carp qw/croak/;
use XML::LibXML;


has specification => (is => 'rw');
has profile       => (is => 'rw');
has document      => (is => 'rw');


my %NODE_TYPE = (
    XML::LibXML::XML_ELEMENT_NODE => 'handle_element',
    XML::LibXML::XML_TEXT_NODE    => 'handle_text',
);

my %CONTENT_MODEL = (
    flow        => {rename_tag => 'div'},
    phrasing    => {rename_tag => 'span'},
    transparent => {rename_tag => 'span'},
    empty       => {remove     => 1},
);


sub process {
    my ($self, $input_doc, $spec, $profile) = @_;

    # get body element
    my $root = $input_doc->documentElement
        or croak "No root element found";
    my $body = ($root->getChildrenByTagName('body'))[0]
        or croak "No body element found";

    my $doc = XML::LibXML->createDocument('1.0', 'UTF-8');

    # convert() needs some object variables, so set them first
    $self->specification($spec);
    $self->profile($profile);
    $self->document($doc);

    my @new_root = $self->convert($body, root => 1);
    if (@new_root == 0) {
        return $doc;
    } elsif (@new_root > 1) {
        die 'more than one root document';
    }

    $doc->setDocumentElement($new_root[0]);

    return $doc;
}

sub convert {
    my ($self, $old_node, %extra) = @_;

    # remove unknown node types completely
    my $method = $NODE_TYPE{$old_node->nodeType}
        or return;

    return $self->$method($old_node, %extra);
}

sub handle_element {
    my ($self, $old_node, %extra) = @_;

    my $tag = $old_node->nodeName;

    # get profile for this element
    my $profile = $self->profile->element($tag);

    unless ($profile) {
        # remove self closing tags (leaf nodes)
        return unless $old_node->hasChildNodes;

        # check specification for this element
        # - handle unknown elements like 'phrasing' (span)
        my $cm = $self->specification->content_model($tag) || 'phrasing';

        $profile = $CONTENT_MODEL{$cm} or croak "Unknown content model '$cm'";
    }

    # remove -> remove complete sub tree
    return if $profile->{remove};

    # create new element
    my $new_node = $self->document->createElement($profile->{rename_tag} || $tag);

    # process attributes
    $self->handle_element_attributes($old_node, $new_node, $profile);


    # process children
    $self->handle_element_children($old_node, $new_node, %extra);


    # optimize
    return $new_node if $extra{root};

    return $self->optimize($new_node);
}

sub handle_element_attributes {
    my ($self, $old_node, $new_node, $profile) = @_;

    my %attribute = ();

    # set_attributes
    if ($profile->{set_attributes}) {
        # just copy the values over
        %attribute = %{$profile->{set_attributes}};
    }

    # check_attributes
    if ($profile->{check_attributes}) {
        # check attributes before setting (= change value)
        while (my ($name, $check) = each %{$profile->{check_attributes}}) {
            my $method = '_check_' . $check;
            my $value  = $self->profile->$method($old_node->getAttribute($name));
            $attribute{$name} = $value if defined $value;
        }
    }

    # special handling of class attribute
    my @classes = ();

    # set_class
    if ($profile->{set_class}) {
        # unconditionally set class
        push @classes, $profile->{set_class};
    }

    # add_class
    if ($profile->{add_class}) {
        # add class from other attributes
        while (my ($name, $check) = each %{$profile->{add_class}}) {
            my $method = '_class_' . $check;
            my $value  = $self->profile->$method($old_node->getAttribute($name));
            push @classes, $value if $value;
        }
    }

    # add original classes last
    if (my $value = $old_node->getAttribute('class')) {
        push @classes, split(/\s+/, $value);
    }

    # remove unknown classes
    @classes = grep { $self->profile->classes->{$_} } @classes;

    # remove duplicated classes (last one survives)
    my %count = ();
    $count{$_}++ foreach (@classes);
    @classes = grep { $count{$_}-- == 1 } @classes;

    my $class = join ' ', @classes;
    $attribute{class} = $class if $class;

    # set attributes sorted
    foreach my $name (sort keys %attribute) {
        $new_node->setAttribute($name, $attribute{$name});
    }
}

sub handle_element_children {
    my ($self, $old_node, $new_node, %extra) = @_;

    delete $extra{root};

    foreach my $old_child ($old_node->childNodes) {
        my @children = $self->convert($old_child, %extra);
        $new_node->addChild($_) foreach (@children);
    }
}

sub optimize {
    my ($self, $node) = @_;

    # only <div> and <span>
    my $tag = $node->nodeName;
    return $node if $tag ne 'div' && $tag ne 'span';

    # only without attributes
    return $node if $node->hasAttributes;

    # no children -> remove completely
    return unless $node->hasChildNodes;

    my @children = $node->childNodes;
    return $node if scalar @children > 1;

    # one children
    my $cm = $self->specification->content_model($children[0]->nodeName) || '';
    if ($cm eq 'flow' && $tag eq 'div') {
        return $children[0];
    }
    elsif ($cm eq 'phrasing' && $tag eq 'span') {
        return $children[0];
    }
    elsif ($cm eq 'empty' && $tag eq 'span') {
        return $children[0];
    }

    return $node;
}


sub handle_text {
    my ($self, $old_node, %extra) = @_;

    return $self->document->createTextNode($old_node->data);
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
