#!/usr/bin/perl -w
use v5.10;
use strict;

################################
# THE BOOK OF ELIZA
#  an irreverent retelling of Exodus
################################

# classes
use Point;
use Region;

# psalms generator
use MarkovChain;

# Parameters
my $debug = 0;
my ($min_length, $max_length) = (50000, 55000);

# Globals - somewhat hacky, but ok
my ($novel,$chapter,$verse,$day);
my $kml;

################################
# HELPER FUNCTIONS
################################
# debug print if enabled
sub debug { if ($debug) { say STDERR join('', @_); } }
# chooses a random sentence from an array
sub pick { return $_[int(rand(@_))]; }
# event occurs with probability 0 to 1
sub chance { return rand(1) < $_[0]; }

# print a chapter header and reset verse to 1 again
sub c { $novel .= ("\n\n## Chapter " . ($chapter++) . "\n"); $verse = 1; }
# print a series of verses with superscript numbering scheme
sub v { $novel .= (join(' ', map{ '<sup>' . ($verse++) . '</sup>' . ucfirst($_); } @_) . ' '); }
# convert a number to ordinals (1st, 2nd, 3rd, 4th, ...)
sub ordinal {
  my $num = shift;
  my $digit = $num % 10;
  if ($digit > 3 || ($num > 3 && $num < 21)) { return $num . 'th'; }
  if ($digit == 3) { return $num . 'rd'; }
  if ($digit == 2) { return $num . 'nd'; }
  return $num . 'st';
}

################################
# STORY BITS
################################
# Points of Interest which trigger special story events
my %pois = (
    'Mount Sinai' => new Point(33.973333,28.539722),
    'Jerusalem' => new Point(35.7833,31.7833) # also, Mount Nebo
     );

# Other stops along the way
#  from https://en.wikipedia.org/wiki/Stations_of_the_Exodus
#  Some points are known, some are not, may just randomize a bunch later.
# Also, some events can just happen wherever (e.g. raining manna etc)
my %cities = (
    'Rameses' => new Point(31.821367,30.787419),
    'Sukkoth'=>new Point(32.098611,30.551954),
#'Etham'=>new Point(0,0),
#'Pi-Hahiroth'=>new Point(0,0),
#'Marah'=>new Point(0,0),
    'Elim'=>new Point(32.649957,29.866703), # at Wadi Gharandel
#'By the Red Sea'=>new Point(0,0),
#'Sin Wilderness'=>new Point(0,0),
#'Dophkah'=>new Point(0,0),
#'Alush'=>new Point(0,0),
#'Rephidim'=>new Point(0,0), # This is pretty near Mount Sinai
#'Sinai Wilderness'=>new Point(0,0),
#'Kibroth-Hattaavah'=>new Point(0,0),
#'Hazeroth'=>new Point(0,0),
#'Rithmah'=>new Point(0,0),
#'Rimmon-Perez'=>new Point(0,0),
#'Libnah'=>new Point(0,0),
#'Rissah'=>new Point(0,0),
#'Kehelathah'=>new Point(0,0),
#'Mount Shapher'=>new Point(0,0),
#'Haradah'=>new Point(0,0),
#'Makheloth'=>new Point(0,0),
#'Tahath'=>new Point(0,0),
#'Tarah'=>new Point(0,0),
#'Mithcah'=>new Point(0,0),
#'Hashmonah'=>new Point(0,0),
#'Moseroth'=>new Point(0,0),
#'Bene-Jaakan'=>new Point(0,0),
#'Hor Haggidgad'=>new Point(0,0),
#'Jotbathah'=>new Point(0,0),
#'Abronah'=>new Point(0,0),
    'Ezion-Geber'=>new Point(34.950444,29.557539),  # modern day Eliat
    'Kadesh'=>new Point(34.390322,30.612847)  # ein-el-qudeirat
#'Mount Hor'=>new Point(0,0),
#'Zalmonah'=>new Point(0,0),
#'Punon'=>new Point(0,0),
#'Oboth'=>new Point(0,0),
#'Abarim Ruins'=>new Point(0,0),
#'Dibon Gad'=>new Point(0,0),
#'Almon Diblathaim'=>new Point(0,0),
#'Abarim Mountains'=>new Point(0,0),
#'Moab Plains'=>new Point(0,0),
    );

