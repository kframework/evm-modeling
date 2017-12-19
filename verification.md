KEVM Verification
=================

Using K's reachability logic theorem prover, we're able to verify many properties about EVM programs as reachability claims.
This module defines some helpers which make writing specifications simpler.

```{.k .uiuck}
requires "evm.k"

module VERIFICATION
    imports EVM
```

These `smt-lemma` helps Z3 reason about stack over/under flow,
and to keep various constraints down to reasonable sizes.

```{.k .uiuck}
    rule #sizeWordStack ( _ , _ ) >=Int 0 => true [smt-lemma]
    rule #sizeWordStack ( WS , N:Int )
      => #sizeWordStack ( WS , 0 ) +Int N
      requires N =/=K 0
      [lemma]

    rule (X -Int A) -Int B    =>  X -Int   (A +Int B)    [smt-lemma]
    rule ((X -Int A) >=Int B) => (X >=Int  (A +Int B))   [smt-lemma]
    rule (N +Int X <Int M)    =>  X <Int (M -Int N)      [smt-lemma]



    rule (X >=Int A ==K true) andBool ((X >=Int B ==K true) andBool P)
      => (X >=Int A ==K true) andBool P requires A >=Int B
         [smt-lemma]
    rule (X >=Int A ==K true) andBool ((X >=Int B ==K true) andBool P)
      => (X >=Int B ==K true) andBool P requires B >=Int A
         [smt-lemma]

    rule (N +Int X <Int M)                 => X <Int (M -Int N)                 [smt-lemma]
    rule 1 +Int (N +Int #sizeWordStack(S)) => (N +Int 1) +Int #sizeWordStack(S) [smt-lemma]

    rule (N +Int #sizeWordStack(S)) +Int 1  => (N +Int 1) +Int #sizeWordStack(S)    [smt-lemma]
    rule (N +Int #sizeWordStack(S)) +Int 0  =>  N +Int #sizeWordStack(S)            [smt-lemma]
    rule (N +Int #sizeWordStack(S)) +Int -1 => (N +Int -1) +Int #sizeWordStack(S)   [smt-lemma]
    rule (N +Int #sizeWordStack(S)) +Int -2 => (N +Int -2) +Int #sizeWordStack(S)   [smt-lemma]

    syntax WordStack ::= #uint(Int) [function, smtlib(uint256)]
 // -----------------------------------------------------------


    rule #take(N, #uint(X) ++ W) => #take(N, #uint(X))                           requires N <Int 32  [smt-lemma]
    rule #take(N, #uint(X))      => #uint(X) ++ #take(N -Int 32, .WordStack)     requires N >=Int 32 [smt-lemma]
    rule #take(N, #uint(X) ++ W) => #uint(X) ++ #take(N -Int 32, W)              requires N >=Int 32 [smt-lemma]
    rule #drop(N, #uint(X) ++ W) => #drop(N -Int 32, W)                          requires N >=Int 32 [smt-lemma]

    rule #asWordAux(N, (#uint(X) ++ W)) => #asWordAux(((N *Int pow256) +Int #getIntBytes(X, 0, 32, 0)), W)          [smt-lemma]
    rule #asWordAux(N, #uint(X))        => #asWordAux(((N *Int pow256) +Int #getIntBytes(X, 0, 32, 0)), .WordStack) [smt-lemma]

    rule #asWordAux(N, #take(K, #uint(X))) =>
         (N *Int (2 ^Int (K *Int 8)) +Int #getIntBytes(X, 32 -Int K, 32, 0)) %Int pow256

    rule #asWordAux(N, #uint(X))
         => #asWordAux(((N *Int pow256) +Int #getIntBytes(X, 0, 32, 0)), .WordStack) [smt-lemma]


    rule 0 +Int X => X

    rule Y  *Int (X +Int #getIntBytes(T, A, B, S)) => (X +Int #getIntBytes(T, A, B, S)) *Int Y
    rule (X +Int #getIntBytes(T, A, B, S)) *Int Y  =>  X *Int Y +Int #getIntBytes(T, A, B, S) *Int Y

    rule (X +Int #getIntBytes(T, A, B, S)) %Int Y  => X %Int Y +Int #getIntBytes(T, A, B, S) %Int Y
      requires X &Int ((2 ^Int B) -Int (2^Int A)) ==Int 0

    rule (X +Int #getIntBytes(T, A, B, S)) /Int Y  => X /Int Y +Int #getIntBytes(T, A, B, S) /Int Y
      requires X &Int ((2 ^Int B) -Int (2^Int A)) ==Int 0

    rule Y +Int (X +Int #getIntBytes(T, A, B, S)) => (Y +Int Y) +Int #getIntBytes(T, A, B, S)
    rule (X +Int #getIntBytes(T, A, B, S)) +Int Y => (X +Int Y) +Int #getIntBytes(T, A, B, S)

    rule #getIntBytes(T, A, B, S) *Int 256 => #getIntBytes(T, A, minInt(B, 31 -Int S), S +Int 1)

    rule #getIntBytes(T, A, B, S) %Int 115792089237316195423570985008687907853269984665640564039457584007913129639936
      => #getIntBytes(T, A, minInt(B, 32 -Int S), S)

    rule #getIntBytes(T, A, B, S) /Int D => #getIntBytes(T, A, B, S -Int 1) /Int (D /Int 256)
      requires S >Int 0 andBool D %Int 256 ==Int 0

    rule #getIntBytes(T, A, B, 0) /Int D => #getIntBytes(T, A +Int 1, B, 0) /Int (D /Int 256)
      requires A <Int B andBool D %Int 256 ==Int 0

    rule #getIntBytes(T, A, A, S)       => 0

    rule #getIntBytes(T, A, B, S) +Int 0 => #getIntBytes(T, A, B, S)

    rule 1461501637330902918203684832716283019655932542975 &Int #getIntBytes(T, A, B, S)
      => #getIntBytes(T, A, minInt(B, 20-Int S), S)

    rule #getIntBytes(T, 0, B, 0): (R:WordStack) => T %Int (2 ^Int (8 *Int B)): R [anywhere, lemma]


    syntax Int ::= #getIntBytes(Int, Int, Int, Int) [function, smtlib(get_int_bytes)]

    rule (X /Int Y) /Int 256 => X /Int (Y *Int 256) [lemma]
```

    #getIntBytes(T, A, B, S) representes an integer formed by division, mod,
    masking, etc. which corresponds to the number formed from bytes [A, B)
    from the big-endian representation of the number T, shifted left by S bytes.

    #getIntBytes(T, A, B, S) = ((T % 2^B) >> A) << S

