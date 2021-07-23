requires "evm.md"

 //
 // Infinite Gas
 // Here we use the construct `#gas` to represent positive infinity, while tracking the gas formula through execution.
 // This allows (i) computing final gas used, and (ii) never stopping because of out-of-gas.
 // Note that the argument to `#gas(_)` is just metadata tracking the current gas usage, and is not meant to be compared to other values.
 // As such, any `#gas(G)` and `#gas(G')` are the _same_ positive infinite, regardless of the values `G` and `G'`.
 // In particular, this means that `#gas(_) <Int #gas(_) => false`, and `#gas(_) <=Int #gas(_) => true`, regardless of the values contained in the `#gas(_)`.
 //

module INFINITE-GAS
    imports INFINITE-GAS-JAVA
    imports INFINITE-GAS-HASKELL
endmodule

module INFINITE-GAS-HASKELL [kore]
    imports INFINITE-GAS-COMMON

    rule #gas(_)  <Int _C => false [concrete(_C), simplification]
    rule #gas(_) <=Int _C => false [concrete(_C), simplification]
    rule #gas(_) >=Int _C => true  [concrete(_C), simplification]
    rule _C <=Int #gas(_) => true  [concrete(_C), simplification]

    rule I1 +Int C2  <Int C3         => I1          <Int C3 -Int C2 [concrete(C2, C3), simplification]
    rule C1          <Int I2 +Int C3 => C1 -Int C3  <Int I2         [concrete(C1, C3), simplification]
    rule C1         <=Int I2 +Int C3 => C1 -Int C3 <=Int I2         [concrete(C1, C3), simplification]

    rule C1 +Int S2 => S2 +Int C1 [concrete(C1), symbolic(S2), simplification]

    rule S1 +Int (S2 +Int I3) => (S1 +Int S2) +Int I3 [symbolic(S1, S2), simplification]
    rule S1 +Int (S2 -Int I3) => (S1 +Int S2) -Int I3 [symbolic(S1, S2), simplification]
    rule S1 -Int (S2 +Int I3) => (S1 -Int S2) -Int I3 [symbolic(S1, S2), simplification]
    rule S1 -Int (S2 -Int I3) => (S1 -Int S2) +Int I3 [symbolic(S1, S2), simplification]

    rule S1 +Int (C2 -Int S3) => (S1 -Int S3) +Int C2 [symbolic(S1, S3), concrete(C2), simplification]
    rule S1 -Int (C2 -Int S3) => (S1 +Int S3) -Int C2 [symbolic(S1, S3), concrete(C2), simplification]

    rule (I1 +Int C2) +Int S3 => (I1 +Int S3) +Int C2 [concrete(C2), symbolic(S3), simplification]
    rule (I1 +Int C2) -Int S3 => (I1 -Int S3) +Int C2 [concrete(C2), symbolic(S3), simplification]
    rule (I1 -Int C2) +Int S3 => (I1 +Int S3) -Int C2 [concrete(C2), symbolic(S3), simplification]
    rule (I1 -Int C2) -Int S3 => (I1 -Int S3) -Int C2 [concrete(C2), symbolic(S3), simplification]

    rule (S1 +Int C2) +Int C3 => S1 +Int (C2 +Int C3) [concrete(C2, C3), symbolic(S1), simplification]
    rule (S1 +Int C2) -Int C3 => S1 +Int (C2 -Int C3) [concrete(C2, C3), symbolic(S1), simplification]
    rule (S1 -Int C2) +Int C3 => S1 +Int (C3 -Int C2) [concrete(C2, C3), symbolic(S1), simplification]
    rule (S1 -Int C2) -Int C3 => S1 -Int (C2 +Int C3) [concrete(C2, C3), symbolic(S1), simplification]
endmodule