# Edges of the travel region
my @regions = (
    new Region({ Name => 'the Gulf of Suez', Polygons => [ [
      new Point(32.581329,29.946605),
      new Point(32.915039,29.190533),
      new Point(32.794189,28.748397),
      new Point(32.365723,29.563902)
    ], [
      new Point(32.843628,29.272025), 
      new Point(33.173218,28.984117), 
      new Point(33.222656,28.173718), 
      new Point(32.607422,28.979312)
    ],[
      new Point(33.195190,28.647210),
      new Point(34.057617,27.800210),
      new Point(33.585205,27.800210),
      new Point(33.066101,28.391400)
    ]] }),
    new Region({ Name => 'the Gulf of Aqaba', Polygons => [ [
      new Point(34.976349,29.559123),
      new Point(34.790955,28.526622),
      new Point(34.565735,28.042895),
      new Point(34.440765,28.024712),
      new Point(34.417419,28.314053),
      new Point(34.763489,29.363027)
    ]] }),
    new Region({ Name => 'the Red Sea', Polygons => [ [
      new Point(33.483582,27.831790),
      new Point(34.277344,27.792921),
      new Point(34.541016,27.215556),
      new Point(33.826904,27.205786)
    ],[
      new Point(34.225159,27.768621),
      new Point(34.442139,28.013801),
      new Point(35.068359,28.120439),
      new Point(36.655884,26.015820),
      new Point(33.958740,26.676913)
    ]] }),
    new Region({ Name => 'the Mediterranean Sea', Polygons => [ [
      new Point(31,31.531726),
      new Point(32.563477,31.052934),
      new Point(33.848877,31.137603),
      new Point(34.222412,31.297328),
      new Point(34.639893,31.784217),
      new Point(34.969482,32.778038)
    ]] }),
    new Region({ Name => 'Egypt', Polygons => [ [
      new Point(31.1,31.6),
      new Point(32.6,29.9),
      new Point(32.373962,29.532840),
      new Point(30.915283,31.503629)
    ]] }),
    new Region({ Name => 'the Dead Sea', Polygons => [ [
      new Point(35.502319,31.758532), 
      new Point(35.592957,31.749190), 
      new Point(35.581970,31.468496), 
      new Point(35.527039,31.316101), 
      new Point(35.414429,31.323140), 
      new Point(35.406189,31.564495)
    ]] }),
    new Region({ Name => 'the land far east of Canaan', Polygons => [ [
      new Point(36.496582,25.681137),
      new Point(36.518555,33.760882),
      new Point(38.737793,33.979809),
      new Point(37.243652,25.145285)
    ]] }),
    new Region({ Name => 'areas well north of the Promised Land', Polygons => [ [
      new Point(34.771729,32.713355),
      new Point(37.023926,32.759562),
      new Point(37.540283,33.238688),
      new Point(34.365234,33.165145)
    ]] })
);

################################
# Novel-building bits
################################
# Common word/phrase tables
my @deity = ('God','The Lord','The Almighty','The Heavenly Father','Yahweh','Adonai','Elohim','Jehovah');
my @party = ('the Israelites','the Jews','the Jewish people','the Hebrews','the children of Abraham',"God's chosen people","Jacob's descendents", 'the multitude');

# ANACHRONISMS ARE LOL amirite
my @curses = ('Jesus Christ', 'God dammit', 'What the hell', 'Oh my god', 'Holy shit', 'O! not this again');
my @gripes = ('When I said "in our image" this is NOT what I had in mind','At least TRY to make it to the Promised Land this time','600,000 Israelites and this was the best leader I could find');
my @plagues = ('turned the water into blood','summoned a plague of frogs','infested the population with lice','sent forth a plague of flies','set a disease among the livestock','caused skin boils upon the people','summoned a thunderstorm of hail and fire','brought a swarm of locusts','caused the light to turn to darkness','killed the first-born son of every family');


