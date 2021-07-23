requires "evm.md"
requires "edsl.md"
requires "./int-simplification.k"

module LEMMAS
    imports LEMMAS-JAVA
    imports LEMMAS-HASKELL
    imports INT-SIMPLIFICATION

  // ########################
  // Arithmetic
  // ########################

    // For #bufStrict simplification in benchmarks
    rule 0 <=Int #ceil32(I)        => true requires 0 <=Int I [simplification, smt-lemma]
    rule 0 <=Int #ceil32(I) -Int I => true requires 0 <=Int I [simplification]

    // chop range & simplification
    rule chop(I) => I requires #rangeUInt( 256 , I ) [simplification]
    rule 0 <=Int chop(_V)             => true        [simplification]
    rule         chop(_V) <Int pow256 => true        [simplification]


  // ########################
  // Set Reasoning
  // ########################

    rule X in (SetItem(Y) _   ) => true      requires X  ==Int Y [simplification]
    rule X in (SetItem(Y) REST) => X in REST requires X =/=Int Y [simplification]

  // ########################
  // Word Reasoning
  // ########################

    rule 0 <=Int #sizeWordStack ( _ , N ) => true requires 0 <=Int N [simplification, smt-lemma]
    rule 0 <=Int #sizeByteArray ( _ )     => true                    [simplification, smt-lemma]

    // bool2Word range & simplification
    rule 0 <=Int bool2Word(_B)             => true   [simplification]
    rule         bool2Word(_B) <Int pow256 => true   [simplification]

    rule notBool notBool B => B [simplification]

    // #newAddr range
    rule 0 <=Int #newAddr(_,_)             => true   [simplification]
    rule         #newAddr(_,_) <Int pow160 => true   [simplification]
    rule         #newAddr(_,_) <Int pow256 => true   [simplification]

    rule #isPrecompiledAccount(#newAddr(_, _), _) => false [simplification]

  // ########################
  // Keccak
  // ########################

    //Required for #Ceil(#buf)
    rule 0 <=Int keccak( _ )             => true [simplification]
    rule         keccak( _ ) <Int pow256 => true [simplification]

  // ########################
  // Buffer Reasoning
  // ########################

    rule WS         ++ .ByteArray => WS  [simplification]
    rule .ByteArray ++ WS         => WS  [simplification]

  // ########################
  // Map Reasoning
  // ########################

    rule #lookup ( _M:Map [ K1 <- V1 ] , K2 ) => #lookup ( K1 |-> V1 , K1 )  requires K1 ==Int  K2 [simplification]
    rule #lookup (  M:Map [ K1 <- _  ] , K2 ) => #lookup ( M         , K2 )  requires K1 =/=Int K2 [simplification]

    rule 0 <=Int #lookup( _M:Map , _ )             => true [simplification, smt-lemma]
    rule         #lookup( _M:Map , _ ) <Int pow256 => true [simplification, smt-lemma]

    // re-order assignments
    rule MEM [ K1 := BUF1:ByteArray ] [ K2 := BUF2:ByteArray ] => MEM [ K2 := BUF2 ] [ K1 := BUF1 ]  requires         #sizeByteArray(BUF2) <=Int K1 -Int K2                   andBool K2  <Int K1 [simplification]
    // overwritten assignment
    rule MEM [ K1 := BUF1           ] [ K2 := BUF2           ] => MEM [ K2 := BUF2 ]                 requires K1 +Int #sizeByteArray(BUF1) <=Int K2 +Int #sizeByteArray(BUF2) andBool K2 <=Int K1 [simplification]
    // redundant assignment
    rule MEM [ K  := BUF1           ] [ K  := BUF2           ] => MEM [ K  := BUF2 ]                 requires         #sizeByteArray(BUF1) ==Int #sizeByteArray(BUF2)                             [simplification]

    // lookup range in memory
    rule _MEM [ _ .. W ] => .ByteArray  requires W ==Int 0                    [simplification]
    rule  MEM [ 0 .. W ] => MEM         requires W ==Int #sizeByteArray(MEM)  [simplification]

    // lookup range in concatenated memory buffers
    rule (BUF1 ++  BUF2)[START .. WIDTH] =>  BUF2[START -Int #sizeByteArray(BUF1) .. WIDTH                          ]                                                              requires                        #sizeByteArray(BUF1) <=Int START                                                             [simplification]
    rule (BUF1 ++  _   )[START .. WIDTH] =>  BUF1[START                           .. WIDTH                          ]                                                              requires START +Int WIDTH <=Int #sizeByteArray(BUF1)                       andBool 0 <=Int START andBool 0 <=Int WIDTH       [simplification]
    rule (BUF1 ++  BUF2)[START .. WIDTH] => (BUF1[START                           .. #sizeByteArray(BUF1) -Int START]) ++ (BUF2[0 .. START +Int WIDTH -Int #sizeByteArray(BUF1)])  requires                        #sizeByteArray(BUF1) <Int START +Int WIDTH andBool #range(0 <= START < #sizeByteArray(BUF1)) [simplification]

    // sizeByteArray

    rule #sizeByteArray(BUF1 ++ BUF2)            => #sizeByteArray(BUF1) +Int #sizeByteArray(BUF2)      [simplification]
    rule #sizeByteArray(#buf(SIZE, _))           => SIZE                                                [simplification]
    rule #sizeByteArray(_MEM [ START .. WIDTH ]) => WIDTH  requires 0 <=Int START andBool 0 <=Int WIDTH [simplification]
    rule #sizeByteArray(#range(_, START, WIDTH)) => WIDTH  requires 0 <=Int START andBool 0 <=Int WIDTH [simplification]

    // TODO: custom ==K unification doesn't work in Haskell yet
    // ++ unification
    rule #buf(N, A) ++ BUF1 ==K #buf(N, B) ++ BUF2 => #buf(N, A) ==K #buf(N, B) andBool BUF1 ==K BUF2     [simplification]

    rule #padToWidth(32, #asByteStack(V)) => #buf(32, V)  requires #rangeUInt(256, V) [simplification]

    rule #asWord(WS) >>Int M => #asWord(WS [ 0 .. #sizeByteArray(WS) -Int (M /Int 8) ])  requires 0 <=Int M andBool M modInt 8 ==Int 0 [simplification]

endmodule

module LEMMAS-JAVA [symbolic, kast]
    imports EVM
    imports EDSL
    imports K-REFLECTION
    imports HASH2
    imports INT-SIMPLIFICATION // TODO: perhaps only need INT-SIMPLIFICATION-JAVA

  // ########################
  // Buffer Reasoning
  // ########################

    rule BUF [ L .. _W ] => .ByteArray requires L >=Int #sizeByteArray(BUF) [simplification]

    rule (W0 : WS) [ 0     .. WIDTH ] => W0 : (WS [ 0            .. WIDTH -Int 1 ]) requires #rangeUInt(8, W0) andBool 0 <Int WIDTH [simplification]
    rule (W0 : WS) [ START .. WIDTH ] =>       WS [ START -Int 1 .. WIDTH        ]  requires #rangeUInt(8, W0) andBool 0 <Int START [simplification]

    // #sizeByteArray

    rule #sizeByteArray(_W : WS) => 1 +Int #sizeByteArray(WS) [simplification]

    // #asWord

    rule #asWord(#buf(_N, BUF)) => BUF [simplification]

    rule #asWord(BUF) /Int pow224 => #asWord(BUF [ 0 .. 4 ]) requires #sizeByteArray(BUF) ==Int 32 [simplification]

    // #range

    rule #range(_M, _N, K) => .ByteArray requires notBool 0 <Int K [simplification]

    rule #range(M [ N := BUF:ByteArray ], L, K) => #range(M, L, minInt(K, N -Int L)) ++ #range(M [ N := BUF ], N, K -Int minInt(K, N -Int L))
      requires 0 <Int K
       andBool L <Int N
      [simplification]

    rule #range(M [ N := BUF ], L, K) => BUF [ L -Int N .. minInt(K, #sizeByteArray(BUF) -Int (L -Int N)) ] ++ #range(M, N +Int #sizeByteArray(BUF), K -Int minInt(K, #sizeByteArray(BUF) -Int (L -Int N)))
      requires 0  <Int K
       andBool N <=Int L
       andBool L  <Int N +Int #sizeByteArray(BUF)
      [simplification]

    rule #range(M [ N := BUF ], L, K) => #range(M, L, K)
      requires 0 <Int K
       andBool N +Int #sizeByteArray(BUF) <=Int L
      [simplification]

    rule #buf(N, #asWord(WS)) => WS
      requires #noOverflow(WS)
       andBool N ==Int #sizeByteArray(WS)
      [simplification]


    rule BA:ByteArray     ==K #buf( 32, DATA ) => #buf( 32, DATA ) ==K   BA              requires #isConcrete(BA)             [simplification]
    rule #buf( 32, DATA ) ==K BA:ByteArray     => DATA             ==Int #asInteger(BA)  requires #isConcrete(BA)
                                                                                          andBool #sizeByteArray(BA) <=Int 32 [simplification]

  // ########################
  // Overflow
  // ########################

    syntax Bool ::= #noOverflow    ( ByteArray ) [function]
                  | #noOverflowAux ( ByteArray ) [function]
 // -------------------------------------------------------
    rule #noOverflow(WS) => #sizeByteArray(WS) <=Int 32 andBool #noOverflowAux(WS)

    rule #noOverflowAux(.ByteArray) => true

  // ########################
  // Arithmetic
  // ########################

    // 0xffff...f &Int N = N
    // MASK = 0xffff...f
    rule MASK &Int N    => N requires MASK ==Int (2 ^Int (log2Int(MASK) +Int 1)) -Int 1 andBool 0 <=Int N andBool N <=Int MASK [simplification]

    // N &Int 0xffff...f = N
    // MASK = 0xffff...f
    rule N    &Int MASK => N requires MASK ==Int (2 ^Int (log2Int(MASK) +Int 1)) -Int 1 andBool 0 <=Int N andBool N <=Int MASK [simplification]

    rule 0 <=Int X &Int Y             => true requires 0 <=Int X andBool X <Int pow256 andBool 0 <=Int Y andBool Y <Int pow256 [simplification]
    rule         X &Int Y <Int pow256 => true requires 0 <=Int X andBool X <Int pow256 andBool 0 <=Int Y andBool Y <Int pow256 [simplification]

  // ########################
  // Boolean Logic
  // ########################

    rule B ==K false => notBool B [simplification]

  // ########################
  // Gas Calculation
  // ########################

    // for gas calculation
    rule A -Int (#if C #then B1 #else B2 #fi) => #if C #then (A -Int B1) #else (A -Int B2) #fi [simplification]

    rule (#if C #then B1 #else B2 #fi) +Int A => #if C #then (B1 +Int A) #else (B2 +Int A) #fi [simplification]

  // ########################
  // Word Reasoning
  // ########################

    rule bool2Word(A) |Int bool2Word(B) => bool2Word(A  orBool B) [simplification]
    rule bool2Word(A) &Int bool2Word(B) => bool2Word(A andBool B) [simplification]

    rule 1 |Int bool2Word(_B) => 1            [simplification]
    rule 1 &Int bool2Word( B) => bool2Word(B) [simplification]

    rule bool2Word(_B) |Int 1 => 1            [simplification]
    rule bool2Word( B) &Int 1 => bool2Word(B) [simplification]

    rule bool2Word(A) =/=K 0 => A          [simplification]
    rule bool2Word(A) =/=K 1 => notBool(A) [simplification]

    rule notBool  (X ==K 0) => X ==K 1  requires #rangeBool(X) [simplification]
    rule notBool  (X ==K 1) => X ==K 0  requires #rangeBool(X) [simplification]
    rule bool2Word(X ==K 1) => X        requires #rangeBool(X) [simplification]

    rule 0 <=Int #asWord(_WS)             => true [simplification]
    rule         #asWord(_WS) <Int pow256 => true [simplification]

    rule X <=Int maxUInt256 => X <Int pow256 [simplification]
    rule X <=Int maxUInt160 => X <Int pow160 [simplification]
    rule X <=Int 255        => X <Int 256    [simplification]

    //Simplification of bool2Word() ==Int CONCRETE, #buf() ==K CONCRETE
    rule I                   ==K bool2Word( B:Bool ) => bool2Word(B) ==Int I             requires #isConcrete(I) [simplification]
    rule bool2Word( B:Bool ) ==K I                   => B            ==K   word2Bool(I)  requires #isConcrete(I) [simplification]

endmodule

module LEMMAS-HASKELL [symbolic, kore]
    imports INT-SYMBOLIC
    imports EVM
    imports EDSL
    imports HASH2
    imports INT-SIMPLIFICATION // TODO: perhaps only need INT-SIMPLIFICATION-HASKELL

  // ########################
  // Word Reasoning
  // ########################

    rule #asWord(BUF) /Int D => #asWord(BUF[0 .. #sizeByteArray(BUF) -Int log256Int(D)]) 
      requires D ==Int 256 ^Int log256Int(D) andBool D >=Int 0
       andBool #sizeByteArray(BUF) >=Int log256Int(D) [simplification]

    rule #asWord(#buf(N, BUF)) => BUF
      requires #range(0 < N <= 32)
       andBool #range(0 <= BUF < 2 ^Int (N *Int 8)) [simplification]

    rule notBool  (X ==Int 0) => X ==Int 1 requires #rangeBool(X) [simplification]
    rule notBool  (X ==Int 1) => X ==Int 0 requires #rangeBool(X) [simplification]
    rule bool2Word(X ==Int 1) => X         requires #rangeBool(X) [simplification]

    //Simplification of bool2Word() ==Int CONCRETE, #buf() ==K CONCRETE
    rule I                   ==Int bool2Word( B:Bool ) => bool2Word(B) ==Int I  [simplification, concrete(I)]
    rule bool2Word( B:Bool ) ==Int I                   => B ==K word2Bool(I)    [simplification, concrete(I)]

  // ########################
  // Arithmetic
  // ########################

    rule N &Int maxUInt160 => N  requires #rangeUInt(160, N) [simplification]

    rule maxUInt160 &Int N => N  requires #rangeUInt(160, N) [simplification]

    rule N modInt pow160   => N  requires #rangeUInt(160, N) [simplification]

  // ########################
  // Buffer Reasoning
  // ########################

    // #range

    rule #range(_                       , _, K) => .ByteArray                                                                                                                                                          requires notBool K >Int 0                                                                               [simplification]
    rule #range(M [ N := BUF:ByteArray ], L, K) => #range(M, L, minInt(K, N -Int L)) ++ #range(M [ N := BUF ], N, K -Int minInt(K, N -Int L))                                                                          requires K  >Int 0 andBool L <Int N                                                                     [simplification]
    rule #range(M [ N := BUF:ByteArray ], L, K) => BUF [ L -Int N .. minInt(K, #sizeByteArray(BUF) -Int (L -Int N)) ] ++ #range(M, N +Int #sizeByteArray(BUF), K -Int minInt(K, #sizeByteArray(BUF) -Int (L -Int N)))  requires K  >Int 0 andBool L <Int N +Int #sizeByteArray(BUF) andBool L >=Int N                          [simplification]
    rule #range(M [ N := BUF:ByteArray ], L, K) => #range(M, L, K)                                                                                                                                                     requires K  >Int 0                                           andBool L >=Int N +Int #sizeByteArray(BUF) [simplification]

    rule 0 <=Int lengthBytes ( _ ) => true [smt-lemma, simplification]

    rule BA:ByteArray   ==K #buf(32, DATA) => #buf(32, DATA) ==K              BA                                       [simplification, concrete(BA)]
    rule #buf(32, DATA) ==K BA:ByteArray   =>          DATA  ==Int #asInteger(BA) requires #sizeByteArray(BA) <=Int 32 [simplification, concrete(BA)]

  // ########################
  // Boolean Logic
  // ########################

    rule B ==Bool false => notBool B [simplification]

endmodule

module HASH2 [symbolic]
    imports INT

endmodule