module INFINITE-GAS-JAVA [kast]
    imports INFINITE-GAS-COMMON
    imports K-REFLECTION

    rule #gas(_)  <Int C => false requires #isConcrete(C) [simplification]
    rule #gas(_) <=Int C => false requires #isConcrete(C) [simplification]
    rule #gas(_) >=Int C => true  requires #isConcrete(C) [simplification]
    rule C <=Int #gas(_) => true  requires #isConcrete(C) [simplification]

    rule I1 +Int C2  <Int C3         => I1          <Int C3 -Int C2 requires #isConcrete(C2) andBool #isConcrete(C3) [simplification]
    rule C1          <Int I2 +Int C3 => C1 -Int C3  <Int I2         requires #isConcrete(C1) andBool #isConcrete(C3) [simplification]
    rule C1         <=Int I2 +Int C3 => C1 -Int C3 <=Int I2         requires #isConcrete(C1) andBool #isConcrete(C3) [simplification]

    rule C1 +Int S2 => S2 +Int C1 requires #isConcrete(C1) andBool notBool #isConcrete(S2) [simplification]

    rule S1 +Int (S2 +Int I3) => (S1 +Int S2) +Int I3 requires (notBool #isConcrete(S1)) andBool (notBool #isConcrete(S2)) [simplification]
    rule S1 +Int (S2 -Int I3) => (S1 +Int S2) -Int I3 requires (notBool #isConcrete(S1)) andBool (notBool #isConcrete(S2)) [simplification]
    rule S1 -Int (S2 +Int I3) => (S1 -Int S2) -Int I3 requires (notBool #isConcrete(S1)) andBool (notBool #isConcrete(S2)) [simplification]
    rule S1 -Int (S2 -Int I3) => (S1 -Int S2) +Int I3 requires (notBool #isConcrete(S1)) andBool (notBool #isConcrete(S2)) [simplification]

    rule S1 +Int (C2 -Int S3) => (S1 -Int S3) +Int C2 requires #isConcrete(C2) andBool (notBool #isConcrete(S1)) andBool (notBool #isConcrete(S3)) [simplification]
    rule S1 -Int (C2 -Int S3) => (S1 +Int S3) -Int C2 requires #isConcrete(C2) andBool (notBool #isConcrete(S1)) andBool (notBool #isConcrete(S3)) [simplification]

    rule (I1 +Int C2) +Int S3 => (I1 +Int S3) +Int C2 requires #isConcrete(C2) andBool notBool #isConcrete(S3) [simplification]
    rule (I1 +Int C2) -Int S3 => (I1 -Int S3) +Int C2 requires #isConcrete(C2) andBool notBool #isConcrete(S3) [simplification]
    rule (I1 -Int C2) +Int S3 => (I1 +Int S3) -Int C2 requires #isConcrete(C2) andBool notBool #isConcrete(S3) [simplification]
    rule (I1 -Int C2) -Int S3 => (I1 -Int S3) -Int C2 requires #isConcrete(C2) andBool notBool #isConcrete(S3) [simplification]

    rule (S1 +Int C2) +Int C3 => S1 +Int (C2 +Int C3) requires #isConcrete(C2) andBool #isConcrete(C3) andBool notBool #isConcrete(S1) [simplification]
    rule (S1 +Int C2) -Int C3 => S1 +Int (C2 -Int C3) requires #isConcrete(C2) andBool #isConcrete(C3) andBool notBool #isConcrete(S1) [simplification]
    rule (S1 -Int C2) +Int C3 => S1 +Int (C3 -Int C2) requires #isConcrete(C2) andBool #isConcrete(C3) andBool notBool #isConcrete(S1) [simplification]
    rule (S1 -Int C2) -Int C3 => S1 -Int (C2 +Int C3) requires #isConcrete(C2) andBool #isConcrete(C3) andBool notBool #isConcrete(S1) [simplification]
endmodule

module INFINITE-GAS-COMMON
    imports EVM

 // Generic rules

    rule (notBool (A andBool B)) andBool A => (notBool B) andBool A                      [simplification]
    rule #if B #then C +Int C1 #else C +Int C2 #fi => C +Int #if B #then C1 #else C2 #fi [simplification]

    rule I -Int I => 0                                                    [simplification]
    rule   (I1 -Int I2)                   +Int I2 =>  I1                  [simplification]
    rule  ((I1 -Int I2) -Int I3)          +Int I2 =>  I1 -Int I3          [simplification]
    rule (((I1 -Int I2) -Int I3) -Int I4) +Int I2 => (I1 -Int I3) -Int I4 [simplification]

    rule X -Int Y +Int Z <=Int A => false requires A <Int X -Int Y andBool 0 <=Int Z [simplification]

 // Symbolic Gas

    syntax Int ::= #gas ( Int , Int , Int )  [function]  // startGas, nonMemory, memory
 //-----------------------------------------------------------------------------------

    syntax Int ::= #gas ( Int ) [function, functional, no-evaluators, klabel(infGas), symbol, smtlib(infGas)]
 // ---------------------------------------------------------------------------------------------------------
    rule #gas(_, _, _) => #gas(0)

    rule #gas(G) +Int G' => #gas(G +Int G') requires 0 <=Int G' orBool 0 -Int G' <Int #gas(G)  [simplification]
    rule G +Int #gas(G') => #gas(G +Int G') requires 0 <=Int G  orBool 0 -Int G  <Int #gas(G') [simplification]

    rule #gas(G) -Int G' => #gas(G -Int G') requires 0 <=Int G' andBool G' <Int #gas(G) [simplification]

    rule #gas(G) *Int G' => #gas(G *Int G') requires 0 <=Int G' [simplification]
    rule G *Int #gas(G') => #gas(G *Int G') requires 0 <=Int G  [simplification]

    rule #gas(G) /Int G' => #gas(G /Int G') requires 0  <Int G' andBool G' <Int #gas(G)  [simplification]
    rule G /Int #gas(G') => 0               requires 0 <=Int G  andBool G  <Int #gas(G') [simplification]

    rule #gas(#gas(G)) => #gas(G) [simplification]

    rule #gas(G) -Int #gas(G') => #gas(G -Int G') [simplification]

    rule minInt(#gas(G), #gas(G'))              => #gas(minInt(G, G'))              [simplification]
    rule #if B #then #gas(G) #else #gas(G') #fi => #gas(#if B #then G #else G' #fi) [simplification]

    rule #allBut64th(#gas(G)) => #gas(#allBut64th(G)) [simplification]

    rule #gas(_)  <Int #gas(_) => false [simplification]
    rule #gas(_) <=Int #gas(_) => true  [simplification]

    rule #gas(_)  <Int I => false requires I <=Int pow256 [simplification]
    rule #gas(_) <=Int I => false requires I <=Int pow256 [simplification]
    rule #gas(_) >=Int I => true  requires I <=Int pow256 [simplification]

    rule I  <Int #gas(_) => true requires I <=Int pow256 [simplification]
    rule I <=Int #gas(_) => true requires I <=Int pow256 [simplification]

    rule I +Int I' <=Int #gas(G) => true requires                     I <=Int #gas(G) andBool I' <=Int #gas(G) [simplification]
    rule I -Int I' <=Int #gas(G) => true requires                     I <=Int #gas(G) andBool I' <=Int #gas(G) [simplification]
    rule I *Int I' <=Int #gas(G) => true requires                     I <=Int #gas(G) andBool I' <=Int #gas(G) [simplification]
    rule I /Int I' <=Int #gas(G) => true requires I' =/=Int 0 andBool I <=Int #gas(G) andBool I' <=Int #gas(G) [simplification]

    rule I *Int I' <Int #gas(G) => true requires I <Int #gas(G) andBool I' <Int #gas(G) [simplification]

    rule #gas(G) <Int I +Int I' => false requires                     notBool (#gas(G) <Int I orBool #gas(G) <Int I') [simplification]
    rule #gas(G) <Int I -Int I' => false requires                     notBool (#gas(G) <Int I orBool #gas(G) <Int I') [simplification]
    rule #gas(G) <Int I *Int I' => false requires                     notBool (#gas(G) <Int I orBool #gas(G) <Int I') [simplification]
    rule #gas(G) <Int I /Int I' => false requires I' =/=Int 0 andBool notBool (#gas(G) <Int I orBool #gas(G) <Int I') [simplification]

    rule #gas(G) <=Int I +Int I' => false requires                     notBool (#gas(G) <=Int I orBool #gas(G) <=Int I') [simplification]
    rule #gas(G) <=Int I -Int I' => false requires                     notBool (#gas(G) <=Int I orBool #gas(G) <=Int I') [simplification]
    rule #gas(G) <=Int I *Int I' => false requires                     notBool (#gas(G) <=Int I orBool #gas(G) <=Int I') [simplification]
    rule #gas(G) <=Int I /Int I' => false requires I' =/=Int 0 andBool notBool (#gas(G) <=Int I orBool #gas(G) <=Int I') [simplification]

    rule minInt(G, G') <Int G''  => G <Int G'' orBool G' <Int G''  [simplification]
    rule G  <Int minInt(G', G'') => G  <Int G' andBool G  <Int G'' [simplification]
    rule G <=Int minInt(G', G'') => G <=Int G' andBool G <=Int G'' [simplification]

    rule 0 <=Int Csstore(_, _, _, _)       => true  [simplification]
    rule Csstore(_, _, _, _) <Int #gas(_)  => true  [simplification]
    rule #gas(_)  <Int Csstore(_, _, _, _) => false [simplification]
    rule #gas(_) >=Int Csstore(_, _, _, _) => true  [simplification]

    rule 0 <=Int Csload(_, _)       => true  [simplification]
    rule Csload(_, _) <Int #gas(_)  => true  [simplification]
    rule #gas(_)  <Int Csload(_, _) => false [simplification]
    rule #gas(_) >=Int Csload(_, _) => true  [simplification]

    rule 0 <=Int Cmem(_, _)       => true  [simplification]
    rule Cmem(_, _) <Int #gas(_)  => true  [simplification]
    rule #gas(_) <Int Cmem(_, _)  => false [simplification]
    rule Cmem(_, _) <=Int #gas(_) => true  [simplification]

    rule 0 <=Int #allBut64th(_G)      => true                          [simplification]
    rule #allBut64th(G) <Int #gas(G') => true requires G <Int #gas(G') [simplification]

    rule 0 <=Int _:ScheduleConst < _:Schedule >       => true  [simplification]
    rule _:ScheduleConst < _:Schedule >  <Int #gas(_) => true  [simplification]
    rule _:ScheduleConst < _:Schedule > <=Int #gas(_) => true  [simplification]
    rule #gas(_) <Int _:ScheduleConst < _:Schedule >  => false [simplification]

    rule log2Int(_) <=Int #gas(_) => true  [simplification]
    rule #gas(_) <Int log2Int(_)  => false [simplification]

    rule 0 <=Int G up/Int _        => true  requires         0 <=Int G        [simplification]
    rule G up/Int _  <Int #gas(G') => true  requires         G  <Int #gas(G') [simplification]
    rule G up/Int _ <=Int #gas(G') => true  requires         G <=Int #gas(G') [simplification]
    rule #gas(G') <Int G up/Int _  => false requires notBool #gas(G') <Int G  [simplification]

    rule 0 <=Int X *Int Y => true requires 0 <=Int X andBool 0 <=Int Y [simplification]

    rule 0 <=Int Csload(_, _)       => true  [simplification]
    rule Csload(_, _) <Int #gas(_)  => true  [simplification]
    rule #gas(_) <Int Csload(_, _)  => false [simplification]
    rule Csload(_, _) <=Int #gas(_) => true  [simplification]

endmodule
