Data-Structures over `Word`
===========================

EVM uses bounded 256 bit integer words, and sometimes also bytes (8 bit words).
Here we provide the arithmetic of these words, as well as some data-structures over them.
Both are implemented using K's `Int`.

```k
module EVM-TYPES
    imports INT
    imports STRING
    imports COLLECTIONS
```

```{.k .bytes}
    imports BYTES
```

Utilities
---------

### Important Powers

Some important numbers that are referred to often during execution.
These can be used for pattern-matching on the LHS of rules as well (`macro` attribute expands all occurances of these in rules).

```k
    syntax Int ::= "pow256" /* 2 ^Int 256 */
                 | "pow255" /* 2 ^Int 255 */
                 | "pow224" /* 2 ^Int 224 */
                 | "pow208" /* 2 ^Int 208 */
                 | "pow168" /* 2 ^Int 168 */
                 | "pow160" /* 2 ^Int 160 */
                 | "pow128" /* 2 ^Int 128 */
                 | "pow96"  /* 2 ^Int 96  */
                 | "pow48"  /* 2 ^Int 48  */
                 | "pow16"  /* 2 ^Int 16  */
 // ----------------------------------------
    rule pow256 => 115792089237316195423570985008687907853269984665640564039457584007913129639936 [macro]
    rule pow255 => 57896044618658097711785492504343953926634992332820282019728792003956564819968  [macro]
    rule pow224 => 26959946667150639794667015087019630673637144422540572481103610249216           [macro]
    rule pow208 => 411376139330301510538742295639337626245683966408394965837152256                [macro]
    rule pow168 => 374144419156711147060143317175368453031918731001856                            [macro]
    rule pow160 => 1461501637330902918203684832716283019655932542976                              [macro]
    rule pow128 => 340282366920938463463374607431768211456                                        [macro]
    rule pow96  => 79228162514264337593543950336                                                  [macro]
    rule pow48  => 281474976710656                                                                [macro]
    rule pow16  => 65536                                                                          [macro]

    syntax Int ::= "minSInt128"
                 | "maxSInt128"
                 | "minUInt8"
                 | "maxUInt8"
                 | "minUInt16"
                 | "maxUInt16"
                 | "minUInt48"
                 | "maxUInt48"
                 | "minUInt96"
                 | "maxUInt96"
                 | "minUInt128"
                 | "maxUInt128"
                 | "minUInt160"
                 | "maxUInt160"
                 | "minUInt168"
                 | "maxUInt168"
                 | "minUInt208"
                 | "maxUInt208"
                 | "minUInt224"
                 | "maxUInt224"
                 | "minSInt256"
                 | "maxSInt256"
                 | "minUInt256"
                 | "maxUInt256"
                 | "minSFixed128x10"
                 | "maxSFixed128x10"
                 | "minUFixed128x10"
                 | "maxUFixed128x10"
 // --------------------------------
    rule minSInt128      => -170141183460469231731687303715884105728                                        [macro]  /*  -2^127      */
    rule maxSInt128      =>  170141183460469231731687303715884105727                                        [macro]  /*   2^127 - 1  */
    rule minSFixed128x10 => -1701411834604692317316873037158841057280000000000                              [macro]  /* (-2^127    ) * 10^10 */
    rule maxSFixed128x10 =>  1701411834604692317316873037158841057270000000000                              [macro]  /* ( 2^127 - 1) * 10^10 */
    rule minSInt256      => -57896044618658097711785492504343953926634992332820282019728792003956564819968  [macro]  /*  -2^255      */
    rule maxSInt256      =>  57896044618658097711785492504343953926634992332820282019728792003956564819967  [macro]  /*   2^255 - 1  */

    rule minUInt8        =>  0                                                                              [macro]
    rule maxUInt8        =>  255                                                                            [macro]
    rule minUInt16       =>  0                                                                              [macro]
    rule maxUInt16       =>  65535                                                                          [macro]  /*   2^16 -  1  */
    rule minUInt48       =>  0                                                                              [macro]
    rule maxUInt48       =>  281474976710655                                                                [macro]  /*   2^48 -  1  */
    rule minUInt96       =>  0                                                                              [macro]
    rule maxUInt96       =>  79228162514264337593543950335                                                  [macro]  /*   2^96 -  1  */
    rule minUInt128      =>  0                                                                              [macro]
    rule maxUInt128      =>  340282366920938463463374607431768211455                                        [macro]  /*   2^128 - 1  */
    rule minUFixed128x10 =>  0                                                                              [macro]
    rule maxUFixed128x10 =>  3402823669209384634633746074317682114550000000000                              [macro]  /* ( 2^128 - 1) * 10^10 */
    rule minUInt160      =>  0                                                                              [macro]
    rule maxUInt160      =>  1461501637330902918203684832716283019655932542975                              [macro]  /*   2^160 - 1  */
    rule minUInt168      =>  0                                                                              [macro]
    rule maxUInt168      =>  374144419156711147060143317175368453031918731001855                            [macro]  /*   2^168 - 1  */
    rule minUInt208      =>  0                                                                              [macro]
    rule maxUInt208      =>  411376139330301510538742295639337626245683966408394965837152255                [macro]  /*   2^208 - 1  */
    rule minUInt224      =>  0                                                                              [macro]
    rule maxUInt224      =>  26959946667150639794667015087019630673637144422540572481103610249215           [macro]  /*   2^224 - 1  */
    rule minUInt256      =>  0                                                                              [macro]
    rule maxUInt256      =>  115792089237316195423570985008687907853269984665640564039457584007913129639935 [macro]  /*   2^256 - 1  */

    syntax Int ::= "eth"
 // --------------------
    rule eth => 1000000000000000000 [macro]
```