####### STORYBUILDER FUNCTIONS / templates
# Boring report of X uneventful days.
sub d
{
  my $days = shift;
my $printable_days = "$days days";
if ($days == 1) { $printable_days = "another day" };
  v(pick(@party) . " traveled onward for $printable_days.");
}
# Repeated visits to some place
sub again
{
  my $place = shift;
  my $times = shift;

  v(pick('For the ' . ordinal($times) . ' time', 'Again','Once more') . ', ' . pick(@party) . " found themselves at $place.",
    pick('This time there was no rejoicing.','The people grumbled amongst themselves.'),
    pick('Hur','Joshua','I') . ' wondered if ' . pick('it may be best to end our journey here','Moses knew what he was doing','someone else should lead the way','we were going in circles','we should stop and ask for directions') . '.',
    'But Moses insisted that we resume our journey tomorrow.');
}

# Kill a character with appropriate gravitas
sub killoff
{
  my $name = shift;

  my @died = ('died','expired','passed away','perished');
  my @means = ('was bitten by an asp','fell from a camel','came under attack by a nomad','was struck by a sudden illness');

  v("On this day, $name " . pick(@means) . '.',
    "Though Hur did tend to $name as he could, they " . pick(@died) . ' during the night.',
    'So it was that ' . pick(@deity) . " carried $name from this world.");

  # taken from Numbers
  v("After the passing of $name, the news spread throughout the people.",
    'And all ' . pick(@party) . ', seeing that ' . $name . ' was dead, mourned for thirty days throughout all their families.');

  # advance 30 days (don't eat though...)
  $day += 30;
}

# Usage
die "Usage: $0 <seed> <novelfile> <kmlfile>\n" if (@ARGV != 3);
srand($ARGV[0]);

# seed chains
my $chain = new MarkovChain(2);
debug('Seeding Markov generator...');
open(FP,'psalms.txt') or die "can't read psalms.txt: $!\n";
while(my $line = <FP>)
{
  chomp $line;
#debug($line);
  $chain->add($line);
}
close(FP);
debug("\tDone!");

# Setup initial KML boilerplate
my $kml_base='<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document><name>BookOfEliza</name><description>Map of journey taken</description><Style id="PolyStyle"><LineStyle><color>CD0000FF</color><width>2</width></LineStyle><PolyStyle><color>9AFF0000</color></PolyStyle></Style><Style id="CityStyle"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/paddle/red-circle.png</href></Icon></IconStyle></Style><Style id="Position"><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/paddle/wht-circle-lv.png</href></Icon></IconStyle></Style>' . "\n";
# dump bounding regions
foreach my $region(@regions)
{
  foreach my $polygon (@{$region->{Polygons}})
  {
    $kml_base .= ('<Placemark><name>' . $region->name . "</name><styleUrl>#PolyStyle</styleUrl><Polygon><altitudeMode>clampToGround</altitudeMode><outerBoundaryIs><LinearRing><coordinates>\n");
    foreach my $point (@{$polygon})
    {
      $kml_base .= ($point->x . ',' . $point->y . ",0.0\n");
    }
    $kml_base .= "</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>\n";
  }
}

#dump cities and POIs
foreach my $poi (keys %pois)
{
  $kml_base .= ('<Placemark><name>' . $poi . '</name><styleUrl>#CityStyle</styleUrl><Point><coordinates>' . $pois{$poi}->x . ',' . $pois{$poi}->y . ",0.0</coordinates></Point></Placemark>\n");
}
foreach my $city (keys %cities)
{
  $kml_base .= ('<Placemark><name>' . $city . '</name><styleUrl>#CityStyle</styleUrl><Point><coordinates>' . $cities{$city}->x . ',' . $cities{$city}->y . ",0.0</coordinates></Point></Placemark>\n");
}

