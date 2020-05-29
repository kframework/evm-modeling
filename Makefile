# Settings
# --------

DEPS_DIR      := deps
BUILD_DIR     := .build
SUBDEFN_DIR   := .
DEFN_BASE_DIR := $(BUILD_DIR)/defn
DEFN_DIR      := $(DEFN_BASE_DIR)/$(SUBDEFN_DIR)
BUILD_LOCAL   := $(abspath $(BUILD_DIR)/local)
LOCAL_LIB     := $(BUILD_LOCAL)/lib

K_SUBMODULE := $(DEPS_DIR)/k
ifneq (,$(wildcard $(K_SUBMODULE)/k-distribution/target/release/k/bin/*))
    K_RELEASE ?= $(abspath $(K_SUBMODULE)/k-distribution/target/release/k)
else
    K_RELEASE ?= $(dir $(shell which kompile))..
endif
K_BIN := $(K_RELEASE)/bin
K_LIB := $(K_RELEASE)/lib/kframework
export K_RELEASE

LIBRARY_PATH       := $(LOCAL_LIB)
C_INCLUDE_PATH     += :$(BUILD_LOCAL)/include
CPLUS_INCLUDE_PATH += :$(BUILD_LOCAL)/include
PATH               := $(K_BIN):$(PATH)

export LIBRARY_PATH
export C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH
export PATH

PLUGIN_SUBMODULE := $(abspath $(DEPS_DIR)/plugin)
export PLUGIN_SUBMODULE

# need relative path for `pandoc` on MacOS
PANDOC_TANGLE_SUBMODULE := $(DEPS_DIR)/pandoc-tangle
TANGLER                 := $(PANDOC_TANGLE_SUBMODULE)/tangle.lua
LUA_PATH                := $(PANDOC_TANGLE_SUBMODULE)/?.lua;;
export TANGLER
export LUA_PATH

.PHONY: all clean distclean                                                                                                      \
        deps all-deps llvm-deps haskell-deps repo-deps k-deps plugin-deps libsecp256k1 libff                                     \
        build build-java build-specs build-haskell build-llvm build-web3                                                         \
        defn java-defn specs-defn web3-defn haskell-defn llvm-defn                                                               \
        test test-all test-conformance test-rest-conformance test-all-conformance test-slow-conformance test-failing-conformance \
        test-vm test-rest-vm test-all-vm test-bchain test-rest-bchain test-all-bchain                                            \
        test-web3 test-all-web3 test-failing-web3                                                                                \
        test-prove test-failing-prove                                                                                            \
        test-prove-benchmarks test-prove-functional test-prove-opcodes test-prove-erc20 test-prove-bihu test-prove-examples      \
        test-prove-imp-specs test-klab-prove                                                                                     \
        test-parse test-failure                                                                                                  \
        test-interactive test-interactive-help test-interactive-run test-interactive-prove test-interactive-search               \
        media media-pdf metropolis-theme
.SECONDARY:

all: build

clean:
	rm -rf $(DEFN_BASE_DIR)

distclean:
	rm -rf $(BUILD_DIR)
	git clean -dffx -- tests/

# Non-K Dependencies
# ------------------

libsecp256k1_out := $(LOCAL_LIB)/pkgconfig/libsecp256k1.pc
libff_out        := $(LOCAL_LIB)/libff.a

libsecp256k1: $(libsecp256k1_out)
libff:        $(libff_out)

$(libsecp256k1_out): $(PLUGIN_SUBMODULE)/deps/secp256k1/autogen.sh
	cd $(PLUGIN_SUBMODULE)/deps/secp256k1                                 \
	    && ./autogen.sh                                                   \
	    && ./configure --enable-module-recovery --prefix="$(BUILD_LOCAL)" \
	    && $(MAKE)                                                        \
	    && $(MAKE) install

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
    LIBFF_CMAKE_FLAGS=
else
    LIBFF_CMAKE_FLAGS=-DWITH_PROCPS=OFF
endif

$(libff_out): $(PLUGIN_SUBMODULE)/deps/libff/CMakeLists.txt
	@mkdir -p $(PLUGIN_SUBMODULE)/deps/libff/build
	cd $(PLUGIN_SUBMODULE)/deps/libff/build                                                               \
	    && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(BUILD_LOCAL) $(LIBFF_CMAKE_FLAGS) \
	    && make -s -j4                                                                                    \
	    && make install

# K Dependencies
# --------------

K_JAR := $(K_SUBMODULE)/k-distribution/target/release/k/lib/java/kernel-1.0-SNAPSHOT.jar

deps: repo-deps
repo-deps: tangle-deps k-deps plugin-deps
k-deps: $(K_JAR)
tangle-deps: $(TANGLER)
plugin-deps: $(PLUGIN_SUBMODULE)/client-c/main.cpp

ifneq ($(RELEASE),)
    K_BUILD_TYPE         := FastBuild
    SEMANTICS_BUILD_TYPE := Release
    KOMPILE_OPTS         += -O3
else
    K_BUILD_TYPE         := FastBuild
    SEMANTICS_BUILD_TYPE := Debug
endif

$(K_JAR):
	cd $(K_SUBMODULE) && mvn package -DskipTests -U -Dproject.build.type=$(K_BUILD_TYPE)

# Building
# --------

SOURCE_FILES       := asm           \
                      data          \
                      driver        \
                      edsl          \
                      evm           \
                      evm-imp-specs \
                      evm-types     \
                      json          \
                      krypto        \
                      network       \
                      serialization \
                      state-loader  \
                      web3
EXTRA_SOURCE_FILES :=
ALL_FILES          := $(patsubst %, %.k, $(SOURCE_FILES) $(EXTRA_SOURCE_FILES))

concrete_tangle := .k:not(.symbolic):not(.nobytes):not(.memmap),.concrete,.bytes,.membytes
java_tangle     := .k:not(.concrete):not(.bytes):not(.memmap):not(.membytes),.symbolic,.nobytes
haskell_tangle  := .k:not(.concrete):not(.nobytes):not(.memmap),.symbolic,.bytes,.membytes

defn: llvm-defn java-defn specs-defn haskell-defn web3-defn
build: build-llvm build-haskell build-java build-specs build-web3

# Java

java_dir           := $(DEFN_DIR)/java
java_files         := $(patsubst %, $(java_dir)/%, $(ALL_FILES))
java_main_module   := ETHEREUM-SIMULATION
java_syntax_module := $(java_main_module)
java_main_file     := driver
java_kompiled      := $(java_dir)/$(java_main_file)-kompiled/timestamp

java-defn:  $(java_files)
build-java: $(java_kompiled)

$(java_dir)/%.k: %.md $(TANGLER)
	@mkdir -p $(java_dir)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:"$(java_tangle)" $< > $@

$(java_kompiled): $(java_files)
	kompile --debug --main-module $(java_main_module) --backend java              \
	        --syntax-module $(java_syntax_module) $(java_dir)/$(java_main_file).k \
	        --directory $(java_dir) -I $(java_dir)                                \
	        $(KOMPILE_OPTS)

# Imperative Specs

specs_dir           := $(DEFN_DIR)/specs
specs_files         := $(patsubst %, $(specs_dir)/%, $(ALL_FILES))
specs_main_module   := EVM-IMP-SPECS
specs_syntax_module := $(specs_main_module)
specs_main_file     := evm-imp-specs
specs_kompiled      := $(specs_dir)/$(specs_main_file)-kompiled/timestamp

specs-defn:  $(specs_files)
build-specs: $(specs_kompiled)

$(specs_dir)/%.k: %.md $(TANGLER)
	@mkdir -p $(specs_dir)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:"$(java_tangle)" $< > $@

$(specs_kompiled): $(specs_files)
	kompile --debug --main-module $(specs_main_module) --backend java                \
	        --syntax-module $(specs_syntax_module) $(specs_dir)/$(specs_main_file).k \
	        --directory $(specs_dir) -I $(specs_dir)                                 \
	        $(KOMPILE_OPTS)

# Haskell

haskell_dir            := $(DEFN_DIR)/haskell
haskell_files          := $(patsubst %, $(haskell_dir)/%, $(ALL_FILES))
haskell_main_module    := ETHEREUM-SIMULATION
haskell_syntax_module  := $(haskell_main_module)
haskell_main_file      := driver
haskell_kompiled       := $(haskell_dir)/$(haskell_main_file)-kompiled/definition.kore

haskell-defn:  $(haskell_files)
build-haskell: $(haskell_kompiled)

$(haskell_dir)/%.k: %.md $(TANGLER)
	@mkdir -p $(haskell_dir)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:"$(haskell_tangle)" $< > $@

$(haskell_kompiled): $(haskell_files)
	kompile --debug --main-module $(haskell_main_module) --backend haskell --hook-namespaces KRYPTO \
	        --syntax-module $(haskell_syntax_module) $(haskell_dir)/$(haskell_main_file).k          \
	        --directory $(haskell_dir) -I $(haskell_dir)                                            \
	        $(KOMPILE_OPTS)

# Web3

web3_dir           := $(abspath $(DEFN_DIR)/web3)
web3_files         := $(patsubst %, $(web3_dir)/%, $(ALL_FILES))
web3_main_module   := WEB3
web3_syntax_module := $(web3_main_module)
web3_main_file     := web3
web3_kompiled      := $(web3_dir)/build/kevm-client
web3_kore          := $(web3_dir)/$(web3_main_file)-kompiled/definition.kore
export web3_main_file
export web3_dir

web3-defn:  $(web3_files)
build-web3: $(web3_kompiled)

$(web3_dir)/%.k: %.md $(TANGLER)
	@mkdir -p $(web3_dir)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:"$(concrete_tangle)" $< > $@

$(web3_kore): $(web3_files)
	kompile --debug --main-module $(web3_main_module) --backend llvm              \
	        --syntax-module $(web3_syntax_module) $(web3_dir)/$(web3_main_file).k \
	        --directory $(web3_dir) -I $(web3_dir)                                \
	        --hook-namespaces "KRYPTO JSON"                                       \
	        --no-llvm-kompile                                                     \
	        $(KOMPILE_OPTS)

$(web3_kompiled): $(web3_kore) $(libff_out)
	@mkdir -p $(web3_dir)/build
	cd $(web3_dir)/build && cmake $(CURDIR)/cmake/client -DCMAKE_BUILD_TYPE=$(SEMANTICS_BUILD_TYPE) && $(MAKE)

# Standalone

llvm_dir           := $(DEFN_DIR)/llvm
llvm_main_module   := ETHEREUM-SIMULATION
llvm_syntax_module := $(llvm_main_module)
llvm_main_file     := driver
llvm_kompiled      := $(llvm_dir)/$(llvm_main_file)-kompiled/interpreter

STANDALONE_KOMPILE_OPTS := -L$(LOCAL_LIB) -I$(K_RELEASE)/include/kllvm \
                           $(PLUGIN_SUBMODULE)/plugin-c/crypto.cpp     \
                           $(PLUGIN_SUBMODULE)/plugin-c/blake2.cpp     \
                           -g -std=c++14 -lff -lcryptopp -lsecp256k1

llvm-defn:  $(llvm_files)
build-llvm: $(llvm_kompiled)

$(llvm_dir)/%.k: %.md $(TANGLER)
	@mkdir -p $(llvm_dir)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:"$(concrete_tangle)" $< > $@

ifeq ($(UNAME_S),Linux)
    STANDALONE_KOMPILE_OPTS += -lprocps
endif

$(llvm_kompiled): $(llvm_files) $(libff_out)
	kompile --debug --main-module $(llvm_main_module) --backend llvm              \
	        --syntax-module $(llvm_syntax_module) $(llvm_dir)/$(llvm_main_file).k \
	        --directory $(llvm_dir) -I $(llvm_dir)                                \
	        --hook-namespaces KRYPTO                                              \
	        $(KOMPILE_OPTS)                                                       \
	        $(addprefix -ccopt ,$(STANDALONE_KOMPILE_OPTS))

# Installing
# ----------

KEVM_RELEASE_TAG ?=

release.md: INSTALL.md
	echo "KEVM Release $(KEVM_RELEASE_TAG)"  > $@
	echo                                    >> $@
	cat INSTALL.md                          >> $@

# Tests
# -----

TEST_CONCRETE_BACKEND := llvm
TEST_SYMBOLIC_BACKEND := java

TEST         := ./kevm
TEST_OPTIONS :=
CHECK        := git --no-pager diff --no-index --ignore-all-space -R

KEVM_MODE     := NORMAL
KEVM_SCHEDULE := ISTANBUL
KEVM_CHAINID  := 1

KEVM_WEB3_ARGS := --shutdownable --respond-to-notifications

KPROVE_MODULE  := VERIFICATION
KPROVE_OPTIONS :=

test-all: test-all-conformance test-prove test-interactive test-parse
test: test-conformance test-prove test-interactive test-parse

# Generic Test Harnesses

tests/ethereum-tests/VMTests/%: KEVM_MODE=VMTESTS
tests/ethereum-tests/VMTests/%: KEVM_SCHEDULE=DEFAULT

tests/%.run: tests/%
	MODE=$(KEVM_MODE) SCHEDULE=$(KEVM_SCHEDULE) CHAINID=$(KEVM_CHAINID)                                                \
	    $(TEST) interpret $(TEST_OPTIONS) --backend $(TEST_CONCRETE_BACKEND)                                           \
	    $< > tests/$*.$(TEST_CONCRETE_BACKEND)-out                                                                     \
	    || $(CHECK) tests/$*.$(TEST_CONCRETE_BACKEND)-out tests/templates/output-success-$(TEST_CONCRETE_BACKEND).json
	rm -rf tests/$*.$(TEST_CONCRETE_BACKEND)-out

tests/%.run-interactive: tests/%
	MODE=$(KEVM_MODE) SCHEDULE=$(KEVM_SCHEDULE) CHAINID=$(KEVM_CHAINID)                                                \
	    $(TEST) run $(TEST_OPTIONS) --backend $(TEST_CONCRETE_BACKEND)                                                 \
	    $< > tests/$*.$(TEST_CONCRETE_BACKEND)-out                                                                     \
	    || $(CHECK) tests/$*.$(TEST_CONCRETE_BACKEND)-out tests/templates/output-success-$(TEST_CONCRETE_BACKEND).json
	rm -rf tests/$*.$(TEST_CONCRETE_BACKEND)-out

tests/%.run-expected: tests/% tests/%.expected
	MODE=$(KEVM_MODE) SCHEDULE=$(KEVM_SCHEDULE) CHAINID=$(KEVM_CHAINID)                                                \
	    $(TEST) run $(TEST_OPTIONS) --backend $(TEST_CONCRETE_BACKEND)                                                 \
	    $< > tests/$*.$(TEST_CONCRETE_BACKEND)-out                                                                     \
	    || $(CHECK) tests/$*.$(TEST_CONCRETE_BACKEND)-out tests/$*.expected
	rm -rf tests/$*.$(TEST_CONCRETE_BACKEND)-out

tests/web3/no-shutdown/%: KEVM_WEB3_ARGS=

tests/%.run-web3: tests/%.in.json
	tests/web3/runtest.sh $< tests/$*.out.json $(KEVM_WEB3_ARGS)
	$(CHECK) tests/$*.out.json tests/$*.expected.json
	rm -rf tests/$*.out.json

tests/%.parse: tests/%
	$(TEST) kast $(TEST_OPTIONS) --backend $(TEST_CONCRETE_BACKEND) $< kast > $@-out
	$(CHECK) $@-out $@-expected
	rm -rf $@-out

tests/specs/functional/%.prove: TEST_SYMBOLIC_BACKEND=haskell
tests/specs/examples/%.prove:   TEST_SYMBOLIC_BACKEND=haskell

tests/specs/functional/storageRoot-spec.k.prove: TEST_SYMBOLIC_BACKEND=java
tests/specs/functional/lemmas-no-smt-spec.k.prove: KPROVE_OPTIONS+=--haskell-backend-command "kore-exec --smt=none"
tests/specs/erc20/hkg/totalSupply-spec.k.prove: TEST_SYMBOLIC_BACKEND=haskell

tests/%.prove: tests/%
	$(TEST) prove $(TEST_OPTIONS) --backend $(TEST_SYMBOLIC_BACKEND) $< $(KPROVE_MODULE) --format-failures $(KPROVE_OPTIONS) \
	    --concrete-rules $(shell cat $(dir $@)concrete-rules.txt | tr '\n' ',') > $@.out ||                                  \
	    $(CHECK) $@.out $@.expected
	rm -rf $@.out

tests/specs/imp-specs/%.prove: tests/specs/imp-specs/%
	$(TEST) prove $(TEST_OPTIONS) --backend-dir $(specs_dir) \
		--backend $(TEST_SYMBOLIC_BACKEND) $< $(KPROVE_MODULE) --format-failures $(KPROVE_OPTIONS) \
	    --concrete-rules $(shell cat $(dir $@)concrete-rules.txt | tr '\n' ',') > $@.out ||                                  \
	    $(CHECK) $@.out $@.expected
	rm -rf $@.out

tests/%.search: tests/%
	$(TEST) search $(TEST_OPTIONS) --backend $(TEST_SYMBOLIC_BACKEND) $< "<statusCode> EVMC_INVALID_INSTRUCTION </statusCode>" > $@-out
	$(CHECK) $@-out $@-expected
	rm -rf $@-out

tests/%.klab-prove: tests/%
	$(TEST) klab-prove $(TEST_OPTIONS) --backend $(TEST_SYMBOLIC_BACKEND) $< $(KPROVE_MODULE) --format-failures $(KPROVE_OPTIONS) \
	    --concrete-rules $(shell cat $(dir $@)concrete-rules.txt | tr '\n' ',')

# Smoke Tests

smoke_tests_run=tests/ethereum-tests/VMTests/vmArithmeticTest/add0.json \
                tests/ethereum-tests/VMTests/vmIOandFlowOperations/pop1.json \
                tests/interactive/sumTo10.evm

smoke_tests_prove=tests/specs/erc20/ds/transfer-failure-1-a-spec.k

# Conformance Tests

tests/ethereum-tests/%.json: tests/ethereum-tests/make.timestamp

slow_conformance_tests    = $(shell cat tests/slow.$(TEST_CONCRETE_BACKEND))    # timeout after 20s
failing_conformance_tests = $(shell cat tests/failing.$(TEST_CONCRETE_BACKEND))

test-all-conformance: test-all-vm test-all-bchain
test-rest-conformance: test-rest-vm test-rest-bchain
test-slow-conformance: $(slow_conformance_tests:=.run)
test-failing-conformance: $(failing_conformance_tests:=.run)
test-conformance: test-vm test-bchain

all_vm_tests     = $(wildcard tests/ethereum-tests/VMTests/*/*.json)
quick_vm_tests   = $(filter-out $(slow_conformance_tests), $(all_vm_tests))
passing_vm_tests = $(filter-out $(failing_conformance_tests), $(quick_vm_tests))
rest_vm_tests    = $(filter-out $(passing_vm_tests), $(all_vm_tests))

test-all-vm: $(all_vm_tests:=.run)
test-rest-vm: $(rest_vm_tests:=.run)
test-vm: $(passing_vm_tests:=.run)

all_bchain_tests     = $(wildcard tests/ethereum-tests/BlockchainTests/GeneralStateTests/*/*.json)                            \
                       $(wildcard tests/ethereum-tests/LegacyTests/Constantinople/BlockchainTests/GeneralStateTests/*/*.json)
quick_bchain_tests   = $(filter-out $(slow_conformance_tests), $(all_bchain_tests))
passing_bchain_tests = $(filter-out $(failing_conformance_tests), $(quick_bchain_tests))
rest_bchain_tests    = $(filter-out $(passing_bchain_tests), $(all_bchain_tests))

test-all-bchain: $(all_bchain_tests:=.run)
test-rest-bchain: $(rest_bchain_tests:=.run)
test-bchain: $(passing_bchain_tests:=.run)

# Web3 Tests

all_web3_tests     = $(wildcard tests/web3/*.in.json) $(wildcard tests/web3/*/*.in.json)
failing_web3_tests = $(shell cat tests/failing.web3)
passing_web3_tests = $(filter-out $(failing_web3_tests), $(all_web3_tests))

test-all-web3: $(all_web3_tests:.in.json=.run-web3)
test-failing-web3: $(failing_web3_tests:.in.json=.run-web3)
test-web3: $(passing_web3_tests:.in.json=.run-web3)

# Proof Tests

prove_specs_dir        := tests/specs
prove_failing_tests    := $(shell cat tests/failing-symbolic.$(TEST_SYMBOLIC_BACKEND))
prove_benchmarks_tests := $(filter-out $(prove_failing_tests), $(wildcard $(prove_specs_dir)/benchmarks/*-spec.k))
prove_functional_tests := $(filter-out $(prove_failing_tests), $(wildcard $(prove_specs_dir)/functional/*-spec.k))
prove_opcodes_tests    := $(filter-out $(prove_failing_tests), $(wildcard $(prove_specs_dir)/opcodes/*-spec.k))
prove_erc20_tests      := $(filter-out $(prove_failing_tests), $(wildcard $(prove_specs_dir)/erc20/*/*-spec.k))
prove_bihu_tests       := $(filter-out $(prove_failing_tests), $(wildcard $(prove_specs_dir)/bihu/*-spec.k))
prove_examples_tests   := $(filter-out $(prove_failing_tests), $(wildcard $(prove_specs_dir)/examples/*-spec.k))
prove_imp_specs_tests  := $(filter-out $(prove_failing_tests), $(wildcard $(prove_specs_dir)/imp-specs/*-spec.k))

test-prove: test-prove-benchmarks test-prove-functional test-prove-opcodes test-prove-erc20 test-prove-bihu test-prove-examples test-prove-imp-specs
test-prove-benchmarks: $(prove_benchmarks_tests:=.prove)
test-prove-functional: $(prove_functional_tests:=.prove)
test-prove-opcodes:    $(prove_opcodes_tests:=.prove)
test-prove-erc20:      $(prove_erc20_tests:=.prove)
test-prove-bihu:       $(prove_bihu_tests:=.prove)
test-prove-examples:   $(prove_examples_tests:=.prove)
test-prove-imp-specs:  $(prove_imp_specs_tests:=.prove)

test-failing-prove: $(prove_failing_tests:=.prove)

test-klab-prove: $(smoke_tests_prove:=.klab-prove)

# Parse Tests

parse_tests:=$(wildcard tests/interactive/*.json) \
             $(wildcard tests/interactive/*.evm)

test-parse: $(parse_tests:=.parse)
	echo $(parse_tests)

# Failing correctly tests

failure_tests:=$(wildcard tests/failing/*.json)

test-failure: $(failure_tests:=.run-expected)

# Interactive Tests

test-interactive: test-interactive-run test-interactive-prove test-interactive-search test-interactive-help

test-interactive-run: $(smoke_tests_run:=.run-interactive)
test-interactive-prove: $(smoke_tests_prove:=.prove)

search_tests:=$(wildcard tests/interactive/search/*.evm)
test-interactive-search: $(search_tests:=.search)

test-interactive-help:
	$(TEST) help

# Media
# -----

media: media-pdf

### Media generated PDFs

media_pdfs := 201710-presentation-devcon3                          \
              201801-presentation-csf                              \
              201905-exercise-k-workshop                           \
              201908-trufflecon-workshop 201908-trufflecon-firefly

media/%.pdf: media/%.md media/citations.md
	@mkdir -p $(dir $@)
	cat $^ | pandoc --from markdown --filter pandoc-citeproc --to beamer --output $@

media-pdf: $(patsubst %, media/%.pdf, $(media_pdfs))

metropolis-theme: $(BUILD_DIR)/media/metropolis/beamerthememetropolis.sty

$(BUILD_DIR)/media/metropolis/beamerthememetropolis.sty:
	cd $(dir $@) && $(MAKE)
