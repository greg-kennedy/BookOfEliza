package MarkovChain;
use strict;
use warnings;

=pod

=head1 DESCRIPTION

This module encapsulate Markov Chains in a class.

=cut

# helper: Trim whitespace
sub _trim { my $str = shift; $str =~ s/^\s+//; $str =~ s/\s+$//; return $str; }
# helper: Normalize a string
sub _norm { my $str = uc(shift); $str =~ s/[^\w ]//; return _trim($str); }
# helper: Pick a random list entry.
sub _pick { return $_[int(rand(@_))]; }

# Create new Markov object
sub new
{
  my $class = shift;

  # empty object with defaults
  my %self = (
    order => 3,
    limit => 50,
    chains => {},
    beginnings => {}
  );

  if (@_) { $self{order} = shift; }
  if (@_) { $self{limit} = shift; }

  # Bless this class and return
  return bless \%self, $class;
}

# Tokenize a sentence and add it to the Markov chain hash
sub add
{
  my $self = shift;
  my @sentences = @_;

  foreach my $sentence(@sentences)
  {
    $sentence = _trim($sentence);

    my @words = split(/\s+/, $sentence);

    if (@words < $self->{order})
    {
      print STDERR "Cannot use sentence $sentence: too short!\n";
    } else {
      # Add this item to sentence beginnings array, if it does not exist.
      my $beginning = join(' ', @words[0 .. ($self->{order} - 1)]);
      # Normalize
      my $norm_beginning = _norm($beginning);

      if (!exists $self->{beginnings}->{$norm_beginning})
      {
        # Beginning does not already exist. Create it.
        $self->{beginnings}->{$norm_beginning} = {$beginning => 1};
      } else {
        # Prefix already exists.  Put this last word as an endpoint.
        $self->{beginnings}->{$norm_beginning}->{$beginning} = 1;
      }

      # Now iterate through all words, storing prefix and next-word.
      for (my $i = 0; $i < @words - $self->{order}; $i ++)
      {
        my $final_index = $i+$self->{order};

        # construct multi-word prefix
        my $prefix = _norm(join(' ', @words[$i .. ($final_index-1)]));
        # Retrieve final word
        my $last_word = $words[$final_index];

        # Add to chain.
        if (!exists $self->{chains}->{$prefix})
        {
          # Prefix does not already exist. Create it.
          $self->{chains}->{$prefix} = {$last_word => 1};
        } else {
          # Prefix already exists.  Put this last word as an endpoint.
          $self->{chains}->{$prefix}->{$last_word} = 1;
        }
      }
    }
  }
}

# Return the next link in a Markovchain
sub _link
{
  my $self = shift;

  my $prefix = _norm(shift);
  my $depth = shift;

  if (exists $self->{chains}->{$prefix} && $depth < $self->{limit})
  {
    # More are available!  Let's pick one at random.
    my $next_word = _pick(keys %{$self->{chains}->{$prefix}});

    # Advance prefix
    my $next_prefix = join(' ',
      (split(/\s+/, $prefix))[1 .. ($self->{order}-1)], $next_word
    );

    # Recurse
    return ' ' . $next_word . $self->_link($next_prefix,$depth+1);
  }

  # Chain ends.
  return '';
}

sub spew
{
  my $self = shift;

  # Pick a random beginning.
  my $norm_prefix = _pick(keys %{$self->{beginnings}});
  my $prefix = _pick(keys %{$self->{beginnings}->{$norm_prefix}});

  # Compose a sentence.
  return $prefix . $self->_link($prefix,0);
}

1;
