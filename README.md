KEVM: Semantics of EVM in K
===========================

In this repository we provide a model of the EVM in K.

Documentation/Support
---------------------

These may be useful for learning KEVM and K (newest to oldest):

-   [Jello Paper], generated using [Sphinx Documentation Generation].
-   [20 minute tour of the semantics](https://www.youtube.com/watch?v=tIq_xECoicQNov) at [2017 Devcon3].
-   [KEVM 1.0 technical report](http://hdl.handle.net/2142/97207), especially sections 3 and 5.
-   [KEVM Paper at CSF'18/FLoC](http://fsl.cs.illinois.edu/index.php/KEVM:_A_Complete_Semantics_of_the_Ethereum_Virtual_Machine).

To get support for KEVM, please join our [Riot Room](https://riot.im/app/#/room/#k:matrix.org).

Repository Structure
--------------------

The following files constitute the KEVM semantics:

-   [krypto.md](krypto.md) sets up some basic cryptographic primitives.
-   [data.md](data.md) provides the (functional) data of EVM (256 bit words, wordstacks, etc...).
-   [network.md](network.md) provides the status codes which are reported to an Ethereum client on execution exceptions.
-   [evm.md](evm.md) is the main KEVM semantics, containing the configuration and transition rules of EVM.

These additional files extend the semantics to make the repository more useful:

-   [driver.md](driver.md) is an execution harness for KEVM, providing a simple language for describing tests/programs.
-   [edsl.md](edsl.md) defines high-level notations of [eDSL], a domain-specific language for EVM specifications, for formal verification of EVM bytecode using [K Reachability Logic Prover].
-   [evm-node.md](evm-node.md) is the protobuf interface that an external Ethereum client can connect to for using KEVM as the execution engine.

Installing/Building
-------------------

### K Backends

There are four backends of K available: LLVM (default) and OCaml for concrete execution and Java (default) and Haskell for symbolic execution.
This repository generates the build-products for each backend in `.build/defn/`.

### System Dependencies

The following are needed for building/running KEVM:

-   [git](https://git-scm.com/)
-   [Pandoc >= 1.17](https://pandoc.org) is used to generate the `*.k` files from the `*.md` files.
-   GNU [Bison](https://www.gnu.org/software/bison/), [Flex](https://github.com/westes/flex), and [Autoconf](http://www.gnu.org/software/autoconf/).
-   GNU [libmpfr](http://www.mpfr.org/) and [libtool](https://www.gnu.org/software/libtool/).
-   Java 8 JDK (eg. [OpenJDK](http://openjdk.java.net/))
-   [Opam](https://opam.ocaml.org/doc/Install.html), **important**: Ubuntu users prior to 15.04 **must** build from source, as the Ubuntu install for 14.10 and prior is broken.
    `opam repository` also requires `rsync`.

On Ubuntu >= 18.04 (for example):

```sh
sudo apt install                                                       \
            autoconf bison clang++-8 clang-8 cmake curl flex gcc git   \
            libboost-test-dev libgmp-dev libjemalloc-dev libmpfr-dev   \
            libprocps-dev libprotobuf-dev libsecp256k1-dev libtool     \
            libyaml-dev libz3-dev lld-8 llvm-8 llvm-8-tools make maven \
            opam openjdk-11-jdk pandoc pkg-config protobuf-compiler    \
            z3 zlib1g-dev
```

On Ubuntu < 18.04, you'll need to skip `libsecp256k1-dev` and instead build it from source (via our `Makefile`):

```sh
make libsecp256k1
```

On ArchLinux:

```sh
sudo pacman -S                                              \
    base base-devel boost clang cmake crypto++ curl git gmp \
    jdk-openjdk jemalloc libsecp256k1 lld llvm maven mpfr   \
    opam python stack yaml-cpp z3 zlib
```

On OSX, using [Homebrew](https://brew.sh/), after installing the command line tools package:

```sh
brew tap caskroom/cask
brew cask install adoptopenjdk12
brew install automake libtool gmp mpfr pkg-config pandoc maven opam z3 libffi
make libsecp256k1
```

NOTE: a previous version of these instructions required the user to run `brew link flex --force`.
After fetching this revision, you should first run `brew unlink flex`, as it is no longer necessary and will cause an error if you have the homebrew version of flex installed instead of the xcode command line tools version.

-   [Haskell Stack](https://docs.haskellstack.org/en/stable/install_and_upgrade/#installupgrade).
    Note that the version of the `stack` tool provided by your package manager might not be recent enough.
    Please follow installation instructions from the Haskell Stack website linked above.

To upgrade `stack` (if needed):

```sh
stack upgrade
export PATH=$HOME/.local/bin:$PATH
```

### Build K Dependency

Get the submodules:

```sh
git submodule update --init --recursive
```

If you haven't already setup K's OCaml dependencies more recently than February 1, 2019, then you also need to setup the K OCaml dependencies (**not** needed if you don't intend to use the OCaml backend):

```sh
./deps/k/k-distribution/src/main/scripts/bin/k-configure-opam-dev
```

And finally build the repository specific dependencies:

```sh
make deps
```

On Arch, instead do:

```sh
make LIBFF_CC=clang LIBFF_CXX=clang++ deps
```

### Building

Finally, you can install repository specific dependencies and build the semantics:

```sh
make build
```

You can also build specific backends as so:

```sh
make build-haskell
make build-llvm
make build-java
make build-ocaml
```

### Installing

To install the `kevm-vm` binary for use in Firefly and other full-nodes, do:

```sh
make install
```

You can set `DESTDIR` and `INSTALL_PREFIX` to change where the installation goes.

Example Usage
-------------

After building the definition, you can run the definition using `./kevm`.
Read the `./kevm` script for examples of the actual invocations of `krun` that `./kevm` makes.

Run the file `tests/ethereum-tests/VMTests/vmArithmeticTest/add0.json`:

```sh
./kevm run tests/ethereum-tests/VMTests/vmArithmeticTest/add0.json
```

To run proofs, you can similarly use `./kevm`.
For example, to prove one of the specifications:

```sh
./kevm prove tests/specs/ds-token-erc20/transfer-failure-1-a-spec.k -m VERIFICATION
```

Running Tests
-------------

The tests are run using the supplied `Makefile`.
First, run `make split-tests` to generate some of the tests from the markdown files.

The following subsume all other tests:

-   `make test`: All of the quick tests.
-   `make test-all`: All of the quick and slow tests.

These are the individual test-suites (all of these can be suffixed with `-all` to also run slow tests):

-   `make test-vm`: VMTests from the [Ethereum Test Set].
-   `make test-bchain`: Subset of BlockchainTests from the [Ethereum Test Set].
-   `make test-proof`: Proofs from the [Verified Smart Contracts].
-   `make test-interactive`: Tests of the `./kevm` command.

When running tests with the `Makefile`, you can specify the `TEST_CONCRETE_BACKEND` (for concrete tests), or `TEST_SYMBOLIC_BACKEND` (for proofs).

Media
-----

This repository can build two pieces of documentation for you, the [Jello Paper] and the [2017 Devcon3] presentation.

### System Dependencies

If you also want to build the [Jello Paper], you'll additionally need:

-   [Sphinx Documentation Generation] tool, and
-   The [K Editor Support] Python `pygments` package.

```sh
sudo apt install python-pygments python-sphinx python-recommonmark
git clone 'https://github.com/kframework/k-editor-support'
cd k-editor-support/pygments
easy_install --user .
```

For the [2017 Devcon3] presentation, you'll need `pdflatex`, commonly provided with `texlive-full`.

```sh
sudo apt install texlive-full
```

### Building

The Makefile supplies targets for building:

-   All media in this list: `make media`
-   [Jello Paper] documentation: `make sphinx`
-   [2017 Devcon3] presentation: `make 2017-devcon3`

Resources
=========

-   [EVM Yellowpaper](https://github.com/ethereum/yellowpaper): Original specification of EVM.
-   [LEM Semantics of EVM](https://github.com/pirapira/eth-isabelle)

For more information about [The K Framework](http://kframework.org), refer to these sources:

-   [The K Tutorial](https://github.com/kframework/k/tree/master/k-distribution/tutorial)
-   [Semantics-Based Program Verifiers for All Languages](http://fsl.cs.illinois.edu/index.php/Semantics-Based_Program_Verifiers_for_All_Languages)
-   [Reachability Logic Resources](http://fsl.cs.illinois.edu/index.php/Reachability_Logic_in_K)
-   [Matching Logic Resources](http://fsl.cs.illinois.edu/index.php/Matching_Logic)
-   [Logical Frameworks](http://dl.acm.org/citation.cfm?id=208700): Discussion of logical frameworks.

[Jello Paper]: <https://jellopaper.org>
[2017 Devcon3]: <https://ethereumfoundation.org/devcon3/>
[Sphinx Documentation Generation]: <http://sphinx-doc.org>
[K Reachability Logic Prover]: <http://fsl.cs.illinois.edu/FSL/papers/2016/stefanescu-park-yuwen-li-rosu-2016-oopsla/stefanescu-park-yuwen-li-rosu-2016-oopsla-public.pdf>
[K Editor Support]: <https://github.com/kframework/k-editor-support>
[Ethereum Test Set]: <https://github.com/ethereum/tests>
[Verified Smart Contracts]: <https://github.com/runtimeverification/verified-smart-contracts>
[eDSL]: <https://github.com/runtimeverification/verified-smart-contracts/blob/master/resources/edsl.md>