# Loop until successful novel is created
my $built_novel_OK = 0;
while (!$built_novel_OK)
{
# Reset novel to scratch
  $novel = '';
# other localish vars
  $chapter = 1;
  $verse = 1;

  $kml = $kml_base;

  my $last_visited = '';
  my %objects_seen = ();  # Here is a serious hack to keep track of the places we've seen before

# Set party conditions
# World state
  my %state = (
# event flags
      FOUND_SINAI => 0,
      FOUND_CANAAN => 0,

# characters
      AARON_DEAD => 0,
      MIRIAM_DEAD => 0,

# position and other info
      POSITION => new Point(31.821367,30.787419),
      RATE => 0.1,  # at equator 0.1 degrees == 6.9 miles (6 naut. mi.)
      HEADING => -0.5,
      PROVISIONS => 30
        );

# Build novel.
  $novel .= "# The Book of Eliza\n";
  $novel .= "## Preface\nArchaeologists working at an excavation site near Israel have recently uncovered a find of truly biblical proportions.  Sealed in a clay pot under an ancient shelter, researchers found a manuscript dating back to the time of the Hebrew exodus from Egypt.  The manuscript, titled \"The Book of Eliza\", is in mint condition and still in the original shrink wrap.  Historians are excited to finally have a pedantically detailed account of the Jewish peoples\' trials as they passed from slavery in Egypt to the promised land of Canaan.  However, some scholars have had their feathers ruffled by its stark portrayal of some of most beloved heroes of Judaism (and, by extension, Christianity).  The remainder of this document contains the Book of Eliza in its entirety.";

  # FIRST CHAPTER
  c;
  v("So it was that the Israelites, having crossed the Sea of Reeds unharmed, set out in search of the Promised Land.","Moses, son of Amram, led his people as ordered by God.","Aaron, the brother of Moses, had knowledge of the stars and lands; he instructed Moses in the direction to lead the congregation.","The prophet Miriam, Aaron's sister, was well loved by the women and children; she too was with them.","The others who led the way were Joshua, Moses' friend and assistant, and Hur, Moses' son.");

  # Start!
  $day = 0;
  my $needs_chapter_break = 0;
my $uneventful_days=0;
  debug("Day $day: ", $state{POSITION}->dump);

  while( ! $state{FOUND_CANAAN} ) 
  {
    my $shortdesc = '';
    my $moveOK = 1;

    # advance a day
    $day ++;

    # New chapter
    if ($needs_chapter_break) {
      # Chance to insert random praise
      if (chance(0.15))
      {
        c;
        my $psalm_len=6+int(rand(8));
        debug("Inserting random $psalm_len line psalm");
        for (my $i = 0; $i <$psalm_len; $i++) {
          v($chain->spew . '.');
        }
      }

      # New empty chapter
      c;
      $needs_chapter_break = 0;

    # Chapter opening sentence
    v("On the " . ordinal($day) . " day, " .
        pick(@party) . ' ' .
	pick('again resumed','prepared and departed on','awoke early for','continued along','set out on') . ' ' .
	pick('their journey','their travels','their way') . '.');

    # Weather and provisions report
    v(pick('The sky was','The day was','The morning was','The conditions were','The weather was','The climate was') . ' ' .
        pick('clear','hot','dry','bright','dusty','cloudless') . '.');

# Be inexact in reporting remaining provisions
      my $provs_estimate = $state{PROVISIONS} - 2 + int(rand(5));
      if ($provs_estimate < 2) { $provs_estimate = 'less than two'; }
      v(pick('The people had food and water for nearly','Joshua found that there were provisions enough for',"By Hur's reckoning, the people could eat for",'I reasoned that our food stores were sufficient for') . " $provs_estimate more days.");
# some flavor
      if ($state{PROVISIONS} < 4) {
        v(pick(@party) . ' were growing quite desperate.',"Moses was looking rather thin.");
      } elsif ($state{PROVISIONS} < 8) {
        v(pick(@party) . ' were ' . pick('hungry','thirsty') . '.');
      } else {
        v('The people were ' . pick('satiated and content','ready to continue','eager to carry on') . '.');
      }

  # begin simulating the days
  $uneventful_days=0;
}

    # Eat
  $uneventful_days++;
      $state{PROVISIONS}--;

    # Compute distance to Jerusalem
    my $start_dist = $state{POSITION}->dist($pois{'Jerusalem'});

# Special events for the morning
#  Aaron's death
    if ($day > 10 && !$state{AARON_DEAD} && chance(0.25)) {
d($uneventful_days);
      debug("*** AARON HAS DIED");
      killoff('Aaron');
      $shortdesc = 'Death of Aaron';
      $state{AARON_DEAD} = 1;
      $needs_chapter_break = 1;
    }
#  Miriam's death
    elsif ($state{FOUND_CANAAN} && !$state{MIRIAM_DEAD} && chance(0.2)) {
d($uneventful_days);
      debug("*** MIRIAM HAS DIED");
      killoff('Miriam');
      $shortdesc = 'Death of Miriam';
      $state{MIRIAM_DEAD} = 1;
      $needs_chapter_break = 1;
    } else {
      # Well nothing else to do, so let's move

# Try to move the party
# fuck up the heading
      if ($state{AARON_DEAD})
      {
        $state{HEADING} = $state{HEADING} - 1 + rand(2);
      } else {
        $state{HEADING} = $state{HEADING} - .1 + rand(.2);
      }

      my $x_chg = $state{RATE} * cos($state{HEADING});
      my $y_chg = $state{RATE} * sin($state{HEADING});
      my $newLocation = new Point($state{POSITION}->x + $x_chg, $state{POSITION}->y + $y_chg);

# check entry to each region
      foreach my $region (@regions)
      {
        if ($region->contains($newLocation))
        {
# prevent movement
          debug(" * Movement into " , $region->name , " halted");

d($uneventful_days);
          v("Joshua said unto Moses,",
              '"We should not travel this way - it leads to ' . $region->name . '!"',
	      'Moses ' . pick('replied','answered','stated','said') . ' ' . pick('wisely','sagely','with great import') . ',',
              '"' . pick("I knew that.","I was merely testing you.","Whoops.","Are you sure about that?") . '"',
              pick(@party) . " thus reversed their direction.");

          $shortdesc = 'Entry stopped';
          $needs_chapter_break = 1;
# flip heading
          $state{HEADING} += 3.14159;
          $moveOK = 0;
          last;
        }
      }

# is OK to move
      if ($moveOK) { $state{POSITION} = $newLocation; }

    # final dist to Jerusalem or other specials
    my $dist = $state{POSITION}->dist($pois{'Jerusalem'});

    # end of day checks
    # check proximity to each city or other PoI
    foreach my $city (keys %cities)
    {
      if ($state{POSITION}->dist($cities{$city}) < $state{RATE})
      {
if ($last_visited ne $city) {
        # Restock provisions
        $state{PROVISIONS} = 30;
        debug("Party has reached $city.");

d($uneventful_days);
$objects_seen{$city}++;
if ($objects_seen{$city}>1)
{
  again($city,$objects_seen{$city});
} else {
        v("At the end of the day's travel, " . pick(@party) . " reached $city.",
		pick(@party) . " rejoiced at this sign of progress in their journey.",
		'After a restful night, ' . pick(@party) . " were able to restock their provisions.");
}

        $shortdesc = 'Stopped in ' . $city;
        $needs_chapter_break = 1; }
$last_visited = $city;
	last;
      }
    }

    # Look at various items here
    if ($dist < $state{RATE}) {
d($uneventful_days);
      debug("Found Canaan!");
      $state{FOUND_CANAAN} = 1;
      $shortdesc = 'Found Canaan';
    } elsif ($state{POSITION}->dist($pois{'Mount Sinai'}) < $state{RATE}) {
if ($last_visited ne 'Mount Sinai') {
      if ($state{FOUND_SINAI}) {
         again('Mount Sinai',$state{FOUND_SINAI});
      } else {
        debug("Found the Ten Commandments!");
d($uneventful_days);
# YAY WRITING
        v('On this day ' . pick(@party) . ' arrived at the base of Mount Sinai.',
          'Moses bid the rest of us to stay behind; he ascended the mountain on his own.',
          'For three days we awaited his return.',
          'At last, Moses returned from the mountain-top, bearing two heavy stone tablets.',
          'Moses said to the multitude,',
          '"These are the Ten Commandments, delivered unto me by God.',
          'We must carry these with us into the Promised Land."',
          'Carrying the stones was no major burden, but the tabernacle Moses made us build must have weighed more than a Volkswagen.',
          'Our progress was slowed as a result.'
        );
        $day += 3;
        $state{RATE} = 0.09;
        $shortdesc = 'Found Ten Commandments';
}
        $needs_chapter_break = 1;
      $state{FOUND_SINAI} ++;
      }
$last_visited = 'Mount Sinai';
    } elsif ($state{PROVISIONS} == 0)
    {
       # starvation 
      debug("Party starved to death.");
d($uneventful_days);
  my @died = ('died','expired','passed away','perished');

  v("After a long day of marching, Moses could travel no further.","Thirst and hunger overtook the chosen leader of " . pick(@party) . ", and he did die.");

  # Revive Moses
  my @divine = ('the very clouds in the sky parted','angels descended from the heavens','a chorus of trumpets blared','a deafening sound arose from the air','shining light beamed down from above','the people were in awe at the presence of the Lord','thunder and lightning lashed out above our heads');
  v('Suddenly, ' . pick(@divine) . '.',
    pick(@divine) . '.',
    'The voice of ' . pick(@deity) . ' spoke unto ' . pick(@party) . ':',
    '"' . ucfirst(pick(@curses)) . '!',
    pick(@gripes) . '."',
    'After these words, the body of Moses was surrounded in a beam of light.',
    'Miraculously, the Lord caused Moses to rise from the dead!',
    'After Moses was revived, the sky returned to normal.',
    'The voice of ' . pick(@deity) . ' spoke once again:',
    '"' . ucfirst(pick(@gripes)) . '."',
    'Moses then turned and said to those gathered here:',
    '"' . pick('Nobody write this down, ok?', 'Pretend you didn\'t see any of that.', 'Leave this part out of the Bible.', 'Don\'t tell anyone this happened, guys.') . '"'
   );
      $state{PROVISIONS} = 30;
      $shortdesc = 'Starved to death';
      $needs_chapter_break = 1;
    } elsif ($moveOK) {
      # Flavor
      if (chance(0.1))
      {
d($uneventful_days);
        # build char array
        my @chars = ('I','Hur','Joshua');
        if (! $state{AARON_DEAD} ) { push @chars, 'Aaron'; }
        if (! $state{MIRIAM_DEAD} ) { push @chars, 'Miriam'; }

        my $progress = $start_dist - $dist;
        if (abs($progress) < ($state{RATE} / 2)) {
          v(pick(@chars) . ' ' . pick('remarked','noted','observed','stated','felt') . ' that we seemed to be making little progress.');
          $shortdesc = 'Little progress';
      $needs_chapter_break = 1;
        } elsif ($progress < 0) {
          v(pick(@chars) . ' ' . pick('remarked','noted','observed','stated','felt') . ' that we might be going the wrong way.',
            'However, last time someone ' . pick('argued with','questioned','doubted') . ' Moses, he ' . pick(@plagues) . '; none were willing to ' . pick('raise their voices again','oppose him this time','discredit him') . '.');
          $shortdesc = 'Wrong way';
      $needs_chapter_break = 1;
        } else {
          v(pick(@chars) . ' ' . pick('remarked','noted','observed','stated','felt') . ' that we seemed to be going ' . pick('the right way','in the correct direction','towards the Promised Land','as ' . pick(@deity) . ' had designed') . '.');
          $shortdesc = 'Right way';
      $needs_chapter_break = 1;
        }
$uneventful_days=0;
      } elsif (chance(0.1)) {
d($uneventful_days);
        # Other random chance of fun stuff.
        my $miracle = int(rand(3));
        if ($miracle == 0) {
          # manna
          v(pick(@party) . ' were unhappy with ' . pick(@deity) . '.',
            'They did question unto Moses:',
            '"Where is the Lord, who would let us starve, and suffer us to be led aimlessly in the desert by you?"',
            'As ' . pick(@party) . ' arose the next day, they discovered a miracle had occurred!',
            pick('Quail enough to feed the multitudes covered the lands.','Manna had rained from heaven, and cured their hunger.','Rain fell from the skies to water the livestock.'),
            'Moses pointed to these events as signs of ' . pick(@deity) . '.');
          $state{PROVISIONS} += 5;
        } elsif ($miracle == 1) {
          # Attacked!
          v(pick(@party) . ' found themselves under attack by ' . pick('the Amalek','the kingdom of Sehon','the kingdom of Og','the kingdom of Ahad') . '.',
            'Though they fought many men, they did not fear destruction.',
            pick('For the Lord did protect them and keep them safe.','As long as Moses kept his arms raised, ' . pick(@party) . ' held the upper hand; though he was weak and did skip arm day, his servants helped keep them aloft.'),
            'A fearsome battle ensued, yet in the end ' . pick(@party) . ' were victorious.');
        } elsif ($miracle == 2) {
           # how about some good old fashioned smiting
           v('At this time certain members of ' . pick(@party) . ' fell from the favor of ' . pick(@deity) . '.',
             pick('They became dissatisfied with their situation.','Some among us gathered their valuables and created their own idol.','Some began to proclaim that they were better under the rule of the Pharaoh','One follower claimed he would start his own Promised Land, with blackjack and hookers.'),
             'These events greatly displeased ' . pick(@deity) . '.',
             'Because of this, ' . pick('they were cast out from ' . pick(@party) . ' and forced to wander alone','a terrible plague was visited upon them','fiery serpents did bite and kill many in the congregation','they became afflicted with leprosy','the earth broke beneath their feet and they were swallowed by it') . '.',
             'Those who witnessed these events did tremble with fear, and they did choose to keep with Moses, despite ' . pick('his temperament','his poor sense of direction','their misgivings','their doubts') . '.');
        }
      $needs_chapter_break = 1;
      }
    }
    }

# dump daily status
    debug("Day $day: ", $state{POSITION}->dump);
    $kml .= ('<Placemark><name>Day ' . $day . '</name><description>' . $shortdesc . '</description><styleUrl>#Position</styleUrl><Point><coordinates>' . $state{POSITION}->x . ',' . $state{POSITION}->y . ",0.0</coordinates></Point></Placemark>\n");

    # Shortcut to terminate novel if it's getting too long
    if (split(/\s+/,$novel) > $max_length) { $state{FOUND_CANAAN}=1; }
  }

  # Made it!  Print last chapter.
  $day ++;
  c;
  v("At long last, " . pick(@party) . " found themselves within a day's march of the Promised Land.",
    'On the eve of this momentous occasion, Moses addressed the multitude thus:',
    '"' . ucfirst(pick(@party)) . '!',
    'After much hardship, we have reached Canaan.',
    'Remember well that it is I, Moses, who brought you here.',
    'See, I told you I knew what I was doing."',
    "At once, a bolt of lightning struck Moses from a clear blue sky.",
    'He fell dead where he stood.',
    'The voice of ' . pick(@deity) . ' thundered out from above:',
    '"I have had just about enough of that guy."');

  c;
  v(pick(@party) . " rejoiced for many days after arriving in Canaan.",
    'During this time, Joshua spoke unto Hur:',
    '"For how many days did ' . pick(@party) . ' wander in the desert?',
    pick(@deity) . ' wants to know, for accounting purposes."',
    'Hur did reply without hesitation:',
    '"Forty years."',
    'Joshua wondered at this, but as Hur was the son of Moses, he did not question further.','And so it was that the Israelites were delivered unto the Promised Land after forty years, as ordained by God.');

  my $word_count = split(/\s+/,$novel);

  $kml .= '</Document></kml>';

# editorial controls
  if ($word_count < $min_length) {
    say STDERR "Only $word_count words, insufficient length (must be $min_length to accept)";
  } elsif ($word_count > $max_length) {
    say STDERR "Got $word_count words, way too long! Trying again for under $max_length.";
  } elsif (! $state{FOUND_SINAI}) {
    say STDERR "Oops, never got the Ten Commandments after $word_count words";
  } else {
#  Worked
    $built_novel_OK=1;
    say STDERR "Total words: $word_count";
  }
}

# Made it this far, it's a best-seller!
open FP,'>',$ARGV[1] or die "Failed to write novel to $ARGV[1]: $!\n";
print FP $novel;
close FP;

# dump KML too
open(KML,'>',$ARGV[2]) or die "Couldn't open KML output $ARGV[2]: $!\n";
print KML $kml;
close KML;

# done!