```{.k .uiuck}
    rule X +Int 0 => X [smt-lemma]

    rule (X +Int Y) *Int A => (X *Int A) +Int (Y *Int A) [smt-lemma]
    rule (X +Int Y) %Int B => (X %Int B) +Int (Y %Int B) [smt-lemma]

    rule (X +Int Y) /Int N => (X /Int N) +Int (Y /Int N) requires X %Int N ==Int 0 [smt-lemma]
    rule (X *Int A) %Int B => (X %Int (B /Int A)) *Int A requires B %Int A ==Int 0 [smt-lemma]

    rule (X %Int M) %Int M => X %Int M                           [smt-lemma]
    rule (X %Int A) %Int B => X %Int B requires A %Int B ==Int 0 [smt-lemma]
    rule (X %Int A) %Int B => X %Int A requires B %Int A ==Int 0 [smt-lemma]

    rule (X %Int A) /Int B => (X /Int B) %Int (A /Int B) requires A %Int B ==Int 0 [smt-lemma]

    rule (X *Int A) *Int 256 => X *Int (A *Int 256)                         [smt-lemma]
    rule (X *Int A) /Int B   => X /Int (B /Int A) requires B %Int A ==Int 0 [smt-lemma]


    rule (((X *Int A) %Int M) *Int B) %Int M => (X *Int (A *Int B)) %Int M [smt-lemma]

    rule 1461501637330902918203684832716283019655932542975 &Int X => X %Int 1461501637330902918203684832716283019655932542976 [smt-lemma]
    rule X &Int 1461501637330902918203684832716283019655932542975 => X %Int 1461501637330902918203684832716283019655932542976 [smt-lemma]

    rule 115792089237316195423570985008687907853269984665640564039457584007913129639935 &Int X
      => X %Int 115792089237316195423570985008687907853269984665640564039457584007913129639936 [smt-lemma]
    rule X &Int 115792089237316195423570985008687907853269984665640564039457584007913129639935
      => X %Int 115792089237316195423570985008687907853269984665640564039457584007913129639936 [smt-lemma]

    rule 255 &Int X => X %Int 256 [smt-lemma]
    rule X &Int 255 => X %Int 256 [smt-lemma]

    rule (X +Int 0)             => X                                        [smt-lemma]
    rule (X /Int N) /Int 256    => X /Int (N *Int 256)                      [smt-lemma]
    rule X /Int N               => 0 requires X >=Int 0 andBool X <Int N    [smt-lemma]
    rule (X %Int A) /Int B      => 0 requires B >=Int A                     [smt-lemma]
```

