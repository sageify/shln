# Shell Script Modules

Shmod imports (sources) shell scripts into the current script from a git repository.

## Usage

```sh
#!/bin/sh

. shmd
import github.com/dockcmd/sh@v0.0.4 docker.sh

```

## Module Management

Modules may be managed using Shroom (shrm).  Shroom is a simple wrapper around Groom but sets the home repository directory to ~/.shmod if no SHMOD_HOME is set.

```sh
shrm
```