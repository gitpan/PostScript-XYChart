#!/usr/bin/perl
use strict;
use warnings;
use PostScript::XYChart;

my $xy = new PostScript::XYChart(
	    file  => {
		landscape => 1,
		errors => 1,
		debug => 2,
	    },
	    chart => {
		left_edge => 80,
		background => [1, 1, 0.9],
		key_width => 72,
	    },
	    x_axis => {
		smallest => 8,
	    },
	    y_axis => {
		smallest => 8,
	    },
	);

my $data = [ [ "First", "Second", "Third" ],
	     [ 1, 2, 8 ],
	     [ 2, 4, 6.2 ],
	     [ 3, 5, 3.9 ],
	     [ 4, 7, 1.2 ], 
	     [ 5, 9, -0.4 ],
	     [ 7, 13, -2.25], ];

$xy->line_from_array( $data, {
	line => { 
	    outer_color => 1,
	    inner_color => [ 0.5, 1, 1 ],
	    outer_width => 5,
	    inner_width => 2,
	    inner_dashes => [ 2, 5, 10, 5 ],
	    outer_dashes => [ 2, 5, 10, 5 ],
	},
	point => {
	    shape => "square",
	    outer_color => 0,
	    inner_color => [ 0.4, 0.8, 0.8 ],
	    outer_width => 3,
	    inner_width => 1,
	    size => 8,
	},
    } );

$data = [ [ "One", "Two" ],
	  [ -0.38, 0.97 ],
	  [ 1.2, 2.99 ],
	  [ 1.4, 5.34 ],
	  [ 2.3, 5.6 ],
	  [ 6.7, 9.1 ],
	  [ 7.4, 12.3 ] ];

$xy->line_from_array( $data, {
	line => { 
	    inner_dashes => [ 10 ],
	},
	point => {
	    shape => "diamond",
	    inner_color => [ 1, 0.5, 0.2 ],
	    outer_width => 5,
	    size => 8,
	},
    } );
    
$xy->build_chart();
$xy->output("12xychart");