-   Range of types

```k
    syntax Bool ::= #rangeBool    ( Int )
                  | #rangeSInt    ( Int , Int )
                  | #rangeUInt    ( Int , Int )
                  | #rangeSFixed  ( Int , Int , Int )
                  | #rangeUFixed  ( Int , Int , Int )
                  | #rangeAddress ( Int )
                  | #rangeBytes   ( Int , Int )
 // -------------------------------------------
    rule #rangeBool    (            X ) => X ==Int 0 orBool X ==Int 1                         [macro]
    rule #rangeSInt    ( 128 ,      X ) => #range ( minSInt128      <= X <= maxSInt128      ) [macro]
    rule #rangeSInt    ( 256 ,      X ) => #range ( minSInt256      <= X <= maxSInt256      ) [macro]
    rule #rangeUInt    (   8 ,      X ) => #range ( minUInt8        <= X <  256             ) [macro]
    rule #rangeUInt    (  16 ,      X ) => #range ( minUInt16       <= X <  pow16           ) [macro]
    rule #rangeUInt    (  48 ,      X ) => #range ( minUInt48       <= X <  pow48           ) [macro]
    rule #rangeUInt    (  96 ,      X ) => #range ( minUInt96       <= X <  pow96           ) [macro]
    rule #rangeUInt    ( 128 ,      X ) => #range ( minUInt128      <= X <  pow128          ) [macro]
    rule #rangeUInt    ( 160 ,      X ) => #range ( minUInt160      <= X <  pow160          ) [macro]
    rule #rangeUInt    ( 168 ,      X ) => #range ( minUInt168      <= X <  pow168          ) [macro]
    rule #rangeUInt    ( 208 ,      X ) => #range ( minUInt208      <= X <  pow208          ) [macro]
    rule #rangeUInt    ( 224 ,      X ) => #range ( minUInt224      <= X <  pow224          ) [macro]
    rule #rangeUInt    ( 256 ,      X ) => #range ( minUInt256      <= X <  pow256          ) [macro]
    rule #rangeSFixed  ( 128 , 10 , X ) => #range ( minSFixed128x10 <= X <= maxSFixed128x10 ) [macro]
    rule #rangeUFixed  ( 128 , 10 , X ) => #range ( minUFixed128x10 <= X <= maxUFixed128x10 ) [macro]
    rule #rangeAddress (            X ) => #range ( minUInt160      <= X <  pow160          ) [macro]
    rule #rangeBytes   (   N ,      X ) => #range ( 0               <= X <  1 <<Byte N      ) [macro]

    syntax Bool ::= "#range" "(" Int "<"  Int "<"  Int ")"
                  | "#range" "(" Int "<"  Int "<=" Int ")"
                  | "#range" "(" Int "<=" Int "<"  Int ")"
                  | "#range" "(" Int "<=" Int "<=" Int ")"
 // ------------------------------------------------------
    rule #range ( LB <  X <  UB ) => LB  <Int X andBool X  <Int UB [macro]
    rule #range ( LB <  X <= UB ) => LB  <Int X andBool X <=Int UB [macro]
    rule #range ( LB <= X <  UB ) => LB <=Int X andBool X  <Int UB [macro]
    rule #range ( LB <= X <= UB ) => LB <=Int X andBool X <=Int UB [macro]
```

-   `chop` interprets an integer modulo $2^256$.

```k
    syntax Int ::= chop ( Int ) [function, functional, smtlib(chop)]
 // ----------------------------------------------------------------
    rule chop ( I:Int ) => I modInt pow256 [concrete, smt-lemma]
```

### Boolean Conversions

Primitives provide the basic conversion from K's sorts `Int` and `Bool` to EVM's words.

-   `bool2Word` interprets a `Bool` as a `Int`.
-   `word2Bool` interprets a `Int` as a `Bool`.

