package Point;
use strict;
use warnings;

# A Point class

sub new
{
  my $class = shift;

  my $x = shift;
  my $y = shift;

  # Bless this class and return
  return bless { x => $x, y => $y }, $class;
}

# get y / x
sub x { my $self = shift; return $self->{x}; }
sub y { my $self = shift; return $self->{y}; }
sub dump { my $self = shift; return '(' . $self->x . ', ' . $self->y . ')'; }

# distance formula
sub dist {
  my ($self,$other) = @_;
  return sqrt(
    (($other->x - $self->x) ** 2) +
    (($other->y - $self->y) ** 2)
  );
}

1;