Sum to N
--------

As a demonstration of simple reachability claims involing a circularity, we prove the EVM [Sum to N](proofs/sum-to-n.md) program correct.
This program sums the numbers from 1 to N (for sufficiently small N), including pre-conditions dis-allowing integer under/overflow and stack overflow.

```{.k .uiuck}
    syntax Map ::= "sumTo" "(" Int ")" [function]
 // ---------------------------------------------
    rule sumTo(N)
      => #asMapOpCodes( PUSH(1, 0) ; PUSH(32, N)                // s = 0 ; n = N
                      ; JUMPDEST                                // label:loop
                      ; DUP(1) ; ISZERO ; PUSH(1, 52) ; JUMPI   // if n == 0, jump to end
                      ; DUP(1) ; SWAP(2) ; ADD                  // s = s + n
                      ; SWAP(1) ; PUSH(1, 1) ; SWAP(1) ; SUB    // n = n - 1
                      ; PUSH(1, 35) ; JUMP                      // jump to loop
                      ; JUMPDEST                                // label:end
                      ; .OpCodes
                      ) [macro]
```

Hacker Gold (HKG) Token Smart Contract
--------------------------------------

Several proofs about the [HKG Token functions](proofs/hkg.md) have been performed.
These helper constants make writing the proof claims simpler/cleaner.

```{.k .uiuck}
    syntax Int ::= "%ACCT_1_BALANCE" [function]
                 | "%ACCT_2_BALANCE" [function]
                 | "%ACCT_1_ALLOWED" [function]
                 | "%ACCT_2_ALLOWED" [function]
                 | "%ACCT_ID"        [function]
                 | "%CALLER_ID"      [function]
                 | "%ORIGIN_ID"      [function]
                 | "%COINBASE_VALUE" [function]


    rule %ACCT_1_ALLOWED => 90140393717854041204577419487481777019768054268415728047989462811209962694062 [macro]
    rule %ACCT_2_BALANCE => 7523342389551220067180060596052511116626922476768911452708464109912271601147  [macro]
    rule %ACCT_1_BALANCE => 73276140668783822097736045772311176946506324369098798920944620499663575949472 [macro]
    rule %ACCT_2_ALLOWED => 89883370637028415006891042932604780869171597379948077832163656920795299088269 [macro]
    rule %ACCT_ID        => 87579061662017136990230301793909925042452127430                               [macro]
    rule %CALLER_ID      => 428365927726247537526132020791190998556166378203                              [macro]
    rule %ORIGIN_ID      => 116727156174188091019688739584752390716576765452                              [macro]
    rule %COINBASE_VALUE => 244687034288125203496486448490407391986876152250                              [macro]
    syntax WordStack ::= "%HKG_ProgramBytes"       [function]
                       | "%HKG_ProgramBytes_buggy" [function]
    syntax Map ::= "%HKG_Program"       [function]
                 | "%HKG_Program_buggy" [function]

    rule %HKG_ProgramBytes       => #parseByteStack("0x60606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063095ea7b31461006757806323b872dd146100be57806370a0823114610134578063a9059cbb1461017e578063dd62ed3e146101d5575bfe5b341561006f57fe5b6100a4600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803590602001909190505061023e565b604051808215151515815260200191505060405180910390f35b34156100c657fe5b61011a600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610331565b604051808215151515815260200191505060405180910390f35b341561013c57fe5b610168600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919050506105b2565b6040518082815260200191505060405180910390f35b341561018657fe5b6101bb600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919080359060200190919050506105fc565b604051808215151515815260200191505060405180910390f35b34156101dd57fe5b610228600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803573ffffffffffffffffffffffffffffffffffffffff1690602001909190505061076a565b6040518082815260200191505060405180910390f35b600081600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925846040518082815260200191505060405180910390a3600190505b92915050565b600081600160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054101580156103fe575081600260008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205410155b801561040a5750600082115b156105a15781600160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828254039250508190555081600160008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828254019250508190555081600260008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600082825403925050819055508273ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a3600190506105ab565b600090506105ab565b5b9392505050565b6000600160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205490505b919050565b600081600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020541015801561064d5750600082115b1561075a5781600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828254039250508190555081600160008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600082825401925050819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a360019050610764565b60009050610764565b5b92915050565b6000600260008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205490505b929150505600a165627a7a72305820955d4848f79dc023af4f6c233535c5c8d39532ebe7e7b64adbd933112556edf30029")                 [macro]
    rule %HKG_ProgramBytes_buggy => #parseByteStack("60606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063095ea7b31461006a57806323b872dd146100c457806370a082311461013d578063a9059cbb1461018a578063dd62ed3e146101e4575b600080fd5b341561007557600080fd5b6100aa600480803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610250565b604051808215151515815260200191505060405180910390f35b34156100cf57600080fd5b610123600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803573ffffffffffffffffffffffffffffffffffffffff16906020019091908035906020019091905050610343565b604051808215151515815260200191505060405180910390f35b341561014857600080fd5b610174600480803573ffffffffffffffffffffffffffffffffffffffff169060200190919050506105c4565b6040518082815260200191505060405180910390f35b341561019557600080fd5b6101ca600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803590602001909190505061060e565b604051808215151515815260200191505060405180910390f35b34156101ef57600080fd5b61023a600480803573ffffffffffffffffffffffffffffffffffffffff1690602001909190803573ffffffffffffffffffffffffffffffffffffffff16906020019091905050610773565b6040518082815260200191505060405180910390f35b600081600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925846040518082815260200191505060405180910390a3600190505b92915050565b600081600160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205410158015610410575081600260008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205410155b801561041c5750600082115b156105b35781600160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828254039250508190555081600160008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828254019250508190555081600260008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600082825403925050819055508273ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a3600190506105bd565b600090506105bd565b5b9392505050565b6000600160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205490505b919050565b600081600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020541015801561065f5750600082115b156107635781600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828254039250508190555081600160008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a36001905061076d565b6000905061076d565b5b92915050565b6000600260008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205490505b929150505600a165627a7a7230582093e640afb442869193a08cf82ed9577e403c7c53a6a95f589e2b673195da102e0029") [macro]

    rule %HKG_Program       => #asMapOpCodes(#dasmOpCodes(%HKG_ProgramBytes, DEFAULT))
    rule %HKG_Program_buggy => #asMapOpCodes(#dasmOpCodes(%HKG_ProgramBytes_buggy, DEFAULT))
```
ABI Calls
---------