```k
    syntax Int ::= bool2Word ( Bool ) [function, functional, smtlib(bool2Word)]
 // ---------------------------------------------------------------------------
    rule bool2Word( B:Bool ) => 1 requires B
    rule bool2Word( B:Bool ) => 0 requires notBool B

    syntax Bool ::= word2Bool ( Int ) [function, functional]
 // --------------------------------------------------------
    rule word2Bool( W ) => false requires W  ==Int 0
    rule word2Bool( W ) => true  requires W =/=Int 0
```

-   `sgn` gives the twos-complement interperetation of the sign of a word.
-   `abs` gives the twos-complement interperetation of the magnitude of a word.

```k
    syntax Int ::= sgn ( Int ) [function, functional]
                 | abs ( Int ) [function, functional]
 // -------------------------------------------------
    rule sgn(I) => -1 requires pow255 <=Int I andBool I <Int pow256
    rule sgn(I) =>  1 requires 0 <=Int I andBool I <Int pow255
    rule sgn(I) =>  0 requires I <Int 0 orBool pow256 <=Int I

    rule abs(I) => 0 -Word I requires sgn(I) ==Int -1
    rule abs(I) => I         requires sgn(I) ==Int  1
    rule abs(I) => 0         requires sgn(I) ==Int  0
```

Word Operations
---------------

### Low-Level

-   `up/Int` performs integer division but rounds up instead of down.

NOTE: Here, we choose to add `I2 -Int 1` to the numerator beforing doing the division to mimic the C++ implementation.
You could alternatively calculate `I1 modInt I2`, then add one to the normal integer division afterward depending on the result.

```k
    syntax Int ::= Int "up/Int" Int [function, functional, smtlib(upDivInt)]
 // ------------------------------------------------------------------------
    rule              _I1 up/Int 0  => 0
    rule              _I1 up/Int I2 => 0                             requires I2 <Int 0
    rule               I1 up/Int 1  => I1
    rule [upDivInt] :  I1 up/Int I2 => (I1 +Int (I2 -Int 1)) /Int I2 requires I2 >Int 1
```

-   `log256Int` returns the log base 256 (floored) of an integer.

```k
    syntax Int ::= log256Int ( Int ) [function]
 // -------------------------------------------
    rule log256Int(N) => log2Int(N) /Int 8
```

The corresponding `<op>Word` operations automatically perform the correct modulus for EVM words.
Warning: operands are assumed to be within the range of a 256 bit EVM word. Unbound integers may not return the correct result.

```k
    syntax Int ::= Int "+Word" Int [function, functional]
                 | Int "*Word" Int [function, functional]
                 | Int "-Word" Int [function, functional]
                 | Int "/Word" Int [function, functional]
                 | Int "%Word" Int [function, functional]
 // -----------------------------------------------------
    rule W0 +Word W1 => chop( W0 +Int W1 )
    rule W0 -Word W1 => chop( W0 -Int W1 )
    rule W0 *Word W1 => chop( W0 *Int W1 )
    rule  _ /Word W1 => 0            requires W1  ==Int 0
    rule W0 /Word W1 => W0 /Int W1   requires W1 =/=Int 0
    rule  _ %Word W1 => 0            requires W1  ==Int 0
    rule W0 %Word W1 => W0 modInt W1 requires W1 =/=Int 0
```

Care is needed for `^Word` to avoid big exponentiation.
The helper `powmod` is a totalization of the operator `_^%Int__` (which comes with K).
`_^%Int__` is not defined when the modulus (third argument) is zero, but `powmod` is.

```k
    syntax Int ::= Int "^Word" Int       [function]
    syntax Int ::= powmod(Int, Int, Int) [function, functional]
 // -----------------------------------------------------------
    rule W0 ^Word W1 => powmod(W0, W1, pow256)

    rule [powmod.nonzero]: powmod(W0, W1, W2) => W0 ^%Int W1 W2  requires W2 =/=Int 0
    rule [powmod.zero]:    powmod( _,  _, W2) => 0               requires W2  ==Int 0
```

`/sWord` and `%sWord` give the signed interperetations of `/Word` and `%Word`.

```k
    syntax Int ::= Int "/sWord" Int [function]
                 | Int "%sWord" Int [function]
 // ------------------------------------------
    rule [divSWord.same]: W0 /sWord W1 =>          abs(W0) /Word abs(W1)  requires sgn(W0) *Int sgn(W1) ==Int  1
    rule [divSWord.diff]: W0 /sWord W1 => 0 -Word (abs(W0) /Word abs(W1)) requires sgn(W0) *Int sgn(W1) ==Int -1
    rule [modSWord.pos]:  W0 %sWord W1 =>          abs(W0) %Word abs(W1)  requires sgn(W0) ==Int  1
    rule [modSWord.neg]:  W0 %sWord W1 => 0 -Word (abs(W0) %Word abs(W1)) requires sgn(W0) ==Int -1
```

### Word Comparison

The `<op>Word` comparisons similarly lift K operators to EVM ones:

