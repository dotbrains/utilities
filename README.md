# Dot-file-Utilities

This is a set of dot-file utilities that are used in the programming of my dot-files repo.

## Use

In order to use [`utils.sh`](utils.sh) you must `source` the script at the beginning of your bash script.

Do this using the following code snippet:

`source <(curl -s "")`

-   _This assumes `curl` is installed on you're system._

**Note**: _Due to an [issue pertaining to bash 3.2 on MacOS](https://stackoverflow.com/a/32596626/5290011) please use the following snippet instead:_

`source /dev/stdin <<<"$(curl -s "")"`
