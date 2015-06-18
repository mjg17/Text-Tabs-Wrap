package Text::Tabs::Modern;

require Exporter;

@ISA = (Exporter);
@EXPORT = qw(expand unexpand $tabstop);

use vars qw($VERSION $SUBVERSION $tabstop $debug);
$VERSION = 2015.0618;
$SUBVERSION = 'modern';

use strict;

use 5.010_000;

BEGIN	{
	$tabstop = 8;
	$debug = 0;
}

my $CHUNK = qr/\X/;

sub _xlen (_) { scalar(() = $_[0] =~ /$CHUNK/g) } 
sub _xpos (_) { _xlen( substr( $_[0], 0, pos($_[0]) ) ) }

sub expand {
	my @l;
	my $pad;
	for ( @_ ) {
		my $s = '';
		for (split(/^/m, $_, -1)) {
			my $offs = 0;
			s{\t}{
			    # this works on both 5.10 and 5.11
				$pad = $tabstop - (_xlen(${^PREMATCH}) + $offs) % $tabstop;
			    # this works on 5.11, but fails on 5.10
				#XXX# $pad = $tabstop - (_xpos() + $offs) % $tabstop;
				$offs += $pad - 1;
				" " x $pad;
			}peg;
			$s .= $_;
		}
		push(@l, $s);
	}
	return @l if wantarray;
	return $l[0];
}

sub unexpand
{
	my (@l) = @_;
	my @e;
	my $x;
	my $line;
	my @lines;
	my $lastbit;
	my $ts_as_space = " " x $tabstop;
	for $x (@l) {
		@lines = split("\n", $x, -1);
		for $line (@lines) {
			$line = expand($line);
			@e = split(/(${CHUNK}{$tabstop})/,$line,-1);
			$lastbit = pop(@e);
			$lastbit = '' 
				unless defined $lastbit;
			$lastbit = "\t"
				if $lastbit eq $ts_as_space;
			for $_ (@e) {
				if ($debug) {
					my $x = $_;
					$x =~ s/\t/^I\t/gs;
					print "sub on '$x'\n";
				}
				s/  +$/\t/;
			}
			$line = join('',@e, $lastbit);
		}
		$x = join("\n", @lines);
	}
	return @l if wantarray;
	return $l[0];
}

1;
__END__

sub expand
{
	my (@l) = @_;
	for $_ (@l) {
		1 while s/(^|\n)([^\t\n]*)(\t+)/
			$1. $2 . (" " x 
				($tabstop * length($3)
				- (length($2) % $tabstop)))
			/sex;
	}
	return @l if wantarray;
	return $l[0];
}


=head1 NAME

Text::Tabs::Modern - implementation of Text::Tabs for perls from
version 5.10 onwards.

See L<Text::Tabs> for full documentation.

=head1 UNICODE

Unlike the old unix utilities, this module correctly accounts for
any Unicode combining characters (such as diacriticals) that may occur
in each line for both expansion and unexpansion.  These are overstrike
characters that do not increment the logical position.  Make sure
you have the appropriate Unicode settings enabled.

=head1 BUGS

Text::Tabs handles only tabs (C<"\t">) and combining characters (C</\pM/>).  It doesn't
count backwards for backspaces (C<"\t">), omit other non-printing control characters (C</\pC/>),
or otherwise deal with any other zero-, half-, and full-width characters.

=head1 LICENSE

Copyright (C) 1996-2002,2005,2006 David Muir Sharnoff.  
Copyright (C) 2005 Aristotle Pagaltzis 
Copyright (C) 2012-2013 Google, Inc.
This module may be modified, used, copied, and redistributed at your own risk.
Although allowed by the preceding license, please do not publicly
redistribute modified versions of this code with the name "Text::Tabs"
unless it passes the unmodified Text::Tabs test suite.