```k
    syntax Int ::= Int "<Word"  Int [function, functional]
                 | Int ">Word"  Int [function, functional]
                 | Int "<=Word" Int [function, functional]
                 | Int ">=Word" Int [function, functional]
                 | Int "==Word" Int [function, functional]
 // ------------------------------------------------------
    rule W0 <Word  W1 => bool2Word(W0 <Int  W1)
    rule W0 >Word  W1 => bool2Word(W0 >Int  W1)
    rule W0 <=Word W1 => bool2Word(W0 <=Int W1)
    rule W0 >=Word W1 => bool2Word(W0 >=Int W1)
    rule W0 ==Word W1 => bool2Word(W0 ==Int W1)
```

-   `s<Word` implements a less-than for `Word` (with signed interperetation).

```k
    syntax Int ::= Int "s<Word" Int [function, functional]
 // ------------------------------------------------------
    rule [s<Word.pp]: W0 s<Word W1 => W0 <Word W1           requires sgn(W0) ==K 1  andBool sgn(W1) ==K 1
    rule [s<Word.pn]: W0 s<Word W1 => bool2Word(false)      requires sgn(W0) ==K 1  andBool sgn(W1) ==K -1
    rule [s<Word.np]: W0 s<Word W1 => bool2Word(true)       requires sgn(W0) ==K -1 andBool sgn(W1) ==K 1
    rule [s<Word.nn]: W0 s<Word W1 => abs(W1) <Word abs(W0) requires sgn(W0) ==K -1 andBool sgn(W1) ==K -1
```

### Bitwise Operators

Bitwise logical operators are lifted from the integer versions.

```k
    syntax Int ::= "~Word" Int       [function, functional]
                 | Int "|Word"   Int [function, functional]
                 | Int "&Word"   Int [function, functional]
                 | Int "xorWord" Int [function, functional]
                 | Int "<<Word"  Int [function]
                 | Int ">>Word"  Int [function]
                 | Int ">>sWord" Int [function]
 // -------------------------------------------
    rule ~Word W       => W xorInt maxUInt256
    rule W0 |Word   W1 => W0 |Int W1
    rule W0 &Word   W1 => W0 &Int W1
    rule W0 xorWord W1 => W0 xorInt W1
    rule W0 <<Word  W1 => chop( W0 <<Int W1 ) requires W1 <Int 256
    rule  _ <<Word  W1 => 0 requires W1 >=Int 256
    rule W0 >>Word  W1 => W0 >>Int W1
    rule W0 >>sWord W1 => chop( (abs(W0) *Int sgn(W0)) >>Int W1 )
```

-   `bit` gets bit $N$ (0 being MSB).
-   `byte` gets byte $N$ (0 being the MSB).

```k
    syntax Int ::= bit  ( Int , Int ) [function]
                 | byte ( Int , Int ) [function]
 // --------------------------------------------
    rule bit (N, _) => 0 requires notBool (N >=Int 0 andBool N <Int 256)
    rule byte(N, _) => 0 requires notBool (N >=Int 0 andBool N <Int  32)

    rule bit (N, W) => bitRangeInt(W , (255 -Int N)        , 1) requires N >=Int 0 andBool N <Int 256
    rule byte(N, W) => bitRangeInt(W , ( 31 -Int N) *Int 8 , 8) requires N >=Int 0 andBool N <Int  32
```

-   `#nBits` shifts in $N$ ones from the right.
-   `#nBytes` shifts in $N$ bytes of ones from the right.
-   `_<<Byte_` shifts an integer 8 bits to the left.
-   `_>>Byte_` shifts an integer 8 bits to the right.

```k
    syntax Int ::= #nBits  ( Int )  [function]
                 | #nBytes ( Int )  [function]
                 | Int "<<Byte" Int [function]
                 | Int ">>Byte" Int [function]
 // ------------------------------------------
    rule #nBits(N)  => (1 <<Int N) -Int 1 requires N >=Int 0
    rule #nBytes(N) => #nBits(N *Int 8)   requires N >=Int 0
    rule N <<Byte M => N <<Int (8 *Int M)
    rule N >>Byte M => N >>Int (8 *Int M)
```

-   `signextend(N, W)` sign-extends from byte $N$ of $W$ (0 being MSB).

```k
    syntax Int ::= signextend( Int , Int ) [function, functional]
 // -------------------------------------------------------------
    rule [signextend.invalid]:  signextend(N, W) => W requires N >=Int 32 orBool N <Int 0
    rule [signextend.negative]: signextend(N, W) => chop( (#nBytes(31 -Int N) <<Byte (N +Int 1)) |Int W ) requires N <Int 32 andBool N >=Int 0 andBool         word2Bool(bit(256 -Int (8 *Int (N +Int 1)), W))
    rule [signextend.positive]: signextend(N, W) => chop( #nBytes(N +Int 1)                      &Int W ) requires N <Int 32 andBool N >=Int 0 andBool notBool word2Bool(bit(256 -Int (8 *Int (N +Int 1)), W))
```


