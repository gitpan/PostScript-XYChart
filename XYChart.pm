package PostScript::XYChart;
use strict;
use warnings;
use PostScript::File 0.04 qw(check_file array_as_string);
use PostScript::GraphPaper;
use PostScript::GraphStyle;
use PostScript::GraphKey;

our $VERSION = "0.01";

=head1 NAME

PostScript::XYChart - graph lines and points

=head1 SYNOPSIS

    use PostScript::XYChart;

    # Draw a graph from data in the CSV file 
    # 'results.csv', and saves it as 'results.ps'
    
    my $xy = new PostScript::XYChart();
    $xy->line_from_file( "results.csv", "Results" );
    $xy->build_chart();
    $xy->output("results");

     
     
    # Or with more direct control

    use PostScript::XYChart;
    use PostScript::GraphStyle qw(defaults);

    $PostScript::GraphStyle::defaults{gray} =
	[ [ 1, 1, 0 ],	    # yellow
	  [ 0, 1, 0 ],	    # green
	  [ 0, 1, 1 ], ];   # cyan
	
    my $xy = new PostScript::XYChart(
	    file  => {
		errors    => 1,
		eps       => 0,
		landscape => 1,
		paper     => 'Letter',
	    },
	    chart => {
		dots_per_inch => 72,
		heading       => "Example",
		background    => [ 0.9, 0.9, 1 ],
		heavy_color   => [ 0, 0.2, 0.8 ],
		mid_color     => [ 0, 0.5, 1 ],
		light_color   => [ 0.7, 0.8, 1 ],
	    },
	    x_axis => {
		smallest => 4,
		title    => "Control variable",
		font     => "Courier",
	    },
	    y_axis => {
		smallest => 3,
		title    => "Dependent variable",
		font     => "Courier",
	    },
	    style  => {
		auto  => [qw(gray dashes)],
		color => 0,
		line  => {
		    inner_width  => 2,
		    outer_width  => 2.5,
		    outer_dashes => [],
		},
		point => {
		    shape => "circle",
		    size  => 8,
		    color => [ 1, 0, 0 ],
		},
	    },
	    key    => {
		    background => 0.9,
	    },
	);

    $xy->line_from_array(
	[ [ qw(Control First Second Third Fourth),
	    qw(Fifth Sixth Seventh Eighth Nineth)],
	  [ 1, 0, 1, 2, 3, 4, 5, 6, 7, 8 ],
	  [ 2, 1, 2, 3, 4, 5, 6, 7, 8, 9 ],
	  [ 3, 2, 3, 4, 5, 6, 7, 8, 9,10 ],
	  [ 4, 3, 4, 5, 6, 7, 8, 9,10,11 ], ]
	);
    $xy->build_chart();
    $xy->output("controlled");
   
=head1 DESCRIPTION

A graph is drawn on a PostScript file from one or more sets of numeric data.  Scales are automatically adjusted
for each data set and the style of lines and points varies between them.  A title, axis labels and a key are also
provided.

=head1 CONSTRUCTOR

=head2 new( [options] )

C<options> may be either a list of hash keys and values or a hash reference.  Either way, the hash should have the
same structure - made up of keys to several sub-hashes.

    $xy = new PostScript::XYChart(
		file   => {
		    # for PostScript::File
		    eps => 1,
		},
		chart  => {
		    # for PostScript::GraphPaper
		    title => "My Graph",
		},
		x_axis => {
		    # for PostScript::GraphPaper
		    font => "Courier",
		},
		y_axis => {
		    # for PostScript::GraphPaper
		    rotate => 1,
		},
		style  => {
		    # for PostScript::GraphStyle
		    color => 1,
		},
		key    => {
		    # for PostScript::GraphKey
		    num_items => 5,
		},
	    );

All the settings are optional and the defaults work reasonably well.  For convenience, the full tree of over 140
options is given below.  See the relevant manpage for full details.  The most useful ones are marked with (*).

=head3 From PostScript::File

    file
	debug
	errors *
	headings
	reencode

	bottom
	clip_command
	clipping
	dir
	eps *
	file
	font_suffix
	height
	landscape *
	left
	paper *
	right
	top
	width
	
	db_active
	db_base
	db_bufsize
	db_color
	db_font
	db_fontsize
	db_xgap
	db_xpos
	db_xtab
	db_ytop

	incpage_handler
	page
	strip

