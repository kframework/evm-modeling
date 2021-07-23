requires "../infinite-gas.k"
requires "../lemmas.k"

module VERIFICATION-COMMON
    imports LEMMAS

  // ########################
  // Ecrecover
  // ########################

    //Symbolic wrapper over the argument of #ecrec. No implementation.
    syntax Int ::= #symEcrec ( ByteArray )   [function]

    //Symbolic predicate representing whether output of #ecrec is empty. No implementation.
    syntax Bool ::= #ecrecEmpty( ByteArray ) [function]

endmodule

module VERIFICATION
    imports VERIFICATION-COMMON
    imports VERIFICATION-JAVA
    imports VERIFICATION-HASKELL

  // ########################
  // Map Reasoning
  // ########################

    rule M:Map [ K1 <- _  ] [ K2 <- V2 ] => M [ K1 <- V2 ]               requires K1 ==Int K2 [simplification]
    rule M:Map [ K1 <- V1 ] [ K2 <- V2 ] => M [ K2 <- V2 ] [ K1 <- V1 ]  requires K2  <Int K1 [simplification]

  // ########################
  // Gas Calculation
  // ########################

    rule Rsstore(_BYZANTIUM, NEW, _CURR, _ORIG) => 0  requires NEW =/=Int 0 [simplification]

  // ########################
  // Ecrecover
  // ########################

    // Range for #symEcrec

    //case 0 is never wrapped into #symEcrec(), corresponds to #ecrecEmpty(DATA) == true
    rule 0 <Int   #symEcrec(_DATA)             => true [simplification]
    //that's because the result in concrete semantics is trimmed to Address range.
    rule          #symEcrec(_DATA) <Int pow160 => true [simplification]
    // Lemmas implied by the above, but still required to match side conditions of #padToWidth rule in lemmas.md
    // General range conversion lemmas like below are not an option, dramatic performance decrease:
    rule 0 <=Int  #symEcrec(_DATA)             => true [simplification]
    rule          #symEcrec(_DATA) <Int pow256 => true [simplification]

  // ########################
  // ABI Encoding
  // ########################

    syntax ByteArray ::= #abiCallData2 ( String , TypedArgs ) [function]

    rule #abiCallData2(FSIG, ARGS)
      => #parseByteStack(substrString(Keccak256(FSIG), 0, 8))
      ++ #encodeArgs(ARGS)

    rule chop(I) => 0 requires I ==Int pow256 [simplification]

  // ########################
  // Memory Usage
  // ########################

    rule #memoryUsageUpdate(#memoryUsageUpdate(MU, START0, WIDTH0), START1, WIDTH1) => #memoryUsageUpdate(MU, START0, WIDTH0) requires START1 +Int WIDTH1 <=Int START0 +Int WIDTH0 andBool 0  <Int WIDTH0 andBool 0 <=Int WIDTH1 [simplification]
    rule #memoryUsageUpdate(#memoryUsageUpdate(MU, START0, WIDTH0), START1, WIDTH1) => #memoryUsageUpdate(MU, START1, WIDTH1) requires START0 +Int WIDTH0  <Int START1 +Int WIDTH1 andBool 0 <=Int WIDTH0 andBool 0  <Int WIDTH1 [simplification]

    rule 0 <=Int #memoryUsageUpdate(_MU, _START, _WIDTH) => true [simplification]

  // ########################
  // Buffer Reasoning
  // ########################

    // ++-identity-right
    rule WS ++ .ByteArray => WS [simplification]

    // ++-associativity
    rule ( WS1 ++ WS2 ) ++ WS3 => WS1 ++ ( WS2 ++ WS3 ) [simplification]

    rule #sizeWordStack(WS, N) <Int SIZE => #sizeWordStack(WS, 0) +Int N <Int SIZE  requires N =/=Int 0 [simplification]

    rule SIZELIMIT <Int #sizeWordStack(WS, N) +Int DELTA  => SIZELIMIT <Int (#sizeWordStack(WS, 0) +Int N) +Int DELTA  requires N =/=Int 0 [simplification]
    rule SIZELIMIT <Int #sizeWordStack(WS, N)             => SIZELIMIT <Int  #sizeWordStack(WS, 0) +Int N              requires N =/=Int 0 [simplification]

    rule #sizeWordStack(WS, N) <=Int SIZE => #sizeWordStack(WS, 0) +Int N <=Int SIZE  requires N =/=Int 0 [simplification]

  // ########################
  // Range
  // ########################

    rule 0 <=Int (_X modInt _Y)         => true                    [simplification]
    rule         (_X modInt  Y) <Int Y  => true  requires Y >Int 0 [simplification]

    rule 0 <=Int 2 ^Int _X             => true                      [simplification]
    rule         2 ^Int  X <Int pow256 => true  requires X <Int 256 [simplification]

    rule 0 <=Int X &Int Y             => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y) [simplification]
    rule         X &Int Y <Int pow256 => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y) [simplification]

    rule 0 <=Int X |Int Y             => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y) [simplification]
    rule         X |Int Y <Int pow256 => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y) [simplification]

    rule 0 <=Int #blockhash(_, _, _, _)             => true [simplification]
    rule         #blockhash(_, _, _, _) <Int pow256 => true [simplification]

    rule 0 <=Int X xorInt maxUInt256             => true  requires #rangeUInt(256, X) [simplification]
    rule         X xorInt maxUInt256 <Int pow256 => true  requires #rangeUInt(256, X) [simplification]

  // ########################
  // Simplification
  // ########################

    rule #range(_M [ N := #buf(WIDTH, DATA) ], N, WIDTH) => #buf(WIDTH, DATA) [simplification]

    rule #asWord(WS) &Int maxUInt256 => #asWord(WS) [simplification]

    rule maxUInt256 &Int X => X requires #rangeUInt(256, X) [simplification]

    // 2^256 - 2^160 = 0xff..ff00..00 (96 1's followed by 160 0's)
    rule 115792089237316195423570985007226406215939081747436879206741300988257197096960 &Int ADDR => 0
      requires #rangeAddress(ADDR)
      [simplification]

    rule chop((ADDR &Int maxUInt160) modInt pow160) => ADDR
      requires #rangeAddress(ADDR)
      [simplification]

  // ########################
  // Arithmetic
  // ########################

    rule (A +Int I2) +Int (I3 -Int A) => I2 +Int I3 [simplification]
    rule (A +Int I2) -Int (A +Int I3) => I2 -Int I3 [simplification]
    rule (A +Int I2) -Int (I3 +Int A) => I2 -Int I3 [simplification]

    rule (I1 +Int I2) -Int (I3 +Int I1) => I2 -Int I3 [simplification]

    rule A -Int (A -Int I1) => I1 [simplification]

    rule (A +Int I1) -Int A => I1 [simplification]

    rule (A +Int B) +Int (C -Int B) => A +Int C [simplification]

    rule (A +Int B +Int C) -Int (A +Int D) => B +Int (C -Int D) [simplification]

    rule (A +Int B +Int C +Int D +Int E) -Int (A +Int C +Int F) => B +Int D +Int E -Int F [simplification]

    // Simplify Cmem(_,_) - Cmem(_, _)
    rule A +Int (I1 -Int A) => I1 [simplification]
    rule (I1 +Int (A -Int I0)) +Int (I2 -Int A) => I1 +Int (I2 -Int I0) [simplification]

    // safeMath mul check c / a == b where c == a * b
    rule (X *Int Y) /Int X => Y  requires X =/=Int 0 [simplification]

    rule I1 *Int A +Int I2 *Int A => (I1 +Int I2) *Int A [simplification]

    rule I1 *Int A +Int B +Int C +Int D +Int I2 *Int A => (I1 +Int I2) *Int A +Int B +Int C +Int D [simplification]

    rule N -Int N => 0 [simplification]

    rule 2 ^%Int X pow256 => 2 ^Int X  requires 0 <=Int X andBool X <Int 256 [simplification]

    rule X modInt Y => X  requires 0 <=Int X andBool X <Int Y [simplification]

    rule ((X *Int Y) /Int Z) /Int Y => X /Int Z  requires Y =/=Int 0 [simplification]

    // X &Int (NOT 31)
    rule X &Int 115792089237316195423570985008687907853269984665640564039457584007913129639904 => (X /Int 32) *Int 32  requires 0 <=Int X [simplification]

    rule (X /Int 32) *Int 32 => X  requires X modInt 32 ==Int 0 [simplification]

    rule #ceil32(X) => X  requires X modInt 32 ==Int 0 [simplification]

    rule 0 <Int 1 <<Int N => true  requires 0 <=Int N [simplification]

    rule X +Int Y <Int pow256 => true  requires X <=Int pow16 andBool Y <Int pow16 [simplification]

    rule X <=Int #ceil32(X)     => true   requires 0 <=Int X                       [simplification]
    rule #ceil32(X) <Int X      => false  requires 0 <=Int X                       [simplification]
    rule #ceil32(X) <=Int pow16 => true   requires 0 <=Int X andBool X <=Int pow16 [simplification]

