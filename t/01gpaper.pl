#!/usr/bin/perl 
use strict;
use warnings;
use PostScript::GraphPaper;

my $gp = new PostScript::GraphPaper(
	    file   => {
		debug => 2,
		errors => 1,
	    },
	    chart  => {
		heading  => "Bar chart",
		right_edge => 250,
		top_edge   => 500,
		key_width  => 100,
		key_height => 150,
	    },
	    x_axis => {
		labels => [ "First bar",
			    "Second bar",
			    "Third bar" ],
	    },
	    y_axis => {
		low    => 123,
		high   => 456.7,
		title  => "Readings",
	    },
	);

$gp->output("01gpaper");

__END__

my $ch = new PostScript::GraphPaper(
	ps_options => {
	    landscape => 1,
	    left => 40,
	    right => 40,
	    top => 30,
	    bottom => 30,
	    clipping => 1,
	    clipcmd => "stroke",
	    debug => 2,
	    errors => 1,
	    errx => 36,
	    erry => 300,
	},
	chart => {
	    key_width => 100,
	},
	x_axis => {
	    #height => 72,
	    #rotate => 1,
	    #center => 1,
	    labels => [qw(aaa bbb ccc ddd eee fff ggg hhh iii jjj)],
	},
	y_axis => {
	    #rotate => 0,
	    #center => 1,
	    labels => [qw(aaa bbb ccc ddd eee fff ggg hhh iii jjj)],
	},
    );


