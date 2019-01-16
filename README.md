# Utilities [![Build Status](https://travis-ci.org/nicholasadamou/utilities.svg?branch=master)](https://travis-ci.org/nicholasadamou/utilities)

This is a set of useful bash utilities that I have curated over the years.

## How to Use

In order to use [`utilities.sh`](utilities.sh) you must `source` the script at the beginning of your bash script.

Do this using the following code snippet:

`source <(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/utilities.sh")`

- _This assumes `curl` is installed on your system._

**Note**: _Due to an [issue pertaining to bash 3.2 on MacOS](https://stackoverflow.com/a/32596626/5290011) please use the following snippet instead:_

`source /dev/stdin <<<"$(curl -s "https://raw.githubusercontent.com/nicholasadamou/utilities/master/utilities.sh")"`
