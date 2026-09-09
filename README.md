# Rubites

Learn to code in Ruby.

## Playing

    cd rubites
    direnv allow   # once, the first time
    start

`start` opens the game. It gives you one exercise at a time: open the file it
names in your own editor, change the line marked `# TODO`, and save. The game
watches the file, re-runs it, and moves you on when the output matches.

Without [direnv](https://direnv.net), run `.rubites/bin/rubites` instead.

## What is here

`levels/` is the course, one directory per level, and it is the only thing you
need to open. Exercises are numbered `level.index`, so `levels/1/1.0_...` is
the first exercise of level 1, and they unlock in order.

The game itself lives in `.rubites/`, out of the way of the levels. Nothing in
there needs touching to play.