endmodule

module VERIFICATION-HASKELL [symbolic, kore]
    imports VERIFICATION-COMMON
    imports INFINITE-GAS

  // ########################
  // Arithmetic
  // ########################

    rule X +Int Y <Int Z => X <Int Z -Int Y [concrete(Y), simplification]

  // ########################
  // Buffer Reasoning
  // ########################

    rule BA1 ++ (BA2 ++ BA3) => (BA1 ++ BA2) ++ BA3 [concrete(BA1, BA2), simplification]

endmodule

module VERIFICATION-JAVA [symbolic, kast]
    imports VERIFICATION-COMMON
    imports K-REFLECTION

  // ########################
  // Symbolic Gas
  // ########################

    syntax Int ::= #gas ( Int , Int , Int )  [function]  // startGas, nonMemory, memory
 // -----------------------------------------------------------------------------------
    rule #gas(_, _, _) <=Int I => false  requires #isConcrete(I) [simplification]

  // ########################
  // Rule Replacement
  // ########################

    // accumulate the gas cost and never run out of gas
    claim <k> MEM' ~> #deductMemoryGas => . ... </k>
         <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM, MEM +Int MEM') </gas>
         <callGas> _ => #gas(INITGAS, NONMEM, MEM) </callGas>
      [trusted, matching(#gas)]

    //Will run only if rule above doesn't match
    claim <k> G ~> #deductGas => . ... </k>
         <gas> #gas(INITGAS, NONMEM, MEM) => #gas(INITGAS, NONMEM +Int G, MEM) </gas>
         <callGas> _ => #gas(INITGAS, NONMEM, MEM) </callGas>
      [trusted, matching(#gas)]

    claim <k> ECREC => #end EVMC_SUCCESS ... </k>
         <callData> DATA </callData>
         <output> _ => #ecrec(#symEcrec(DATA)) </output>
      requires notBool #isConcrete(DATA)
       andBool #sizeByteArray(DATA) ==Int 128
       andBool notBool #ecrecEmpty(DATA)
      [trusted]

    claim <k> ECREC => #end EVMC_SUCCESS ... </k>
         <callData> DATA </callData>
         <output> _ => #ecrec(.Account) </output>
      requires notBool #isConcrete(DATA)
       andBool #sizeByteArray(DATA) ==Int 128
       andBool #ecrecEmpty(DATA)
      [trusted]

  // ########################
  // Arithmetic
  // ########################

    rule ((A +Int I1) +Int B) +Int I2 => (A +Int B) +Int (I1 +Int I2)
      requires notBool #isConcrete(A)
       andBool notBool #isConcrete(B)
       andBool #isConcrete(I1)
       andBool #isConcrete(I2)
      [simplification]

    rule (A +Int I1) +Int (B +Int I2) => (A +Int B) +Int (I1 +Int I2)
      requires notBool #isConcrete(A)
       andBool notBool #isConcrete(B)
       andBool #isConcrete(I1)
       andBool #isConcrete(I2)
      [simplification]

    rule chop(X +Int Y) => X +Int Y
      requires #range(0 <= X <= pow16)
       andBool #range(0 <= Y <  pow16)
      [simplification]

    rule X +Int Y <Int Z => X <Int Z -Int Y requires #isConcrete(Y) [simplification]

  // ########################
  // Gas
  // ########################

    //Generated by rule for #refund
    rule #gas(A1, B1, C1) +Int #gas(A2, B2, C2) => #gas(A1, B1 -Int A2 +Int B2, C1 +Int C2) [simplification]

    rule 0 <=Int X -Int #gas( A,  B,  C)             => true  requires #gas(A, B, C) <=Int X [simplification]
    rule         X -Int #gas(_A, _B, _C) <Int pow256 => true  requires X <Int pow256         [simplification]

    rule #gas(A1, B1, C1) -Int #gas(A1, B2, C2) => (B2 +Int C2) -Int (B1 +Int C1) [simplification]

    rule 0 <=Int #gas(_, _, _)             => true [simplification]
    rule         #gas(_, _, _) <Int pow256 => true [simplification]

endmodule