A WordStack for EVM
-------------------

### As a cons-list

A cons-list is used for the EVM wordstack.

-   `.WordStack` serves as the empty worstack, and
-   `_:_` serves as the "cons" operator.

```k
    syntax WordStack [flatPredicate]
    syntax WordStack ::= ".WordStack"      [smtlib(_dotWS)]
                       | Int ":" WordStack [klabel(_:_WS), smtlib(_WS_)]
 // --------------------------------------------------------------------
```

```{.k .bytes}
    syntax Bytes ::= Int ":" Bytes [function]
 // -----------------------------------------
    rule I : BS => Int2Bytes(1, I, BE) ++ BS requires I <Int 256
```

-   `#take(N , WS)` keeps the first $N$ elements of a `WordStack` (passing with zeros as needed).
-   `#drop(N , WS)` removes the first $N$ elements of a `WordStack`.

```k
    syntax WordStack ::= #take ( Int , WordStack ) [klabel(takeWordStack), function, functional]
 // --------------------------------------------------------------------------------------------
    rule [#take.base]:      #take(N, _WS)                => .WordStack                      requires notBool N >Int 0
    rule [#take.zero-pad]:  #take(N, .WordStack)         => 0 : #take(N -Int 1, .WordStack) requires N >Int 0
    rule [#take.recursive]: #take(N, (W : WS):WordStack) => W : #take(N -Int 1, WS)         requires N >Int 0

    syntax WordStack ::= #drop ( Int , WordStack ) [klabel(dropWordStack), function, functional]
 // --------------------------------------------------------------------------------------------
    rule #drop(N, WS:WordStack)       => WS                                  requires notBool N >Int 0
    rule #drop(N, .WordStack)         => .WordStack                          requires         N >Int 0
    rule #drop(N, (W : WS):WordStack) => #drop(1, #drop(N -Int 1, (W : WS))) requires         N >Int 1
    rule #drop(1, (_ : WS):WordStack) => WS
```

```{.k .bytes}
    syntax Bytes ::= #take ( Int , Bytes ) [klabel(takeBytes), function, functional]
 // --------------------------------------------------------------------------------
    rule #take(N, _BS:Bytes) => .Bytes                                      requires                                        notBool N >Int 0
    rule #take(N,  BS:Bytes) => #padRightToWidth(N, .Bytes)                 requires notBool lengthBytes(BS) >Int 0 andBool         N >Int 0
    rule #take(N,  BS:Bytes) => BS ++ #take(N -Int lengthBytes(BS), .Bytes) requires         lengthBytes(BS) >Int 0 andBool notBool N >Int lengthBytes(BS)
    rule #take(N,  BS:Bytes) => BS [ 0 .. N ]                               requires         lengthBytes(BS) >Int 0 andBool         N >Int lengthBytes(BS)

    syntax Bytes ::= #drop ( Int , Bytes ) [klabel(dropBytes), function, functional]
 // --------------------------------------------------------------------------------
    rule #drop(N, BS:Bytes) => BS                                  requires                                        notBool N >Int 0
    rule #drop(N, BS:Bytes) => .Bytes                              requires notBool lengthBytes(BS) >Int 0 andBool         N >Int 0
    rule #drop(N, BS:Bytes) => .Bytes                              requires         lengthBytes(BS) >Int 0 andBool         N >Int lengthBytes(BS)
    rule #drop(N, BS:Bytes) => substrBytes(BS, N, lengthBytes(BS)) requires         lengthBytes(BS) >Int 0 andBool notBool N >Int lengthBytes(BS)
```

### Element Access

-   `WS [ N ]` accesses element $N$ of $WS$.
-   `WS [ N := W ]` sets element $N$ of $WS$ to $W$ (padding with zeros as needed).

```k
    syntax Int ::= WordStack "[" Int "]" [function, functional]
 // -----------------------------------------------------------
    rule (W : _):WordStack [ N ] => W                  requires N ==Int 0
    rule WS:WordStack      [ N ] => #drop(N, WS) [ 0 ] requires N  >Int 0
    rule  _:WordStack      [ N ] => 0                  requires N  <Int 0

    syntax WordStack ::= WordStack "[" Int ":=" Int "]" [function, functional]
 // --------------------------------------------------------------------------
    rule (_W0 : WS):WordStack [ N := W ] => W  : WS                     requires N ==Int 0
    rule ( W0 : WS):WordStack [ N := W ] => W0 : (WS [ N -Int 1 := W ]) requires N  >Int 0
    rule        WS :WordStack [ N := _ ] => WS                          requires N  <Int 0
    rule .WordStack           [ N := W ] => (0 : .WordStack) [ N := W ]
```

-   `#sizeWordStack` calculates the size of a `WordStack`.
-   `_in_` determines if a `Int` occurs in a `WordStack`.

