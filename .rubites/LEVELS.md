# Level plan

A **level** is one fundamental topic. Each level is made of several
**exercises**, and each exercise is one file in `exercises/`.

Exercises are numbered `level.index`:

    1.2
    │ └── the exercise within the level, counting from 0
    └──── the level

So level 3 owns `3.0`–`3.8`. Nine exercises per level is the ceiling; four or
five is the target. The number is both the filename prefix and the header, and
they have to agree — a test enforces it. Numbers are also the progress key
(`Progress#solved?`), so exercises can be renamed freely but not renumbered.

The engine sorts numerically rather than by filename, so level 10 lands after
level 2 rather than between 1 and 3. Beyond sorting and the level map's rows,
it does not treat a level as a thing in its own right: levels have no titles in
the game, only here.

## What each exercise has to do

- Teach exactly one thing, and be solvable by editing the line marked `# TODO`.
- Ship **unsolved** — enforced by `test_..._ships_unsolved`.
- Be checkable by comparing printed output. There is no other assertion.
- Fail in a way the diff can explain well: a one-line, one-difference failure
  gets a caret pointing at the exact column. Prefer those.

## What exercises cannot do

- **Read input.** Stdin is closed in the child process; `gets` returns `nil`.
- **Take longer than 5 seconds.** The runner kills the process.
- **Print more than 8 lines**, or the panel truncates to `… +N more`.
- **Distinguish `print` from `puts`** by trailing newline — trailing whitespace
  is normalised away. `print` only earns an exercise when two calls build one
  line.

## Writing them

`start --author 3.2` opens one exercise; `start --author 3` opens the start of
level 3. Either way every exercise is unlocked, `n` and `p` step between them,
and nothing is written to the save file.

---

## Level 1 · Output — making the computer say something

The first thing that has to happen is that the learner sees their own change
appear on screen.

| # | Exercise | The one thing |
|---|---|---|
| 1.0 | A first line | `puts` prints what is inside the quotes |
| 1.1 | More than one line | two `puts` calls make two lines |
| 1.2 | Printing a number | numbers need no quotes, and `puts 2 + 2` prints `4` |
| 1.3 | Staying on the same line | `print` does not move to the next line |

## Level 2 · Variables — giving a value a name

| # | Exercise | The one thing |
|---|---|---|
| 2.0 | Naming a value | `=` binds a name to a value |
| 2.1 | Using the name twice | the name stands in for the value everywhere |
| 2.2 | Changing your mind | reassignment; the last value wins |
| 2.3 | Building one from others | a variable can be defined from other variables |

## Level 3 · Strings — text you can shape

| # | Exercise | The one thing |
|---|---|---|
| 3.0 | Interpolation | `#{}` drops a value into a string |
| 3.1 | Interpolating two values | one pair of quotes, several holes |
| 3.2 | Joining instead | `+` concatenates, and why interpolation is nicer |
| 3.3 | Shouting | `upcase` / `downcase` return a *new* string |
| 3.4 | Measuring | `length`, and that it counts characters not words |

## Level 4 · Numbers — arithmetic and its surprises

| # | Exercise | The one thing |
|---|---|---|
| 4.0 | The four operations | `+ - * /` |
| 4.1 | Order of operations | parentheses change the answer |
| 4.2 | The integer division trap | `7 / 2` is `3`, not `3.5` |
| 4.3 | Floats fix it | `7.0 / 2`, and how floats print |
| 4.4 | Text is not a number | `"7".to_i`, `7.to_s` |

## Level 5 · Truth — comparing things

| # | Exercise | The one thing |
|---|---|---|
| 5.0 | Asking a question | a comparison prints `true` or `false` |
| 5.1 | Equal, and assignment | `==` compares, `=` assigns |
| 5.2 | And, or, not | combining two questions |
| 5.3 | Nothing at all | `nil`, and that it is not `false` |

## Level 6 · Conditionals — doing different things

| # | Exercise | The one thing |
|---|---|---|
| 6.0 | If | run a line only sometimes |
| 6.1 | Otherwise | `else` |
| 6.2 | More than two ways | `elsif`, and that order matters |
| 6.3 | Unless | the inverted `if`, and when it reads better |
| 6.4 | Deciding on two things | a condition built with `&&` |

## Level 7 · Arrays — many values under one name

| # | Exercise | The one thing |
|---|---|---|
| 7.0 | A list | making one, and that `puts` prints each item on its own line |
| 7.1 | Reaching in | `[0]`, `first`, `last`, and that counting starts at zero |
| 7.2 | Growing | `<<` / `push`, and `length` |
| 7.3 | Back to one string | `join` |
| 7.4 | Order and membership | `sort`, `include?` |

## Level 8 · Repetition — doing it again

| # | Exercise | The one thing |
|---|---|---|
| 8.0 | N times | `times` |
| 8.1 | Once per item | `each` |
| 8.2 | A range of numbers | `(1..5).each` |
| 8.3 | Changing every item | `map` |
| 8.4 | Keeping some, adding up | `select`, `sum` |

## Level 9 · Hashes — values with labels

| # | Exercise | The one thing |
|---|---|---|
| 9.0 | Looking something up | key to value |
| 9.1 | Symbols as keys | `:name`, and adding a pair |
| 9.2 | What is in here | `keys`, `values` |
| 9.3 | Once per pair | `each` with two block parameters |
| 9.4 | Not there | a missing key is `nil`; `fetch` with a default |

## Level 10 · Methods — naming an action

| # | Exercise | The one thing |
|---|---|---|
| 10.0 | Defining and calling | `def`, and that defining runs nothing |
| 10.1 | Passing something in | arguments |
| 10.2 | Handing something back | the last line is the return value |
| 10.3 | A sensible default | default arguments |
| 10.4 | Methods using methods | composing two of your own |

---

Everything below is the frontier rather than the fundamentals. It belongs in
the plan, but only once levels 1–10 are written and played through.

## Level 11 · Blocks — passing code around

| # | Exercise | The one thing |
|---|---|---|
| 11.0 | Two ways to write one | `do ... end` and `{ ... }` |
| 11.1 | Block parameters | the `|item|` slot |
| 11.2 | Writing one that takes a block | `yield` |
| 11.3 | Only if there is one | `block_given?` |

## Level 12 · Objects — your own kinds of thing

| # | Exercise | The one thing |
|---|---|---|
| 12.0 | A class and a new one | `class`, `initialize`, `.new` |
| 12.1 | Asking it about itself | `attr_reader` |
| 12.2 | Teaching it to do something | an instance method |
| 12.3 | Printing it | `to_s` |
| 12.4 | Two objects together | one object using another |

---

## Where things stand

Level 1 is written. Levels 2–10 are specified above and unwritten; the three
placeholder files the engine shipped with have been replaced.
