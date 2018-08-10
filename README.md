# Alex: Proof of concept for preference learning algorithms

![Rubyhexagon](https://mootech.eu/alex.png)

Rubyhexagon icon by the very talented [Ulvra](https://www.furaffinity.net/user/ulvra)

![GitHub Release Date](https://img.shields.io/github/release-date/maxine-red/alex.svg)

## Description

Alex is a test program, to research ways of preference learning algorithms to
communicate with their developers.

The code is always cleaned up with rubocop, but can be messy at some times, as
idea flow is priotized over immediate code quality.

Currently, there is a method tested, that determines tags, that are most
influential, for a decision and highlights those.

## Installation

Download this gem or clone it into a directory to use.

A PostgreSQL server must be setup and a database called 'alex' needs to be
present.

Please then execute `$ psql -f sql/alex.sql alex` to populate the database.

The needed SQL file can be downloaded under https://mootech.eu/sql/alex.sql.

You can reset everything by simply running the above command again.
It also contains a lot of data, so execution might take some time.

## Examples

Required that you're in the project's root directory:

`$ bin/alex train`

Will train the network, it is pre-trained already.

`$ bin/alex show`

Shows a post, Alex thinks the user will like, and gives additional information
on why something was chosen.

`$ bin/alex rate [post id] [rating]`

Add another rating to Alex's list of ratings. This is used for
training/learning.

## Donations

[![Patreon](https://img.shields.io/badge/Patreon-donate-orange.svg)](https://www.patreon.com/maxine_red)
[![KoFi](https://img.shields.io/badge/KoFi-donate-blue.svg)](https://ko-fi.com/maxinered)

## Social Media

Follow me on Twitter, if you're brave enough.

[![Twitter Follow](https://img.shields.io/twitter/follow/maxine_red.svg?style=social&logo=twitter&label=Follow)](https://twitter.com/maxine_red)

## License

[![GPLv3](https://www.gnu.org/graphics/gplv3-127x51.png)](https://www.gnu.org/licenses/gpl-3.0.en.html)

Copyright 2018 :copyright: Maxine Michalski

## Semantic versioning

This gem follows semantic versioning 2.0. This means that minor releases are
safe to use and you can set your dependecy to '~> 1.0'.

## Contributing

1. [Fork it](https://github.com/maxine-red/alex/fork)
1. Create your feature branch (git checkout -b my-new-feature)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create a new Pull Request
