use ExtUtils::MakeMaker;

WriteMakefile(
    NAME		=> 'PostScript::XYChart',
    ABSTRACT_FROM	=> 'XYChart.pm',
    AUTHOR		=> 'Christopher Willmot <chris@willmot.org.uk>',
    VERSION_FROM	=> 'XYChart.pm',
    PREREQ_PM		=> {	PostScript::File       => 0.04,
				PostScript::GraphStyle => 0.01,
				PostScript::GraphPaper => 0.01,
				PostScript::GraphKey   => 0.01,
				},
);
