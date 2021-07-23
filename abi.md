ABI Encoding
============

```k
requires "evm.md"
requires "buf.md"

module EVM-ABI
    imports EVM
    imports BUF
```

### ABI Call Data

When a function is called in the EVM, its arguments are encoded in a single byte-array and put in the so-called 'call data' section.
The encoding is defined in the [Ethereum contract application binary interface (ABI) specification](https://solidity.readthedocs.io/en/develop/abi-spec.html).
The eDSL provides `#abiCallData`, a notation to specify the ABI call data in a way similar to a high-level function call notation, defined below.
It specifies the function name and the (symbolic) arguments along with their types.
For example, the following notation represents a data that encodes a call to the `transfer` function with two arguments: `TO`, the receiver account address of type `address` (an 160-bit unsigned integer), and `VALUE`, the value to transfer of type `unit256` (a 256-bit unsigned integer).

```
  #abiCallData("transfer", #address(TO), #uint256(VALUE))
```

which denotes (indeed, is translated to) the following byte array:

```
  F1 : F2 : F3 : F4 : T1 : ... : T32 : V1 : ... : V32
```

where `F1 : F2 : F3 : F4` is the (two's complement) byte-array representation of `2835717307`, the first four bytes of the hash value of the `transfer` function signature, `keccak256("transfer(address,unit256)")`, and `T1 : ... : T32` and `V1 : ... : V32` are the byte-array representations of `TO` and `VALUE` respectively.

```k
    syntax TypedArg ::= #uint160 ( Int )
                      | #address ( Int )
                      | #uint256 ( Int )
                      | #uint48  ( Int )
                      | #uint16  ( Int )
                      | #uint8   ( Int )
                      | #int256  ( Int )
                      | #int128  ( Int )
                      | #bytes32 ( Int )
                      | #bool    ( Int )
                      | #bytes   ( ByteArray )
                      | #string  ( String )
                      | #array   ( TypedArg , Int , TypedArgs )
 // -----------------------------------------------------------

    syntax TypedArgs ::= List{TypedArg, ","} [klabel(typedArgs)]
 // ------------------------------------------------------------

    syntax ByteArray ::= #abiCallData ( String , TypedArgs ) [function]
 // -------------------------------------------------------------------
    rule #abiCallData( FNAME , ARGS ) => #signatureCallData(FNAME, ARGS) ++ #encodeArgs(ARGS)

    syntax ByteArray ::= #signatureCallData ( String, TypedArgs ) [function]
 // ------------------------------------------------------------------------
    rule #signatureCallData( FNAME , ARGS ) => #parseByteStack(substrString(Keccak256(#generateSignature(FNAME, ARGS)), 0, 8))

    syntax String ::= #generateSignature     ( String, TypedArgs ) [function, functional]
                    | #generateSignatureArgs ( TypedArgs )         [function, functional]
 // -------------------------------------------------------------------------------------
    rule #generateSignature( FNAME , ARGS ) => FNAME +String "(" +String #generateSignatureArgs(ARGS) +String ")"

    rule #generateSignatureArgs(.TypedArgs)                            => ""
    rule #generateSignatureArgs(TARGA:TypedArg, .TypedArgs)            => #typeName(TARGA)
    rule #generateSignatureArgs(TARGA:TypedArg, TARGB:TypedArg, TARGS) => #typeName(TARGA) +String "," +String #generateSignatureArgs(TARGB, TARGS)

    syntax String ::= #typeName ( TypedArg ) [function, functional]
 // ---------------------------------------------------------------
    rule #typeName(   #uint160( _ )) => "uint160"
    rule #typeName(   #address( _ )) => "address"
    rule #typeName(   #uint256( _ )) => "uint256"
    rule #typeName(    #uint48( _ )) => "uint48"
    rule #typeName(    #uint16( _ )) => "uint16"
    rule #typeName(     #uint8( _ )) => "uint8"
    rule #typeName(    #int256( _ )) => "int256"
    rule #typeName(    #int128( _ )) => "int128"
    rule #typeName(   #bytes32( _ )) => "bytes32"
    rule #typeName(      #bool( _ )) => "bool"
    rule #typeName(     #bytes( _ )) => "bytes"
    rule #typeName(    #string( _ )) => "string"
    rule #typeName( #array(T, _, _)) => #typeName(T) +String "[]"

    syntax ByteArray ::= #encodeArgs    ( TypedArgs )                               [function]
    syntax ByteArray ::= #encodeArgsAux ( TypedArgs , Int , ByteArray , ByteArray ) [function]
 // ------------------------------------------------------------------------------------------
    rule #encodeArgs(ARGS) => #encodeArgsAux(ARGS, #lenOfHeads(ARGS), .ByteArray, .ByteArray)

    rule #encodeArgsAux(.TypedArgs, _:Int, HEADS, TAILS) => HEADS ++ TAILS

    rule #encodeArgsAux((ARG, ARGS), OFFSET, HEADS, TAILS)
        => #encodeArgsAux(ARGS, OFFSET, HEADS ++ #enc(ARG), TAILS)
      requires #isStaticType(ARG)

    rule #encodeArgsAux((ARG, ARGS), OFFSET, HEADS, TAILS)
        => #encodeArgsAux(ARGS, OFFSET +Int #sizeOfDynamicType(ARG), HEADS ++ #enc(#uint256(OFFSET)), TAILS ++ #enc(ARG))
      requires notBool(#isStaticType(ARG))

    syntax Int ::= #lenOfHeads ( TypedArgs ) [function, functional]
 // ---------------------------------------------------------------
    rule #lenOfHeads(.TypedArgs) => 0
    rule #lenOfHeads(ARG, ARGS)  => #lenOfHead(ARG) +Int #lenOfHeads(ARGS)

    syntax Int ::= #lenOfHead ( TypedArg ) [function, functional]
 // -------------------------------------------------------------
    rule #lenOfHead(  #uint160( _ )) => 32
    rule #lenOfHead(  #address( _ )) => 32
    rule #lenOfHead(  #uint256( _ )) => 32
    rule #lenOfHead(   #uint48( _ )) => 32
    rule #lenOfHead(   #uint16( _ )) => 32
    rule #lenOfHead(    #uint8( _ )) => 32
    rule #lenOfHead(   #int256( _ )) => 32
    rule #lenOfHead(   #int128( _ )) => 32
    rule #lenOfHead(  #bytes32( _ )) => 32
    rule #lenOfHead(     #bool( _ )) => 32
    rule #lenOfHead(    #bytes( _ )) => 32
    rule #lenOfHead(   #string( _ )) => 32
    rule #lenOfHead(#array(_, _, _)) => 32

    syntax Bool ::= #isStaticType ( TypedArg ) [function, functional]
 // -----------------------------------------------------------------
    rule #isStaticType(  #uint160( _ )) => true
    rule #isStaticType(  #address( _ )) => true
    rule #isStaticType(  #uint256( _ )) => true
    rule #isStaticType(   #uint48( _ )) => true
    rule #isStaticType(   #uint16( _ )) => true
    rule #isStaticType(    #uint8( _ )) => true
    rule #isStaticType(   #int256( _ )) => true
    rule #isStaticType(   #int128( _ )) => true
    rule #isStaticType(  #bytes32( _ )) => true
    rule #isStaticType(     #bool( _ )) => true
    rule #isStaticType(    #bytes( _ )) => false
    rule #isStaticType(   #string( _ )) => false
    rule #isStaticType(#array(_, _, _)) => false

    syntax Int ::= #sizeOfDynamicType ( TypedArg ) [function]
 // ---------------------------------------------------------
    rule #sizeOfDynamicType(#bytes(BS)) => 32 +Int #ceil32(#sizeByteArray(BS))

    rule #sizeOfDynamicType(#array(T, N, _)) => 32 *Int (1 +Int N)
      requires #isStaticType(T)

    rule #sizeOfDynamicType(#array(T, N, ELEMS)) => 32 *Int (1 +Int N +Int #sizeOfDynamicTypeAux(ELEMS))
      requires notBool #isStaticType(T)

    syntax Int ::= #sizeOfDynamicTypeAux ( TypedArgs ) [function]
 // -------------------------------------------------------------
    rule #sizeOfDynamicTypeAux(TARG, TARGS) => #sizeOfDynamicType(TARG) +Int #sizeOfDynamicTypeAux(TARGS)
      requires notBool #isStaticType(TARG)

    rule #sizeOfDynamicTypeAux(.TypedArgs) => 0

    syntax ByteArray ::= #enc ( TypedArg ) [function]
 // -------------------------------------------------
    // static Type
    rule #enc(#uint160( DATA )) => #bufStrict(32, #getValue(#uint160( DATA )))
    rule #enc(#address( DATA )) => #bufStrict(32, #getValue(#address( DATA )))
    rule #enc(#uint256( DATA )) => #bufStrict(32, #getValue(#uint256( DATA )))
    rule #enc( #uint48( DATA )) => #bufStrict(32, #getValue( #uint48( DATA )))
    rule #enc( #uint16( DATA )) => #bufStrict(32, #getValue( #uint16( DATA )))
    rule #enc(  #uint8( DATA )) => #bufStrict(32, #getValue(  #uint8( DATA )))
    rule #enc( #int256( DATA )) => #bufStrict(32, #getValue( #int256( DATA )))
    rule #enc( #int128( DATA )) => #bufStrict(32, #getValue( #int128( DATA )))
    rule #enc(#bytes32( DATA )) => #bufStrict(32, #getValue(#bytes32( DATA )))
    rule #enc(   #bool( DATA )) => #bufStrict(32, #getValue(   #bool( DATA )))

    // dynamic Type
    rule #enc(        #bytes(BS)) => #encBytes(#sizeByteArray(BS), BS)
    rule #enc(#array(_, N, DATA)) => #enc(#uint256(N)) ++ #encodeArgs(DATA)
    rule #enc(      #string(STR)) => #enc(#bytes(#parseByteStackRaw(STR)))

    syntax ByteArray ::= #encBytes ( Int , ByteArray ) [function]
 // -------------------------------------------------------------
    rule #encBytes(N, BS) => #enc(#uint256(N)) ++ BS ++ #bufStrict(#ceil32(N) -Int N, 0)
```

```k
    syntax Int ::= #getValue ( TypedArg ) [function]
 // ------------------------------------------------
    rule #getValue(      #bool( X )) => X        requires #rangeBool(X)
    rule #getValue(   #address( X )) => #addr(X)
    rule #getValue(     #uint8( X )) => X        requires #rangeUInt(8, X)
    rule #getValue(    #uint16( X )) => X        requires #rangeUInt(16, X)
    rule #getValue(    #uint48( X )) => X        requires #rangeUInt(48, X)
    rule #getValue(   #uint160( X )) => X        requires #rangeUInt(160, X)
    rule #getValue(   #uint256( X )) => X        requires #rangeUInt(256, X)
    rule #getValue(    #int128( X )) => chop(X)  requires #rangeSInt(128, X)
    rule #getValue(    #int256( X )) => chop(X)  requires #rangeSInt(256, X)
    rule #getValue(   #bytes32( X )) => X        requires #rangeUInt(256, X)

    syntax Int ::= #ceil32 ( Int )
 // ------------------------------
    rule #ceil32(N) => (N up/Int 32) *Int 32 [macro]
```

This is the decoding of the typed arguments.

```k
    syntax TypedArg ::= #constructTypedArg ( String , String ) [function]
//  ---------------------------------------------------------------------
    rule #constructTypedArg(T, V) => #uint160  (              String2Base(V, 16) modInt pow160) requires T ==String "uint160"
    rule #constructTypedArg(T, V) => #address  (              String2Base(V, 16) modInt pow160) requires T ==String "address"
    rule #constructTypedArg(T, V) => #uint256  (              String2Base(V, 16) modInt pow256) requires T ==String "uint256"
    rule #constructTypedArg(T, V) => #uint48   (               String2Base(V, 16) modInt pow48) requires T ==String "uint48"
    rule #constructTypedArg(T, V) => #uint16   (               String2Base(V, 16) modInt pow16) requires T ==String "uint16"
    rule #constructTypedArg(T, V) => #uint8    (                 String2Base(V, 16) modInt 256) requires T ==String "uint8"
    rule #constructTypedArg(T, V) => #int256   ((String2Base(V, 16) modInt pow256) -Int pow256) requires T ==String "int256" andBool String2Base(V, 16) modInt pow256 >Int maxSInt256
    rule #constructTypedArg(T, V) => #int256   (              String2Base(V, 16) modInt pow256) requires T ==String "int256" andBool String2Base(V, 16) modInt pow256 <=Int maxSInt256
    rule #constructTypedArg(T, V) => #int128   ((String2Base(V, 16) modInt pow128) -Int pow128) requires T ==String "int128" andBool String2Base(V, 16) modInt pow128 >Int maxSInt128
    rule #constructTypedArg(T, V) => #int128   (              String2Base(V, 16) modInt pow128) requires T ==String "int128" andBool String2Base(V, 16) modInt pow128 <=Int maxSInt128
    rule #constructTypedArg(T, V) => #bytes    (                               String2Bytes(V)) requires T ==String "bytes"
    rule #constructTypedArg(T, V) => #bytes32  (                              #parseHexWord(V)) requires T ==String "bytes32"
    rule #constructTypedArg(T, V) => #bool     (                   String2Base(V, 16) modInt 2) requires T ==String "bool"
    rule #constructTypedArg(T, V) => #string   (                                             V) requires T ==String "string"
```

### ABI Event Logs

EVM logs are special data structures in the blockchain, being searchable by off-chain clients.
Events are high-level wrappers of the EVM logs provided in the high-level languages.
Contracts can declare and generate the events, which will be compiled down to the EVM bytecode using the EVM log instructions.
The encoding scheme of the events in the EVM logs is defined in the Ethereum contract application binary interface (ABI) specification, leveraging the ABI call data encoding scheme.

The eDSL provides `#abiEventLog`, a notation to specify the EVM logs in the high-level events, defined below.
It specifies the contract account address, the event name, and the event arguments.
For example, the following notation represents an EVM log data that encodes the `Transfer` event generated by the `transfer` function, where `ACCT_ID` is the account address, and `CALLER_ID`, `TO_ID`, and `VALUE` are the event arguments.
Each argument is tagged with its ABI type (`#address` or `#uint256`), and the `indexed` attribute (`#indexed`) if any, according to the event declaration in the contract.

```
  #abiEventLog(ACCT_ID, "Transfer", #indexed(#address(CALLER_ID)), #indexed(#address(TO_ID)), #uint256(VALUE))
```

The above notation denotes (i.e., is translated to) the following EVM log data structure:

```
  { ACCT_ID                                                                                                                                                                                                                                                  | |`
  | 100389287136786176327247604509743168900146139575972864366142685224231313322991
  : CALLER_ID                                                                                                                                                                                                                                                |/|
  : TO_ID                                                                                                                                                                                                                                                    | |
  : .WordStack                                                                                                                                                                                                                                               | |
  | #bufStrict(32, VALUE)                                                                                                                                                                                                                           | |
  }
```

where `100389287136786176327247604509743168900146139575972864366142685224231313322991` is the hash value of the event signature, `keccak256("Transfer(address,address,unit256)")`.

```k
    syntax EventArg ::= TypedArg
                      | #indexed ( TypedArg )
 // -----------------------------------------

    syntax EventArgs ::= List{EventArg, ","} [klabel(eventArgs)]
 // ------------------------------------------------------------

    syntax SubstateLogEntry ::= #abiEventLog ( Int , String , EventArgs ) [function]
 // --------------------------------------------------------------------------------
    rule #abiEventLog(ACCT_ID, EVENT_NAME, EVENT_ARGS)
      => { ACCT_ID | #getEventTopics(EVENT_NAME, EVENT_ARGS) | #encodeArgs(#getNonIndexedArgs(EVENT_ARGS)) }

    syntax List ::= #getEventTopics ( String , EventArgs ) [function]
 // -----------------------------------------------------------------
    rule #getEventTopics(ENAME, EARGS)
      => ListItem(#parseHexWord(Keccak256(#generateSignature(ENAME, #getTypedArgs(EARGS)))))
         #getIndexedArgs(EARGS)

    syntax TypedArgs ::= #getTypedArgs ( EventArgs ) [function]
 // -----------------------------------------------------------
    rule #getTypedArgs(#indexed(E), ES) => E, #getTypedArgs(ES)
    rule #getTypedArgs(E:TypedArg,  ES) => E, #getTypedArgs(ES)
    rule #getTypedArgs(.EventArgs)      => .TypedArgs

    syntax List ::= #getIndexedArgs ( EventArgs ) [function]
 // --------------------------------------------------------
    rule #getIndexedArgs(#indexed(E), ES) => ListItem(#getValue(E)) #getIndexedArgs(ES)
    rule #getIndexedArgs(_:TypedArg,  ES) =>                        #getIndexedArgs(ES)
    rule #getIndexedArgs(.EventArgs)      => .List

    syntax TypedArgs ::= #getNonIndexedArgs ( EventArgs ) [function]
 // ----------------------------------------------------------------
    rule #getNonIndexedArgs(#indexed(_), ES) =>    #getNonIndexedArgs(ES)
    rule #getNonIndexedArgs(E:TypedArg,  ES) => E, #getNonIndexedArgs(ES)
    rule #getNonIndexedArgs(.EventArgs)      => .TypedArgs
```

```k
endmodule
```