=head3 From PostScript::GraphPaper

    chart
	background
	bottom_edge
	color *
	dots_per_inch
	font
	font_color
	font_size
	heading
	heading_font
	heading_font_color
	heading_font_size
	heading_height
	heavy_color
	heavy_width
	key_width
	left_edge
	light_color
	light_width
	mid_color
	mid_width
	right_edge
	right_margin
	spacing
	top_edge
	top_margin

    x_axis
	center
	font
	font_color
	font_size
	height
	high
	label_gap
	labels
	labels_req
	low
	mark_min
	mark_max
	rotate
	smallest *
	title
	width

    y_axis
	(same as x_axis)

=head3 From PostScript::GraphStyle

    style
	auto *
	color *
	same *

	line
	    color
	    dashes
	    inner_color
	    inner_dashes
	    inner_width
	    outer_color
	    outer_dashes
	    outer_width
	    width
	
	point
	    color
	    inner_color
	    inner_width
	    outer_color
	    outer_width
	    shape
	    size
	    width
		
	bar
	    color
	    inner_color
	    inner_width
	    outer_color
	    outer_width
	    width
	
=head3 From PostScript::GraphKey

    key
	file
	background
	graph_paper
	horizontal_spacing
	icon_height
	icon_width
	max_height
	num_items
	outline_color
	outline_width
	spacing *
	text_color
	text_font
	text_size
	text_width
	title
	title_color
	title_font
	title_size
	vertical_spacing

=cut

sub new {
    my $class = shift;
    my $opt = {};
    if (@_ == 1) {
	$opt = $_[0];
    } else {
	%$opt = @_;
    }
   
    my $o = {};
    bless( $o, $class );
    $o->{opt} = $opt;
    $o->{opt}{x_axis} = {} unless (defined $o->{opt}{x_axis});
    $o->{opt}{y_axis} = {} unless (defined $o->{opt}{y_axis});

    return $o;
}

=head1 OBJECT METHODS

=head2 line_from_array( data [, label|opts|style ]... )

=over 4

=item C<data>

An array reference pointing to a list of positions.  

=item C<label>

A string to represent this line in the Key.

=item C<opts>

This should be a hash reference containing keys and values suitable for a PostScript::GraphStyle object.  If present,
the object is created with the options specified.

=item C<style>

It is also acceptable to create a PostScript::GraphStyle object independently and pass that in here.

=back

One or more lines of data is added to the chart.  This may be called many times before the chart is finalized with
B<build_chart>.
      
Each position is the data array contains an x value and one or more y values.  For example, the following points
will be plotted on an x axis from 2 to 4 a y axis including from 49 to 57.

    [ [ 2, 49.7 ],
      [ 3, 53.4 ],
      [ 4. 56.1 ], ]

This will plot three lines with 6 points each.  

    [ ["X", "Y", "Yb", "Yc"],
      [x0, y0, yb0, yc0],
      [x1, y1, yb1, yc1],
      [x2, y2, yb2, yc2],
      [x3, y3, yb3, yc3],
      [x4, y4, yb4, yc4],
      [x5, y5, yb5, yc5], ]

The first line is made up of (x0,y0), (x1,y1)... and these must be there.  The second line comes from (x0,yb0),
(x1,yp1)... and so on.  Optionally, the first row of data in the array may be labels for the X and Y axis, and
then for each line.

Where multiple lines are given, it is best to specify C<label> as an option.  Otherwise it will default to the
name of the first line - rarely what you want.  Of course this is ignored if the B<new> option 'y_axis => title'
was given.

=cut

