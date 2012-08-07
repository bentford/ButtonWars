# Button Wars

This is a proof of concept game to prove a few things:

a) that Core Animation is fast enough to make a game from

b) how the Chipmunk physics library can be integrated into UIKit or Core Animation at a low level


## How to play

* Currently only supports two players, so grab a friend.

* **IMPORTANT: Right swipe anywhere on the screen to change levels and use the level editor!!**


## How to use the level editor

*NOTE: the level editor is not very user friendly, use at your own risk.*

To invoke the level editor, make a horizontal swipe gesture to the right in the game screen.

Type in characters in the 65 x 33 character grid.  Good luck!

* p - peg
* w&lt;num&gt; - makes a wall
* rb&lt;degrees&gt; - makes a rotating bumper, where it will shoot to degrees
* b - normal bumper
* sx&lt;v|h&gt;&lt;n|s&gt;&lt;distance&gt; - sliding box, first option change between vertical or horizontal, second option changes start point
* s2 - indicates marble shooter, moving or playing these is not yet supported

The vertical line of x's on the left side is just a guide, it doesn't change anything.  It helps to keep it aligned.


## Credits

The game idea, graphic design, and programming are all done by me.

Who am I?

http://benford.me