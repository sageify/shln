# Link Management

## SHLN LN

Add new links.  By default, shln will look in the git package root directories.

For example, upon first creation, 

```bash
shln -ln helloworld.sh
shln ln $(shpk -find -d helloworld.sh) helloworld.sh | cut -

```