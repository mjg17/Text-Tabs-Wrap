package Text::Tabs;

use strict;
use warnings;

my $flavour;
our @ISA;

BEGIN {
    my @to_alias = qw(
        &expand &unexpand
        $VERSION $SUBVERSION $tabstop $debug
    );

    require Exporter;
    @ISA = qw(Exporter);

    my $base = __PACKAGE__;

    $flavour = ($] >= 5.010) ? "${base}::Modern" : "${base}::Old";

    # Aliasing ensures that fully-qualified usage works...
    my $alias_code = "use $flavour;\n";
    foreach my $what (@to_alias) {
        my ($sigil, $name) = $what =~ /^(.)(.+)$/;
        $sigil = '*' if $sigil eq '$'; # required to allow 'local' to work on aliased package variables

        # Example:      *Text::Foo::bar   = \&Text::Foo::Modern::bar;
        $alias_code .= "*${base}::${name} = \\${sigil}${flavour}::${name};\n";
    }

    eval $alias_code;
}

sub import {
    # ...and this ensures that import requests are handled by the correct flavour
    $flavour->export_to_level(1, @_);
    return;
}

1;
__END__

=head1 NAME

Text::Tabs - expand and unexpand tabs like unix expand(1) and unexpand(1)

=head1 SYNOPSIS

  use Text::Tabs;

  $tabstop = 4;  # default = 8
  @lines_without_tabs = expand(@lines_with_tabs);
  @lines_with_tabs = unexpand(@lines_without_tabs);

=head1 DESCRIPTION

Text::Tabs does most of what the unix utilities expand(1) and unexpand(1) 
do.  Given a line with tabs in it, C<expand> replaces those tabs with
the appropriate number of spaces.  Given a line with or without tabs in
it, C<unexpand> adds tabs when it can save bytes by doing so, 
like the C<unexpand -a> command.  

See L<Text::Tabs::Modern/UNICODE> for details of Unicode handling when
using this module with perl version 5.10 or later.

=head1 EXPORTS

The following are exported:

=over 4

=item expand

=item unexpand

=item $tabstop

The C<$tabstop> variable controls how many column positions apart each
tabstop is.  The default is 8.

Please note that C<local($tabstop)> doesn't do the right thing and if you want
to use C<local> to override C<$tabstop>, you need to use
C<local($Text::Tabs::tabstop)>.

=back

=head1 EXAMPLE

  #!perl
  # unexpand -a
  use Text::Tabs;

  while (<>) {
    print unexpand $_;
  }

Instead of the shell's C<expand> command, use:

  perl -MText::Tabs -n -e 'print expand $_'

Instead of the shell's C<unexpand -a> command, use:

  perl -MText::Tabs -n -e 'print unexpand $_'

=head1 SUBVERSION

This module comes in two flavors: one for modern perls (5.10 and above)
and one for ancient obsolete perls.  The version for modern perls has
support for Unicode.  The version for old perls does not.

You can tell which version you have installed by looking at
C<$Text::Tabs::SUBVERSION>: it is C<old> for obsolete perls and
C<modern> for current perls.

Documentation specific to a subversion can be found in
L<Text::Tabs::Modern> and L<Text::Tabs::Old>.

=head1 LICENSE

Copyright (C) 1996-2002,2005,2006 David Muir Sharnoff.  
Copyright (C) 2005 Aristotle Pagaltzis 
Copyright (C) 2012-2013 Google, Inc.
This module may be modified, used, copied, and redistributed at your own risk.
Although allowed by the preceding license, please do not publicly
redistribute modified versions of this code with the name "Text::Tabs"
unless it passes the unmodified Text::Tabs test suite.
