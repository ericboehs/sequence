# Sequence Winner Announcer

The game board:

<img src="https://user-images.githubusercontent.com/28198/89595943-9690a580-d81b-11ea-8eb7-ca7c11b6ffda.jpeg" width=512>

What the computer sees and displays:

<img src="https://user-images.githubusercontent.com/28198/89595994-bb851880-d81b-11ea-806d-bc679f4a05ea.png" width=512>


## What?
This program detects and announces winning moves for the board game [Sequence](https://www.jaxgames.com/sequence/).

## Why?
My family would commonly play past the end of the game because we wouldn't notice someone won.

## How?
This uses OpenCV to do the computer vision and Ruby to do the solving. (I'm a rubyist so this was the fastest way to write the solver for me.)

## Caveats
- The color profile is highly customized to my camera and will need to be adjusted if you really are trying to get this to work for yourself.
- It only works for Blue and Green pieces.
- The code needs refactored. It was written in a couple evenings so many hacks and copy/pastes were done.