```k
    syntax Int ::= #sizeWordStack ( WordStack )       [function, functional, smtlib(sizeWordStack)]
                 | #sizeWordStack ( WordStack , Int ) [function, functional, klabel(sizeWordStackAux), smtlib(sizeWordStackAux)]
 // ----------------------------------------------------------------------------------------------------------------------------
    rule #sizeWordStack ( WS ) => #sizeWordStack(WS, 0)
    rule #sizeWordStack ( .WordStack, SIZE ) => SIZE
    rule #sizeWordStack ( _ : WS, SIZE )     => #sizeWordStack(WS, SIZE +Int 1)

    syntax Bool ::= Int "in" WordStack [function]
 // ---------------------------------------------
    rule _ in .WordStack => false
    rule W in (W' : WS)  => (W ==K W') orElseBool (W in WS)
```

-   `#replicateAux` pushes `N` copies of `A` onto a `WordStack`.
-   `#replicate` is a `WordStack` of length `N` with `A` the value of every element.

```k
    syntax WordStack ::= #replicate    ( Int, Int )            [function, functional]
                       | #replicateAux ( Int, Int, WordStack ) [function, functional]
 // ---------------------------------------------------------------------------------
    rule #replicate   ( N,  A )     => #replicateAux(N, A, .WordStack)
    rule #replicateAux( N,  A, WS ) => #replicateAux(N -Int 1, A, A : WS) requires         N >Int 0
    rule #replicateAux( N, _A, WS ) => WS                                 requires notBool N >Int 0
```

-   `WordStack2List` converts a term of sort `WordStack` to a term of sort `List`.

```k
    syntax List ::= WordStack2List ( WordStack ) [function, functional]
 // -------------------------------------------------------------------
    rule WordStack2List(.WordStack) => .List
    rule WordStack2List(W : WS) => ListItem(W) WordStack2List(WS)
```

Local Memory
------------

Most of EVM data is held in local memory.

-   `WM [ N := WS ]` assigns a contiguous chunk of $WM$ to $WS$ starting at position $W$.
-   `#range(M, START, WIDTH)` reads off $WIDTH$ elements from $WM$ beginning at position $START$ (padding with zeros as needed).

```{.k .bytes}
    syntax Memory = Bytes
    syntax Memory ::= Memory "[" Int ":=" ByteArray "]" [function, functional, klabel(mapWriteBytes)]
 // -------------------------------------------------------------------------------------------------
    rule WS [ START := WS' ] => replaceAtBytes(padRightBytes(WS, START +Int #sizeByteArray(WS'), 0), START, WS') requires START >=Int 0  [concrete]
    rule  _ [ START := _:ByteArray ] => .Memory                                                                  requires START  <Int 0  [concrete]

    syntax ByteArray ::= #range ( Memory , Int , Int ) [function, functional]
 // -------------------------------------------------------------------------
    rule #range(LM, START, WIDTH) => LM [ START .. WIDTH ] [concrete]

    syntax Memory ::= ".Memory"
 // ---------------------------
    rule .Memory => .Bytes [macro]

    syntax Memory ::= Memory "[" Int ":=" Int "]" [function]
 // --------------------------------------------------------
    rule WM [ IDX := VAL ] => padRightBytes(WM, IDX +Int 1, 0) [ IDX <- VAL ]
```

```{.k .nobytes}
    syntax Memory = Map
    syntax Memory ::= Memory "[" Int ":=" ByteArray "]" [function, functional]
 // --------------------------------------------------------------------------
    rule [mapWriteBytes.base]:      WM[ _N := .WordStack ] => WM
    rule [mapWriteBytes.recursive]: WM[  N := W : WS     ] => (WM[N <- W])[N +Int 1 := WS]

    syntax ByteArray ::= #range ( Memory , Int , Int )             [function, functional]
    syntax ByteArray ::= #range ( Memory , Int , Int , ByteArray ) [function, functional, klabel(#rangeAux)]
 // --------------------------------------------------------------------------------------------------------
    rule [#range]:         #range(WM, START, WIDTH) => #range(WM, START +Int WIDTH -Int 1, WIDTH, .WordStack)
    rule [#rangeAux.base]: #range( _,  _END, WIDTH, WS) => WS requires notBool 0 <Int WIDTH
    rule [#rangeAux.rec]:  #range(WM,   END => END -Int 1, WIDTH => WIDTH -Int 1, WS => #lookupMemory(WM, END) : WS) requires 0 <Int WIDTH

    syntax Memory ::= ".Memory"
 // ---------------------------
    rule .Memory => .Map [macro]

    syntax Memory ::= Memory "[" Int ":=" Int "]" [function]
 // --------------------------------------------------------
    rule WM [ IDX := VAL:Int ] => WM [ IDX <- VAL ]
```

Byte Arrays
-----------

The local memory of execution is a byte-array (instead of a word-array).

