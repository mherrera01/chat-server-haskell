# chat-server-haskell

A rest chat server made with Haskell using the
[Yesod framework](https://www.yesodweb.com/). It is implemented taking
advantage of the STM technology for clients concurrency.

## Build

> **_NOTE_**: Building the project could take a while if it is the first time
installing the package dependencies defined in the package.yaml file.

### Environment

This project is developed on Windows with the following Haskell platform,
which is available to download [here](https://downloads.haskell.org/~platform/8.0.2/):
- [GHC](https://www.haskell.org/ghc/) (Glasgow Haskell Compiler) version 8.0.2:
Support of the [Haskell 2010 language](https://wiki.haskell.org/Language_and_library_specification).

- [Stack tool](https://docs.haskellstack.org/) version 1.3.2: Compile and
run a Haskell project allowing several commands such as `build`, `exec` and `clean`.

- [hpack](https://github.com/sol/hpack) version 0.15.0: Build the cabal package
file from the package.yaml during compilation.

- Snapshot resolver [lts-8.20](https://www.stackage.org/lts-8.20): Specify the
GHC version to use and the versions of package dependencies. This is configured
in the stack.yaml file.

For newer versions, the installation and setup have changed, whose instructions can
be found in the official [Haskell site](https://www.haskell.org/downloads/).

### Production

For running the server in production mode, write the following stack commands:
```
$> stack build
$> stack exec chat-server-haskell-exe
```
There is also another simplified way:
```
$> stack run
```
It automatically compiles the project in the .stack-work/ folder and executes it.
This is a shortcut command defined in the package [stack-run](https://hackage.haskell.org/package/stack-run),
which can be installed as follows:
```
$> stack install stack-run
```

### Development

For developing the server, the package [yesod-bin](https://hackage.haskell.org/package/yesod-bin)
is used with the version specified in the snapshot resolver. For its installation:
```
$> stack install yesod-bin
```
Running the command below calls the main function in app/devel.hs
and starts the server:
```
$> yesod devel
```
The project code will be recompiled whenever a file is modified and the server
will be relaunched. Therefore, the tedious work of compiling and running the code
is automatized.