sub line_from_array {
    my $o = shift;
    my ($data, $style, $opts, $label);
    foreach my $arg (@_) {
	$_ = ref($arg);
	CASE: {
	    if (/ARRAY/)                  { $data  = $arg; last CASE; }
	    if (/HASH/)                   { $opts  = $arg; last CASE; }
	    if (/PostScript::GraphStyle/) { $style = $arg; last CASE; }
	    $label = $arg;
	}
    }
    die "add_line() requires an array\nStopped" unless (defined $data);
    $opts = $o->{opt}{style}                    unless (defined $opts);
    $style = new PostScript::GraphStyle($opts)  unless (defined $style); 
    $o->{ylabel} = $label                       unless (defined $o->{ylabel});
    
    my $name = $o->{default}++;
    my ($first, @rest) = split_data($data);
    foreach my $column (@rest) {
	$o->line_from_array($column);
    }
    
    $o->{line}{$name}{xtitle} = "";
    my $line = $o->{line}{$name};
    $line->{ytitle} = $label || "";
    $line->{style} = $style;
    
    unless ($first->[0][1] =~ /^[\d.-]/) {
	my $row = shift(@$first);
	$line->{xtitle} = $$row[0];
	$line->{ytitle} = $$row[1];
    }
    $o->{ylabel} = $line->{ytitle} unless (defined $o->{ylabel});
    
    my @coords;
    my ($xmin, $ymin, $xmax, $ymax);
    foreach my $row (@$first) {
	my ($x, $y) = @$row;
	if ($x =~ /^[\d.-]/) {
	    $xmin = $x if (not defined($xmin) or $x < $xmin);
	    $xmax = $x if (not defined($xmax) or $x > $xmax);
	}
	if ($y =~ /^[\d.-]/) {
	    $ymin = $y if (not defined($ymin) or $y < $ymin);
	    $ymax = $y if (not defined($ymax) or $y > $ymax);
	}
    }
    $line->{data} = $first;
    $line->{last} = 2 * ($#$first + 1) - 1;
    $line->{xmin} = $xmin;
    $line->{xmax} = $xmax;
    $line->{ymin} = $ymin;
    $line->{ymax} = $ymax;
}

# Internal function
# Splits array data of the form 
# [ [x1, a1, b1, c1],
#   [x2, a2, b2, c2], ]
# to an array holding several arrays of (x,y) points
# [ [ [x1, a1], [x2, a2] ],
#   [ [x1, b1], [x2, b2] ],
#   [ [x1, c1], [x2, c2] ], ]
#
sub split_data {
    my $data = shift;
    return ([[0, 0]]) unless (ref($data) eq "ARRAY");
    my @res;
    foreach my $row (@$data) {
	if (ref($row) eq "ARRAY") {
	    my ($x, @rest) = @$row;
	    for (my $i = 0; $i <= $#rest; $i++) {
		$res[$i] = [] unless (defined $res[$i]);
		push @{$res[$i]}, [ $x, $rest[$i] ];
	    }
	}
    }
    return @res;
}

=head2 line_from_file( file [, label|opts|style ]... )

=over 4

=item C<file>

The name of a CSV file.

=item C<label>

A string to represent this line in the Key.

=item C<opts>

This should be a hash reference containing keys and values suitable for a PostScript::GraphStyle object.  If present,
the object is created with the options specified.

=item C<style>

It is also acceptable to create a PostScript::GraphStyle object independently and pass that in here.

=back

The comma seperated file should contain data in the form:

    x0, y0
    x1, y1
    x2, y2

Optionally, the first line may hold labels.  Any additional columns are interpreted as y-values for additional
lines.  For example:

    Volts, R1k2, R1k8, R2k2
    4.0,   3.33, 2.22, 1.81
    4.5,   3.75, 2.50, 2.04
    5.0,   4.16, 2.78, 2.27
    5.5,   4.58, 3.05, 2.50

Where multiple lines are given, it is best to specify C<label> as an option.  Otherwise it will default to the
name of the first line - rarely what you want.  Of course the B<new> option 'y_axis => title' takes precedence
over both.

Note that the headings have to begin with a non-digit in order to be recognized as such.

=cut

sub line_from_file {
    my ($o, $file, $style) = @_;
    my $filename = check_file($file);
    my @data;
    open(INFILE, "<", $filename) or die "Unable to open \'$filename\': $!\nStopped";
    while (<INFILE>) {
	chomp;
	my @row = split /\s*,\s*/;
	push @data, [ @row ] if (@row);
    }
    close INFILE;

    $o->line_from_array( \@data, $style );
}

=head2 build_chart()

The main method.  It calculates the scales from the data collected, draws the graph paper, puts the lines on it
and adds a key.

=cut

sub build_chart {
    my ($o) = @_;
    my $oo  = $o->{opt};

    my ($first, @rest) = sort keys( %{$o->{line}} );
    $oo->{x_axis} = {} unless (defined $oo->{x_axis});
    my $ox        = $o->{opt}{x_axis};
    $oo->{y_axis} = {} unless (defined $oo->{y_axis});
    my $oy        = $o->{opt}{y_axis};
    
    # Examine all lines for extent of x & y axes and label lengths
    my ($xmin, $ymin, $xmax, $ymax, $xtitle, $ytitle);
    my $maxlen  = 0;
    my $lines   = 0;
    my $lwidth  = 3;
    my $maxsize = 0;
    foreach my $name ($first, @rest) {
	my $line     = $o->{line}{$name};
	my $style    = $line->{style};
	my $lw       = $style->line_outer_width();
	my $size     = $style->point_size() + $lwidth;
	$maxsize     = $size if ($size > $maxsize);
	$lwidth      = $lw/2 if ($lw/2 > $lwidth);
	$xmin        = $line->{xmin} if (not defined($xmin) or $line->{xmin} < $xmin);
	$xmax        = $line->{xmax} if (not defined($xmax) or $line->{xmax} > $xmax);
	$ymin        = $line->{ymin} if (not defined($ymin) or $line->{ymin} < $ymin);
	$ymax        = $line->{ymax} if (not defined($ymax) or $line->{ymax} > $ymax);
	$ox->{title} = $line->{xtitle} unless (defined $ox->{title});
	$oy->{title} = $o->{ylabel} unless (defined $oy->{title});
	my $len      = length($line->{ytitle});
	$maxlen      = $len if ($len > $maxlen);
	$lines++;
    }
    $ox->{low}  = $xmin;
    $ox->{high} = $xmax;
    $oy->{low}  = $ymin;
    $oy->{high} = $ymax;
   
    # Ensure PostScript::File exists
    $oo->{file}   = {} unless (defined $oo->{file});
    my $of        = $o->{opt}{file};
    $of->{left}   = 36 unless (defined $of->{left});
    $of->{right}  = 36 unless (defined $of->{right});
    $of->{top}    = 36 unless (defined $of->{top});
    $of->{bottom} = 36 unless (defined $of->{bottom});
    $of->{errors} = 1 unless (defined $of->{errors});
    $o->{ps}      = (ref($of) eq "PostScript::File") ? $of : new PostScript::File( $of );

    # same calculations as for height of GraphPaper y axis
    # used as max_height for GraphKey
    $oo->{chart} = {} unless (defined $oo->{chart});
    my $oc       = $o->{opt}{chart};
    my @bbox     = $o->{ps}->get_page_bounding_box();
    my $bottom   = defined($oc->{bottom_edge})  ? $oc->{bottom_edge}  : $bbox[1]+1;
    my $top      = defined($oc->{top_edge})     ? $oc->{top_edge}     : $bbox[3]-1;
    my $spc      = defined($oc->{spacing})      ? $oc->{spacing}      : 0;
    my $height   = $top - $bottom - 2 * $spc;

    # Ensure max_height and num_lines are set for GraphKey
    $oo->{key} = {} unless (defined $oo->{key});
    my $ok     = $o->{opt}{key};
    if (defined $ok->{max_height}) {
	$ok->{max_height} = $height if ($ok->{max_height} > $height);
    } else {
	$ok->{max_height} = $height; 
    }
    $ok->{num_items}   = $lines;
    my $tsize          = defined($ok->{text_size}) ? $ok->{text_size} : 10;
    $ok->{text_width}  = $maxlen * $tsize * 0.7;
    $ok->{icon_width}  = $maxsize * 3;
    $ok->{icon_height} = $maxsize * 1.5;
    $ok->{spacing}     = $lwidth;
    $o->{gk}           = new PostScript::GraphKey( $ok );
    
    # Create GraphPaper now key width is known
    $oo->{file}      = $o->{ps};
    $oc->{key_width} = $o->{gk}->width();
    $o->{gp}         = new PostScript::GraphPaper( $oo );

    # Add in lines and key details
    $o->ps_functions();
    $o->{gk}->build_key( $o->{gp} );
    $o->{ps}->add_to_page( "gpaperdict begin\nxychartdict begin\n" );
    my $linenum = 1;
    foreach my $name ($first, @rest) {
	my $line = $o->{line}{$name};
	my $points = "";
	foreach my $row (@{$line->{data}}) {
	    my ($x, $y) = @$row;
	    my $px = $o->{gp}->px($x);
	    my $py = $o->{gp}->py($y);
	    $points = "$px $py " . $points;
	}
	my $style = $line->{style};
	$style->ps_functions( $o->{ps}, "xychartdict", 0 );
	$style->background( $o->{gp}->chart_background() );
	$style->set( $o->{ps} );
	$o->{ps}->add_to_page( "[ $points ] $line->{last} xyline\n" );
	$o->{gk}->add_key_item( $line->{ytitle}, <<END_KEY_ITEM );
	    
	    2 dict begin
		/kpx kix0 kix1 add 2 div def
		/kpy kiy0 kiy1 add 2 div def
		point_outer kpx kpy draw1point
		[ kix0 kiy0 kix1 kiy1 ] 3 2 copy line_outer drawxyline line_inner drawxyline
		point_inner kpx kpy draw1point
	    end
	    
END_KEY_ITEM
    }
    $o->{ps}->add_to_page( "end end\n" );
}

# Internal method, called by build_chart
#
sub ps_functions {
    my ($o) = @_;
    my $name = "XYChart";
    # dict entries: style fns=7, style code=19, here=6
    $o->{ps}->add_function( $name, <<END_FUNCTIONS ) unless ($o->{ps}->has_function($name));
	/xychartdict 35 dict def
	xychartdict begin
	    % _ coords_array last => _
	    /drawxyline {
		xychartdict begin
		    /idx exch def
		    /linearray exch def
		    /y linearray idx get def
		    /idx idx 1 sub def
		    /x linearray idx get def
		    /idx idx 1 sub def
		    newpath
		    x y moveto
		    {
			idx 0 le { exit } if
			/y linearray idx get def
			/idx idx 1 sub def
			/x linearray idx get def
			/idx idx 1 sub def
			x y lineto
		    } loop
		    stroke
		end
	    } bind def
	    
	    % x y => 0
	    % ppshape should be one of the make_ Style functions
	    /draw1point {
		xychartdict begin
		    gsave
			ppshape
			gsave stroke grestore
			eofill
		    grestore
		end
	    } bind def
	    
	    % _ coords_array last => _
	    /drawxypoints {
		xychartdict begin
		    /idx exch def
		    /linearray exch def
		    /y linearray idx get def
		    /idx idx 1 sub def
		    /x linearray idx get def
		    /idx idx 1 sub def
		    x y draw1point
		    {
			idx 0 le { exit } if
			/y linearray idx get def
			/idx idx 1 sub def
			/x linearray idx get def
			/idx idx 1 sub def
			x y draw1point
		    } loop
		end
	    } bind def
	    
	    % _ coords_array last => _
	    /xyline {
		xychartdict begin
		    2 copy point_outer drawxypoints
		    2 copy line_outer drawxyline
		    2 copy line_inner drawxyline
		    point_inner drawxypoints
		end
	    } bind def
	    
	end
END_FUNCTIONS
}

=head1 SUPPORTING METHODS

=head2 add_function( name, code )

Add functions to the underlying PostScript::File object.  See L<PostScript::File/add_function> for details.

=head2 add_to_page( [page], code )

Add postscript code to the underlying PostScript::File object.  See L<PostScript::File/add_to_page> for details.

=head2 file

Return the underlying PostScript::File object.

=head2 graph_key

Return the underlying PostScript::GraphKey object.  Only available after a call to B<build_chart>.

=head2 graph_paper

Return the underlying PostScript::GraphPaper object.  Only available after a call to B<build_chart>.

=head2 newpage( [page] )

Start a new page in the underlying PostScript::File object.  See L<PostScript::File/newpage> and
L<PostScript::File/set_page_label>.

=head2 output( file [, dir] )

Output the chart as a file.  See L<PostScript::File/output>.

=cut

sub file { return shift()->{ps}; }
sub graph_key { return shift()->{gk}; }
sub graph_paper { return shift()->{gp}; }

sub output { my $o = shift; $o->{ps}->output(@_); }
sub newpage { my $o = shift; $o->{ps}->newpage(@_); }
sub add_function { my $o = shift; $o->{ps}->add_function(@_); }
sub add_to_page { my $o = shift; $o->{ps}->add_to_page(@_); }

1;

