# chat-server-haskell

A simple chat server made with Haskell using the
[Yesod framework](https://www.yesodweb.com/). It is implemented taking
advantage of the STM technology for clients concurrency.

## Build

### Environment

This project has been developed under Windows with the following Haskell
platform, which is available to download [here](https://downloads.haskell.org/~platform/8.0.2/):
- [GHC](https://www.haskell.org/ghc/) (Glasgow Haskell Compiler) version 8.0.2:
Support of the [Haskell 2010 language](https://wiki.haskell.org/Language_and_library_specification).

- [Stack tool](https://docs.haskellstack.org/) version 1.3.2: Compile and
run a Haskell project allowing several commands such as `build`, `run` and `clean`.

- [hpack](https://github.com/sol/hpack) version 0.15.0: Build the cabal package
file from the package.yaml during compilation.

- [Snapshot resolver](https://www.stackage.org) lts-8.18: Specify the GHC version
to use and the versions of package dependencies. This is configured in the
stack.yaml file.

For newer versions, the installation setup has changed, whose instructions can
be found in the official [Haskell site](https://www.haskell.org/downloads/).

### Production

For running the server in production mode, write the following stack command:
```
$> stack run
```
It automatically compiles the project in the .stack-work/ folder. It may take
some time if it is the first time installing the package dependencies defined in
the package.yaml file.

### Development

For developing the server, the package [yesod-bin](https://hackage.haskell.org/package/yesod-bin)
is used with the version 1.5.2.3 specified in the snapshot resolver. For its
installation:
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
