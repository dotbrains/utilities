# Utilities

This is a set of useful bash utilities that I have curated over the years.

## Use

In order to use [`utils.sh`](utils.sh) you must `source` the script at the beginning of your bash script.

Do this using the following code snippet:

`source <(curl -s "https://github.com/nicholasadamou/utilities/raw/master/utils.sh")`

- _This assumes `curl` is installed on your system._

**Note**: _Due to an [issue pertaining to bash 3.2 on MacOS](https://stackoverflow.com/a/32596626/5290011) please use the following snippet instead:_

`source /dev/stdin <<<"$(curl -s "https://github.com/nicholasadamou/utilities/raw/master/utils.sh")"`