The ABI Call mechanism provides syntatic sugar to make writing proofs easier.
Instead of manually populating the `<callData>` cell and `<pc>` cell with the right values,
we the sugar allows following conveniences -

 `#abiCallData(*FUNCTION_NAME*, TypedArgs)`, where the typed args to have be of the
 `#uint160(*DATA*)` where the types are from the ABI specification, and enclose
 the data.

The above constructs place the correct values (in accordance with the ABI) in the `<callData>`
cell, allowing proofs of ABI-compliant EVM program to begin at `<pc> 0 </pc>`.

```{.k .uiuck}
    syntax TypedArg ::= "#uint160"      "(" Int ")"
                      | "#address"      "(" Int ")"
                      | "#uint256"      "(" Int ")"

    syntax TypedArgs ::= List{TypedArg, ","}

    syntax WordStack ::= "#encodeArgs" "(" WordStack "|" TypedArgs ")"  [function]
                       | "#getData" "(" TypedArg ")"                    [function]


    syntax WordStack ::= #abiCallData( String , TypedArgs )             [function]

    syntax String ::= #typeName                 ( TypedArg )            [function]
                    | #generateSignature        ( String, TypedArgs)    [function]

    rule #abiCallData( FNAME , ARGS ) =>
                #parseByteStack(substrString(Keccak256(#generateSignature(FNAME +String "(", ARGS)), 0, 8))
                    ++ #encodeArgs(.WordStack | ARGS)

    rule #generateSignature(SIGN, TARGA, TARGB, TARGS)  => #generateSignature(SIGN +String #typeName(TARGA) +String ",", TARGB, TARGS)
    rule #generateSignature(SIGN, TARG, .TypedArgs)     => #generateSignature(SIGN +String #typeName(TARG), .TypedArgs)
    rule #generateSignature(SIGN, .TypedArgs)           => SIGN +String ")"

    rule #typeName(#uint160( _ ))                       => "uint160"
    rule #typeName(#address( _ ))                       => "address"
    rule #typeName(#uint256( _ ))                       => "uint256"

    rule #encodeArgs(WS | ARG, ARGS)            => #encodeArgs(WS ++ #getData(ARG) |  ARGS)
    rule #encodeArgs(WS | .TypedArgs)           => WS
    rule #encodeArgs(.WordStack | .TypedArgs)   => .WordStack

    rule #getData(#uint160( DATA ))             => #uint( DATA )
    rule #getData(#address( DATA ))             => #uint( DATA )
    rule #getData(#uint256( DATA ))             => #uint( DATA )
```

```{.k .uiuck}
endmodule
```

