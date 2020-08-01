#!/usr/bin/env perl
use strict;
use warnings;

## LOCAL MODULES
# make local dir accessible for use statements
use FindBin qw( $RealBin );
use lib $RealBin;

use MarkovChain;

# new chain of order 2
my $chain = new MarkovChain(2);

# All psalms containing "Zion"
$chain->add(
  "Yet have I set my king upon my holy hill of Zion",
  "Sing praises to the LORD, which dwelleth in Zion: declare among the people his doings",
  "That I may shew forth all thy praise in the gates of the daughter of Zion: I will rejoice in thy salvation",
  "Oh that the salvation of Israel were come out of Zion! when the LORD bringeth back the captivity of his people, Jacob shall rejoice, and Israel shall be glad",
  "Send thee help from the sanctuary, and strengthen thee out of Zion",
  "Beautiful for situation, the joy of the whole earth, is mount Zion, on the sides of the north, the city of the great King",
  "Let mount Zion rejoice, let the daughters of Judah be glad, because of thy judgments",
  "Walk about Zion, and go round about her: tell the towers thereof",
  "Out of Zion, the perfection of beauty, God hath shined",
  "Do good in thy good pleasure unto Zion: build thou the walls of Jerusalem",
  "Oh that the salvation of Israel were come out of Zion! When God bringeth back the captivity of his people, Jacob shall rejoice, and Israel shall be glad",
  "For God will save Zion, and will build the cities of Judah: that they may dwell there, and have it in possession",
  "Remember thy congregation, which thou hast purchased of old; the rod of thine inheritance, which thou hast redeemed; this mount Zion, wherein thou hast dwelt",
  "In Salem also is his tabernacle, and his dwelling place in Zion",
  "But chose the tribe of Judah, the mount Zion which he loved",
  "They go from strength to strength, every one of them in Zion appeareth before God",
  "The LORD loveth the gates of Zion more than all the dwellings of Jacob",
  "And of Zion it shall be said, This and that man was born in her: and the highest himself shall establish her",
  "Zion heard, and was glad; and the daughters of Judah rejoiced because of thy judgments, O LORD",
  "The LORD is great in Zion; and he is high above all the people",
  "Thou shalt arise, and have mercy upon Zion: for the time to favour her, yea, the set time, is come",
  "When the LORD shall build up Zion, he shall appear in his glory",
  "To declare the name of the LORD in Zion, and his praise in Jerusalem",
  "The LORD shall send the rod of thy strength out of Zion: rule thou in the midst of thine enemies",
  "They that trust in the LORD shall be as mount Zion, which cannot be removed, but abideth for ever",
  "When the LORD turned again the captivity of Zion, we were like them that dream",
  "The LORD shall bless thee out of Zion: and thou shalt see the good of Jerusalem all the days of thy life",
  "Let them all be confounded and turned back that hate Zion",
  "For the LORD hath chosen Zion; he hath desired it for his habitation",
  "As the dew of Hermon, and as the dew that descended upon the mountains of Zion: for there the LORD commanded the blessing, even life for evermore",
  "The LORD that made heaven and earth bless thee out of Zion",
  "Blessed be the LORD out of Zion, which dwelleth at Jerusalem Praise ye the LORD",
  "By the rivers of Babylon, there we sat down, yea, we wept, when we remembered Zion",
  "For there they that carried us away captive required of us a song; and they that wasted us required of us mirth, saying, Sing us one of the songs of Zion",
  "The LORD shall reign for ever, even thy God, O Zion, unto all generations Praise ye the LORD",
  "Praise the LORD, O Jerusalem; praise thy God, O Zion",
  "Let Israel rejoice in him that made him: let the children of Zion be joyful in their King"
);

print $chain->spew . ".\n";
