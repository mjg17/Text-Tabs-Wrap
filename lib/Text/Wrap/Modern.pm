package Text::Wrap::Modern;

use warnings::register;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(wrap fill);
@EXPORT_OK = qw($columns $break $huge);

$VERSION = 2015.0618;
$SUBVERSION = 'modern';

use 5.010_000;

use vars qw($VERSION $SUBVERSION $columns $debug $break $huge $unexpand $tabstop $separator $separator2);
use strict;

BEGIN	{
	$columns = 76;  # <= screen width
	$debug = 0;
	$break = '(?=\s)\X';
	$huge = 'wrap'; # alternatively: 'die' or 'overflow'
	$unexpand = 1;
	$tabstop = 8;
	$separator = "\n";
	$separator2 = undef;
}

my $CHUNK = qr/\X/;

sub _xlen(_) { scalar(() = $_[0] =~ /$CHUNK/g) }

sub _xpos(_) { _xlen( substr( $_[0], 0, pos($_[0]) ) ) }

use Text::Tabs qw(expand unexpand);

sub wrap
{
	my ($ip, $xp, @t) = @_;

	local($Text::Tabs::tabstop) = $tabstop;
	my $r = "";
	my $tail = pop(@t);
	my $t = expand(join("", (map { /\s+\z/ ? ( $_ ) : ($_, ' ') } @t), $tail));
	my $lead = $ip;
	my $nll = $columns - _xlen(expand($xp)) - 1;
	if ($nll <= 0 && $xp ne '') {
		my $nc = _xlen(expand($xp)) + 2;
		warnings::warnif "Increasing \$Text::Wrap::columns from $columns to $nc to accommodate length of subsequent tab";
		$columns = $nc;
		$nll = 1;
	}
	my $ll = $columns - _xlen(expand($ip)) - 1;
	$ll = 0 if $ll < 0;
	my $nl = "";
	my $remainder = "";

	use re 'taint';

	pos($t) = 0;
	while ($t !~ /\G(?:$break)*\Z/gc) {
		if ($t =~ /\G((?:(?=[^\n])\X){0,$ll})($break|\n+|\z)/xmgc) {
			$r .= $unexpand 
				? unexpand($nl . $lead . $1)
				: $nl . $lead . $1;
			$remainder = $2;
		} elsif ($huge eq 'wrap' && $t =~ /\G((?:(?=[^\n])\X){$ll})/gc) {
			$r .= $unexpand 
				? unexpand($nl . $lead . $1)
				: $nl . $lead . $1;
			$remainder = defined($separator2) ? $separator2 : $separator;
		} elsif ($huge eq 'overflow' && $t =~ /\G((?:(?=[^\n])\X)*?)($break|\n+|\z)/xmgc) {
			$r .= $unexpand 
				? unexpand($nl . $lead . $1)
				: $nl . $lead . $1;
			$remainder = $2;
		} elsif ($huge eq 'die') {
			die "couldn't wrap '$t'";
		} elsif ($columns < 2) {
			warnings::warnif "Increasing \$Text::Wrap::columns from $columns to 2";
			$columns = 2;
			return ($ip, $xp, @t);
		} else {
			die "This shouldn't happen";
		}
			
		$lead = $xp;
		$ll = $nll;
		$nl = defined($separator2)
			? ($remainder eq "\n"
				? "\n"
				: $separator2)
			: $separator;
	}
	$r .= $remainder;

	print "-----------$r---------\n" if $debug;

	print "Finish up with '$lead'\n" if $debug;

	my($opos) = pos($t);

	$r .= $lead . substr($t, pos($t), length($t) - pos($t))
		if pos($t) ne length($t);

	print "-----------$r---------\n" if $debug;;

	return $r;
}

sub fill 
{
	my ($ip, $xp, @raw) = @_;
	my @para;
	my $pp;

	for $pp (split(/\n\s+/, join("\n",@raw))) {
		$pp =~ s/\s+/ /g;
		my $x = wrap($ip, $xp, $pp);
		push(@para, $x);
	}

	# if paragraph_indent is the same as line_indent, 
	# separate paragraphs with blank lines

	my $ps = ($ip eq $xp) ? "\n\n" : "\n";
	return join ($ps, @para);
}

1;
__END__

=head1 NAME

Text::Wrap::Modern - implementation of Text::Wrap for perls from
version 5.10 onwards.

See L<Text::Wrap> for full documentation.

=head1 UNICODE

Unlike the old Unix fmt(1) utility, this module correctly accounts for
any Unicode combining characters (such as diacriticals) that may occur
in each line for both expansion and unexpansion.  These are overstrike
characters that do not increment the logical position.  Make sure
you have the appropriate Unicode settings enabled.

=head1 SEE ALSO

For correct handling of East Asian half- and full-width characters, 
see L<Text::WrapI18N>.
For more detailed controls: L<Text::Format>.

=head1 AUTHOR

David Muir Sharnoff <cpan@dave.sharnoff.org> with help from Tim Pierce and
many many others.  

=head1 LICENSE

Copyright (C) 1996-2009 David Muir Sharnoff.  
Copyright (C) 2012-2013 Google, Inc.
This module may be modified, used, copied, and redistributed at your own risk.
Although allowed by the preceding license, please do not publicly
redistribute modified versions of this code with the name "Text::Wrap"
unless it passes the unmodified Text::Wrap test suite.
