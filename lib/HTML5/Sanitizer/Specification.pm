package HTML5::Sanitizer::Specification;
# ABSTRACT: HTML 5 specification

use Moose;

my %ELEMENT_SPEC = (
# A
    a          => {content_model => 'transparent'},
    abbr       => {content_model => 'phrasing'},
    address    => {content_model => 'flow'},
    acronym    => {content_model => 'phrasing'},
    applet     => {content_model => 'transparent'},
    area       => {content_model => 'empty'},
    article    => {content_model => 'flow'},
    aside      => {content_model => 'flow'},
    audio      => {content_model => 'transparent'},
# B
    b          => {content_model => 'phrasing'},
    base       => {content_model => 'empty'},
    basefont   => {content_model => 'empty'},
    bdi        => {content_model => 'phrasing'},
    bdo        => {content_model => 'phrasing'},
    bgsound    => {content_model => 'empty'},
    big        => {content_model => 'phrasing'},
    blink      => {content_model => 'phrasing'},
    blockquote => {content_model => 'flow'},
    body       => {content_model => 'flow'},
    br         => {content_model => 'empty'},
    button     => {content_model => 'phrasing'},
# C
    canvas     => {content_model => 'transparent'},
    caption    => {content_model => 'flow'},
    center     => {content_model => 'flow'},
    cite       => {content_model => 'phrasing'},
    code       => {content_model => 'transparent'},
    col        => {content_model => 'empty'},
    colgroup   => {content_model => 'flow'},
    command    => {content_model => 'empty'},
    comment    => {content_model => 'transparent'},
# D
    datalist   => {content_model => 'phrasing'},
    dd         => {content_model => 'flow'},
    del        => {content_model => 'transparent'},
    details    => {content_model => 'flow'},
    device     => {content_model => 'empty'},
    dfn        => {content_model => 'phrasing'},
    dir        => {content_model => 'flow'},
    div        => {content_model => 'flow'},
    dl         => {content_model => 'flow'},
    dt         => {content_model => 'phrasing'},
# E
    em         => {content_model => 'phrasing'},
    embed      => {content_model => 'empty'},
# F
    fieldset   => {content_model => 'flow'},
    figcaption => {content_model => 'flow'},
    figure     => {content_model => 'flow'},
    font       => {content_model => 'phrasing'},
    footer     => {content_model => 'flow'},
    form       => {content_model => 'flow'},
    frame      => {content_model => 'empty'},
    frameset   => {content_model => 'flow'},
# H
    h1         => {content_model => 'flow'},
    h2         => {content_model => 'flow'},
    h3         => {content_model => 'flow'},
    h4         => {content_model => 'flow'},
    h5         => {content_model => 'flow'},
    h6         => {content_model => 'flow'},
    head       => {content_model => 'flow'},
    header     => {content_model => 'flow'},
    hgroup     => {content_model => 'flow'},
    hr         => {content_model => 'empty'},
    html       => {content_model => 'flow'},
# I
    i          => {content_model => 'phrasing'},
    iframe     => {content_model => 'transparent'},
    img        => {content_model => 'empty'},
    input      => {content_model => 'empty'},
    ins        => {content_model => 'transparent'},
    isindex    => {content_model => 'empty'},
# K
    kbd        => {content_model => 'phrasing'},
    keygen     => {content_model => 'empty'},
# L
    label      => {content_model => 'phrasing'},
    legend     => {content_model => 'phrasing'},
    li         => {content_model => 'flow'},
    link       => {content_model => 'empty'},
    listing    => {content_model => 'flow'},
# M
    map        => {content_model => 'transparent'},
    mark       => {content_model => 'phrasing'},
    marquee    => {content_model => 'phrasing'},
    menu       => {content_model => 'flow'},
    meta       => {content_model => 'empty'},
    meter      => {content_model => 'phrasing'},
    multicol   => {content_model => 'flow'},
# N
    nav        => {content_model => 'flow'},
    nextid     => {content_model => 'empty'},
    nobr       => {content_model => 'phrasing'},
    noembed    => {content_model => 'transparent'},
    noframes   => {content_model => 'transparent'},
    noscript   => {content_model => 'transparent'},
# O
    object     => {content_model => 'transparent'},
    ol         => {content_model => 'flow'},
    optgroup   => {content_model => 'phrasing'},
    option     => {content_model => 'phrasing'},
    output     => {content_model => 'phrasing'},
# P
    p          => {content_model => 'flow'},
    param      => {content_model => 'empty'},
    plaintext  => {content_model => 'phrasing'},
    pre        => {content_model => 'flow'},
    progress   => {content_model => 'phrasing'},
# Q
    q          => {content_model => 'phrasing'},
# R
    rb         => {content_model => 'phrasing'},
    rp         => {content_model => 'phrasing'},
    rt         => {content_model => 'phrasing'},
    ruby       => {content_model => 'phrasing'},
# S
    s          => {content_model => 'phrasing'},
    samp       => {content_model => 'phrasing'},
    script     => {content_model => 'phrasing'},
    section    => {content_model => 'flow'},
    select     => {content_model => 'phrasing'},
    small      => {content_model => 'phrasing'},
    source     => {content_model => 'empty'},
    spacer     => {content_model => 'empty'},
    span       => {content_model => 'phrasing'},
    strike     => {content_model => 'transparent'},
    strong     => {content_model => 'phrasing'},
    style      => {content_model => 'transparent'},
    sub        => {content_model => 'phrasing'},
    summary    => {content_model => 'phrasing'},
    sup        => {content_model => 'phrasing'},
    svg        => {content_model => 'transparent'},
# T
    table      => {content_model => 'flow'},
    tbody      => {content_model => 'flow'},
    td         => {content_model => 'flow'},
    textarea   => {content_model => 'phrasing'},
    tfoot      => {content_model => 'flow'},
    th         => {content_model => 'flow'},
    thead      => {content_model => 'flow'},
    time       => {content_model => 'phrasing'},
    title      => {content_model => 'phrasing'},
    tr         => {content_model => 'flow'},
    track      => {content_model => 'empty'},
    tt         => {content_model => 'phrasing'},
# U
    u          => {content_model => 'phrasing'},
    ul         => {content_model => 'flow'},
# V
    var        => {content_model => 'phrasing'},
    video      => {content_model => 'transparent'},
# W
    wbr        => {content_model => 'empty'},
# X
    xmp        => {content_model => 'phrasing'},
    xml        => {content_model => 'phrasing'},
);

sub elements      { keys %ELEMENT_SPEC }
sub content_model { $ELEMENT_SPEC{$_[1]}{content_model} }


no Moose;
__PACKAGE__->meta->make_immutable;

1;