-   `#asWord` will interperet a stack of bytes as a single word (with MSB first).
-   `#asInteger` will interperet a stack of bytes as a single arbitrary-precision integer (with MSB first).
-   `#asAccount` will interpret a stack of bytes as a single account id (with MSB first).
    Differs from `#asWord` only in that an empty stack represents the empty account, not account zero.
-   `#asByteStack` will split a single word up into a `ByteArray`.
-   `_++_` acts as `ByteArray` append.
-   `WS [ N .. W ]` access the range of `WS` beginning with `N` of width `W`.
-   `#sizeByteArray` calculates the size of a `ByteArray`.
-   `#padToWidth(N, WS)` and `#padRightToWidth` make sure that a `WordStack` is the correct size.

```{.k .bytes}
    syntax ByteArray = Bytes
    syntax ByteArray ::= ".ByteArray"
 // ---------------------------------
    rule .ByteArray => .Bytes [macro]

    syntax Int ::= #asWord ( ByteArray ) [function, functional, smtlib(asWord)]
 // ---------------------------------------------------------------------------
    rule #asWord(WS) => chop(Bytes2Int(WS, BE, Unsigned)) [concrete]

    syntax Int ::= #asInteger ( ByteArray ) [function, functional]
 // --------------------------------------------------------------
    rule #asInteger(WS) => Bytes2Int(WS, BE, Unsigned) [concrete]

    syntax Account ::= #asAccount ( ByteArray ) [function]
 // ------------------------------------------------------
    rule #asAccount(BS) => .Account    requires lengthBytes(BS) ==Int 0
    rule #asAccount(BS) => #asWord(BS) [owise]

    syntax ByteArray ::= #asByteStack ( Int ) [function, functional]
 // ----------------------------------------------------------------
    rule #asByteStack(W) => Int2Bytes(W, BE, Unsigned) [concrete]

    syntax ByteArray ::= ByteArray "++" ByteArray [function, functional, right, klabel(_++_WS), smtlib(_plusWS_)]
 // -------------------------------------------------------------------------------------------------------------
    rule WS ++ WS' => WS +Bytes WS' [concrete]

    syntax ByteArray ::= ByteArray "[" Int ".." Int "]" [function, functional]
 // --------------------------------------------------------------------------
    rule                 _ [ START .. WIDTH ] => .ByteArray                      requires notBool (WIDTH >=Int 0 andBool START >=Int 0)
    rule [bytesRange] : WS [ START .. WIDTH ] => substrBytes(padRightBytes(WS, START +Int WIDTH, 0), START, START +Int WIDTH)
      requires WIDTH >=Int 0 andBool START >=Int 0 andBool START <Int #sizeByteArray(WS)
    rule                 _ [ _     .. WIDTH ] => padRightBytes(.Bytes, WIDTH, 0) [owise]

    syntax Int ::= #sizeByteArray ( ByteArray ) [function, functional, klabel(sizeByteArray), smtlib(sizeByteArray)]
 // ----------------------------------------------------------------------------------------------------------------
    rule #sizeByteArray ( WS ) => lengthBytes(WS) [concrete]

    syntax ByteArray ::= #padToWidth      ( Int , ByteArray ) [function, functional]
                       | #padRightToWidth ( Int , ByteArray ) [function, functional]
 // --------------------------------------------------------------------------------
    rule                        #padToWidth(N, BS)      =>               BS        requires notBool (N >=Int 0)
    rule [padToWidthNonEmpty] : #padToWidth(N, BS)      =>  padLeftBytes(BS, N, 0) requires          N >=Int 0
    rule                        #padRightToWidth(N, BS) =>               BS        requires notBool (N >=Int 0)
    rule                        #padRightToWidth(N, BS) => padRightBytes(BS, N, 0) requires          N >=Int 0
```

