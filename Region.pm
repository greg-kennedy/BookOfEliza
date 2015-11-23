package Region;
use strict;
use warnings;

use Point;

# A Region class, holds a polygon, name, and link to
#  callback function

sub new
{
  my $class = shift;
  my %params = %{+shift};

  # Bless this class and return
  return bless \%params, $class;
}

# get region name
sub name { my $self = shift; return $self->{Name}; }
sub dump { my $self = shift; return 'Name: ' . $self->name . ', Polygons: ' . @{$self->{Polygons}}; }

# check if point is in region using winding
sub contains {
  my $self = shift;
  my $point = shift;

  foreach my $polygon_ref ( @{$self->{Polygons}} )
  {
    my @polygon = @{$polygon_ref};
    my $inPoly = 1;

    my $winding = 0;
    for (my $vertex = 0; $vertex < @polygon; $vertex++)
    {
      my $next_vertex = ($vertex + 1) % @polygon;
      # compute line segment
      my $direction = ($point->y - $polygon[$vertex]->y) * ($polygon[$next_vertex]->x - $polygon[$vertex]->x) -
        ($point->x - $polygon[$vertex]->x) * ($polygon[$next_vertex]->y - $polygon[$vertex]->y);

      #DEBUG
      #print STDERR "segment ", $polygon[$vertex]->dump, "-", $polygon[$next_vertex]->dump, " vs ",$polygon[$vertex]->dump,"-",$point->dump,": ",$direction," comp ",$winding,"\n";

      # point along polygon edge segment
      next if ($direction == 0);

      # initial direction unknown
      if ($winding == 0) { $winding = $direction; next; }
      # Mismatch in directions!
      if ($direction * $winding < 0) { $inPoly=0; last; }
    }
    return 1 if $inPoly;
  }

  return 0;
}

# action to perform
sub do { my $self = shift; $self->{Callback}->(@_); }

1;
