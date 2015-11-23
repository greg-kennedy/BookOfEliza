#!/usr/bin/perl
use v5.10;

use Point;
use Region;

$a = new Point(0,1);
$b = new Point(1,0);

say "Distance: " . $b->dist($a);

$poly = new Region({Name=>'foo', Polygons=>[ [
  new Point(0,0),
  new Point(1,1),
  new Point(2,0),
  new Point(1,-1)
]]});

say "check contains A: " . $poly->contains($a);
say "check contains B: " . $poly->contains($b);