```{.k .nobytes}
    syntax ByteArray = WordStack
    syntax ByteArray ::= ".ByteArray"
 // ---------------------------------
    rule .ByteArray => .WordStack [macro]

    syntax Int ::= #asWord ( ByteArray ) [function, functional, smtlib(asWord)]
 // ---------------------------------------------------------------------------
    rule [#asWord.base-empty]:  #asWord( .WordStack     ) => 0
    rule [#asWord.base-single]: #asWord( W : .WordStack ) => W
    rule [#asWord.recursive]:   #asWord( W0 : W1 : WS   ) => #asWord(((W0 *Word 256) +Word W1) : WS)

    syntax Int ::= #asInteger ( ByteArray ) [function]
 // --------------------------------------------------
    rule #asInteger( .WordStack     ) => 0
    rule #asInteger( W : .WordStack ) => W
    rule #asInteger( W0 : W1 : WS   ) => #asInteger(((W0 *Int 256) +Int W1) : WS)

    syntax Account ::= #asAccount ( ByteArray ) [function]
 // ------------------------------------------------------
    rule #asAccount( .WordStack ) => .Account
    rule #asAccount( W : WS     ) => #asWord(W : WS)

    syntax ByteArray ::= #asByteStack ( Int )             [function, functional]
                       | #asByteStack ( Int , ByteArray ) [function, klabel(#asByteStackAux), smtlib(asByteStack)]
 // --------------------------------------------------------------------------------------------------------------
    rule [#asByteStack]:              #asByteStack( W )      => #asByteStack( W , .WordStack )
    rule [#asByteStackAux.base]:      #asByteStack( 0 , WS ) => WS
    rule [#asByteStackAux.recursive]: #asByteStack( W , WS ) => #asByteStack( W /Int 256 , W modInt 256 : WS ) requires W =/=K 0

    syntax ByteArray ::= ByteArray "++" ByteArray [function, memo, right, klabel(_++_WS), smtlib(_plusWS_)]
 // -------------------------------------------------------------------------------------------------------
    rule .WordStack ++ WS' => WS'
    rule (W : WS)   ++ WS' => W : (WS ++ WS')

    syntax ByteArray ::= ByteArray "[" Int ".." Int "]" [function, functional, memo]
 // --------------------------------------------------------------------------------
    rule [ByteArray.range]: WS [ START .. WIDTH ] => #take(WIDTH, #drop(START, WS))

    syntax Int ::= #sizeByteArray ( ByteArray ) [function, functional, smtlib(sizeByteArray), memo]
 // -----------------------------------------------------------------------------------------------
    rule #sizeByteArray ( WS ) => #sizeWordStack(WS) [concrete]

    syntax ByteArray ::= #padToWidth      ( Int , ByteArray ) [function, functional, memo]
                       | #padRightToWidth ( Int , ByteArray ) [function, memo]
 // --------------------------------------------------------------------------------------
    rule [#padToWidth]:      #padToWidth(N, WS)      => #replicateAux(N -Int #sizeByteArray(WS), 0, WS)
    rule [#padRightToWidth]: #padRightToWidth(N, WS) => WS ++ #replicate(N -Int #sizeByteArray(WS), 0)
```

Accounts
--------

### Empty Account

-   `.Account` represents the case when an account ID is referenced in the yellowpaper, but
    the actual value of the account ID is the empty set. This is used, for example, when
    referring to the destination of a message which creates a new contract.

```k
    syntax Account ::= ".Account" | Int
 // -----------------------------------
```

### Addresses

-   `#addr` turns an Ethereum word into the corresponding Ethereum address (160 LSB).

```k
    syntax Int ::= #addr ( Int ) [function]
 // ---------------------------------------
    rule #addr(W) => W %Word pow160
```

Storage/Memory Lookup
---------------------

-   `#lookup` looks up a key in the contract storage and returns 0 if the key doesn't exist, otherwise returning its value.
-   `#lookupMemory` looks up a key in the local memory and returns 0 if the key doesn't exist, otherwise returning its value.
-   `#write` stores a value for a certain key in the contract storage.

```k
    syntax ContractStorage ::= Map

    syntax Int ::= #lookup        ( ContractStorage , Int ) [function, functional, smtlib(lookup)]
                 | #lookupMemory  ( Map             , Int ) [function, functional, smtlib(lookupMemory)]
 // ----------------------------------------------------------------------------------------------------
    rule [#lookup.some]:         #lookup(       (KEY |-> VAL:Int) _M:Map, KEY ) => VAL modInt pow256
    rule [#lookup.none]:         #lookup(                          M:Map, KEY ) => 0                 requires notBool KEY in_keys(M)
    //Impossible case, for completeness
    rule [#lookup.notInt]:       #lookup(       (KEY |-> VAL    ) _M:Map, KEY ) => 0                 requires notBool isInt(VAL)

    rule [#lookupMemory.some]:   #lookupMemory( (KEY |-> VAL:Int) _M, KEY )     => VAL modInt 256
    rule [#lookupMemory.none]:   #lookupMemory(                    M, KEY )     => 0                 requires notBool KEY in_keys(M)
    //Impossible case, for completeness
    rule [#lookupMemory.notInt]: #lookupMemory( (KEY |-> VAL    ) _M, KEY )     => 0                 requires notBool isInt(VAL)

    syntax ContractStorage ::= #write ( ContractStorage , Int, Int ) [function, functional]
 // ---------------------------------------------------------------------------------------
    rule #write(M:Map, KEY, VAL) => M [ KEY <- VAL ]
```

Substate Log
------------

During execution of a transaction some things are recorded in the substate log (Section 6.1 in YellowPaper).
This is a right cons-list of `SubstateLogEntry` (which contains the account ID along with the specified portions of the `wordStack` and `localMem`).

```k
    syntax SubstateLogEntry ::= "{" Int "|" List "|" ByteArray "}" [klabel(logEntry)]
 // ---------------------------------------------------------------------------------
```

```k
endmodule
```
