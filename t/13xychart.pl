#!/usr/bin/perl
use strict;
use warnings;
use PostScript::XYChart;

my $xy = new PostScript::XYChart(
	    file   => {
		landscape  => 1,
		errors     => 1,
		debug      => 2,
	    },
	    chart  => {
		left_edge  => 100,
		background => [1, 1, 0.9],
	    },
	    x_axis => {
		smallest   => 8,
	    },
	    y_axis => {
		smallest   => 4,
	    },
	    style  => {
		auto       => [qw(dashes green)],
		same       => 0,
		color      => 1,
		line       => {
		    width => 2,
		},
		shape      => {
		},
	    }
	);

my $data = [ [qw(Control First Second Third Fourth Fifth Sixth Seventh Eighth Nineth Tenth)],
	     [ 1, 1, 2, 3, 4, 5, 6, 7, 8, 9,10 ],
	     [ 2, 2, 3, 4, 5, 6, 7, 8, 9,10,11 ],
	     [ 3, 3, 4, 5, 6, 7, 8, 9,10,11,12 ],
	     [ 4, 4, 5, 6, 7, 8, 9,10,11,12,13 ], ];

$xy->line_from_array( $data );

$xy->build_chart();
$xy->output("13xychart");

