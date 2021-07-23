Parsing/Unparsing
=================

```k
requires "krypto.md"
requires "evm-types.md"
requires "json-rpc.md"
```

```k
module SERIALIZATION
    imports KRYPTO
    imports EVM-TYPES
    imports STRING-BUFFER
    imports JSON-EXT
```

Address/Hash Helpers
--------------------

-   `keccak` serves as a wrapper around the `Keccak256` in `KRYPTO`.

```k
    syntax Int ::= keccak ( ByteArray ) [function, functional, smtlib(smt_keccak)]
 // ------------------------------------------------------------------------------
    rule [keccak]: keccak(WS) => #parseHexWord(Keccak256(#unparseByteStack(WS)))
```

-   `#newAddr` computes the address of a new account given the address and nonce of the creating account.
-   `#sender` computes the sender of the transaction from its data and signature.
-   `#addrFromPrivateKey` computes the address of an account given its private key

```k
    syntax Int ::= #newAddr ( Int , Int ) [function]
                 | #newAddr ( Int , Int , ByteArray ) [function, klabel(#newAddrCreate2)]
 // -------------------------------------------------------------------------------------
    rule [#newAddr]:        #newAddr(ACCT, NONCE) => #addr(#parseHexWord(Keccak256(#rlpEncodeLength(#rlpEncodeBytes(ACCT, 20) +String #rlpEncodeWord(NONCE), 192))))
    rule [#newAddrCreate2]: #newAddr(ACCT, SALT, INITCODE) => #addr(#parseHexWord(Keccak256("\xff" +String #unparseByteStack(#padToWidth(20, #asByteStack(ACCT))) +String #unparseByteStack(#padToWidth(32, #asByteStack(SALT))) +String #unparseByteStack(#parseHexBytes(Keccak256(#unparseByteStack(INITCODE)))))))

    syntax Account ::= #sender ( Int , Int , Int , Account , Int , String , Int , ByteArray , ByteArray, Int )                  [function]
                     | #sender ( String , Int , String , String )                                                               [function, klabel(#senderAux)]
                     | #sender ( String )                                                                                       [function, klabel(#senderAux2)]
                     | #sender ( Int , Int , Int , Int , Int , Account , Int , String , JSONs , Int , ByteArray, ByteArray )    [function, klabel(#senderAux3)]
 // -----------------------------------------------------------------------------------------------------------------------------------------------------------
    rule #sender(TN, TP, TG, TT, TV, DATA, TW, TR, TS, _CID)
      => #sender(#unparseByteStack(#parseHexBytes(#hashUnsignedTx(TN, TP, TG, TT, TV, #parseByteStackRaw(DATA)))), TW, #unparseByteStack(TR), #unparseByteStack(TS))
      requires TW ==Int 27 orBool TW ==Int 28

    rule #sender(TN, TP, TG, TT, TV, DATA, TW, TR, TS, CID)
      => #sender(#unparseByteStack(#parseHexBytes(#hashUnsignedTx(TN, TP, TG, TT, TV, #parseByteStackRaw(DATA), CID))), 28 -Int (TW %Int 2), #unparseByteStack(TR), #unparseByteStack(TS))
      requires TW ==Int CID *Int 2 +Int 35 orBool TW ==Int CID *Int 2 +Int 36

    rule #sender(TYPE, CID, TN, TP, TG, TT, TV, TD, TA, TW, TR, TS)
      => #sender(#unparseByteStack(#parseHexBytes(#hashUnsignedTxT1(TYPE, CID, TN, TP, TG, TT, TV, #parseByteStackRaw(TD), TA))), TW +Int 27, #unparseByteStack(TR), #unparseByteStack(TS))
      requires TW ==Int 0 orBool TW ==Int 1

    rule #sender(_, _, _, _, _, _, _, _, _, _) => .Account [owise]

    rule #sender(HT, TW, TR, TS) => #sender(ECDSARecover(HT, TW, TR, TS))

    rule #sender("")  => .Account
    rule #sender(STR) => #addr(#parseHexWord(Keccak256(STR))) requires STR =/=String ""

    syntax Int ::= #addrFromPrivateKey ( String ) [function]
 // --------------------------------------------------------
    rule #addrFromPrivateKey ( KEY ) => #addr( #parseHexWord( Keccak256 ( Hex2Raw( ECDSAPubKey( Hex2Raw( KEY ) ) ) ) ) )
```

-   `#blockHeaderHash` computes the hash of a block header given all the block data.

```k
    syntax Int ::= #blockHeaderHash( Int , Int , Int , Int , Int , Int , ByteArray , Int , Int , Int , Int , Int , ByteArray , Int , Int ) [function, klabel(blockHeaderHash), symbol]
                 | #blockHeaderHash(String, String, String, String, String, String, String, String, String, String, String, String, String, String, String) [function, klabel(#blockHashHeaderStr), symbol]
 // -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   rule #blockHeaderHash(HP, HO, HC, HR, HT, HE, HB, HD, HI, HL, HG, HS, HX, HM, HN)
         => #blockHeaderHash(#asWord(#parseByteStackRaw(HP)),
                             #asWord(#parseByteStackRaw(HO)),
                             #asWord(#parseByteStackRaw(HC)),
                             #asWord(#parseByteStackRaw(HR)),
                             #asWord(#parseByteStackRaw(HT)),
                             #asWord(#parseByteStackRaw(HE)),
                                     #parseByteStackRaw(HB) ,
                             #asWord(#parseByteStackRaw(HD)),
                             #asWord(#parseByteStackRaw(HI)),
                             #asWord(#parseByteStackRaw(HL)),
                             #asWord(#parseByteStackRaw(HG)),
                             #asWord(#parseByteStackRaw(HS)),
                                     #parseByteStackRaw(HX) ,
                             #asWord(#parseByteStackRaw(HM)),
                             #asWord(#parseByteStackRaw(HN)))

    rule #blockHeaderHash(HP, HO, HC, HR, HT, HE, HB, HD, HI, HL, HG, HS, HX, HM, HN)
         => #parseHexWord(Keccak256(#rlpEncodeLength(         #rlpEncodeBytes(HP, 32)
                                                      +String #rlpEncodeBytes(HO, 32)
                                                      +String #rlpEncodeBytes(HC, 20)
                                                      +String #rlpEncodeBytes(HR, 32)
                                                      +String #rlpEncodeBytes(HT, 32)
                                                      +String #rlpEncodeBytes(HE, 32)
                                                      +String #rlpEncodeString(#unparseByteStack(HB))
                                                      +String #rlpEncodeWordStack(HD : HI : HL : HG : HS : .WordStack)
                                                      +String #rlpEncodeString(#unparseByteStack(HX))
                                                      +String #rlpEncodeBytes(HM, 32)
                                                      +String #rlpEncodeBytes(HN, 8),
                                                    192)))

```

- `#hashSignedTx` Takes transaction data. Returns the hash of the rlp-encoded transaction with R S and V.
- `#hashUnsignedTx` Returns the hash of the rlp-encoded transaction without R S or V.

```k
    syntax String ::= #hashSignedTx     ( Int , Int , Int , Account , Int , ByteArray , Int , ByteArray , ByteArray ) [function]
                    | #hashUnsignedTx   ( Int , Int , Int , Account , Int , ByteArray )                               [function]
                    | #hashUnsignedTx   ( Int , Int , Int , Account , Int , ByteArray, Int )                          [function]
                    | #hashUnsignedTxT1 ( Int , Int , Int , Int , Int , Account , Int , ByteArray , JSONs )           [function]
 // ----------------------------------------------------------------------------------------------------------------------------
    rule [hashTx]: #hashSignedTx(TN, TP, TG, TT, TV, TD, TW, TR, TS)
                => Keccak256( #rlpEncodeTransaction(TN, TP, TG, TT, TV, TD, TW, TR, TS) )

    rule [hashFakeTx]: #hashUnsignedTx(TN, TP, TG, TT, TV, TD)
                    => Keccak256( #rlpEncodeLength(         #rlpEncodeWord(TN)
                                                    +String #rlpEncodeWord(TP)
                                                    +String #rlpEncodeWord(TG)
                                                    +String #rlpEncodeAccount(TT)
                                                    +String #rlpEncodeWord(TV)
                                                    +String #rlpEncodeString(#unparseByteStack(TD))
                                                  , 192
                                                  )
                                )

    rule [hashFakeTx2]: #hashUnsignedTx(TN, TP, TG, TT, TV, TD, CID)
                     => Keccak256( #rlpEncodeLength(         #rlpEncodeWord(TN)
                                                     +String #rlpEncodeWord(TP)
                                                     +String #rlpEncodeWord(TG)
                                                     +String #rlpEncodeAccount(TT)
                                                     +String #rlpEncodeWord(TV)
                                                     +String #rlpEncodeString(#unparseByteStack(TD))
                                                     +String #rlpEncodeWord(CID)
                                                     +String #rlpEncodeString("")
                                                     +String #rlpEncodeString("")
                                                   , 192
                                                   )
                                 )

    rule [hashFakeTxT1]: #hashUnsignedTxT1(TYPE, CID, TN, TP, TG, TT, TV, TD, [TA])
                      => Keccak256(       #rlpEncodeBytes(TYPE,1)
                                  +String #rlpEncodeLength(         #rlpEncodeWord(CID)
                                                            +String #rlpEncodeWord(TN)
                                                            +String #rlpEncodeWord(TP)
                                                            +String #rlpEncodeWord(TG)
                                                            +String #rlpEncodeAccount(TT)
                                                            +String #rlpEncodeWord(TV)
                                                            +String #rlpEncodeString(#unparseByteStack(TD))
                                                            +String #rlpEncodeAccessList([TA], "")
                                                          , 192
                                                          )
                                  )
```

The EVM test-sets are represented in JSON format with hex-encoding of the data and programs.
Here we provide some standard parser/unparser functions for that format.

Parsing
-------

These parsers can interperet hex-encoded strings as `Int`s, `ByteArray`s, and `Map`s.

-   `#parseHexWord` interprets a string as a single hex-encoded `Word`.
-   `#parseHexBytes` interprets a string as a hex-encoded stack of bytes.
-   `#alignHexString` makes sure that the length of a (hex)string is even.
-   `#parseByteStack` interprets a string as a hex-encoded stack of bytes, but makes sure to remove the leading "0x".
-   `#parseByteStackRaw` casts a string as a stack of bytes, ignoring any encoding.
-   `#parseWordStack` interprets a JSON list as a stack of `Word`.
-   `#parseMap` interprets a JSON key/value object as a map from `Word` to `Word`.
-   `#parseAddr` interprets a string as a 160 bit hex-endcoded address.
-   `#parseAccessListStorageKeys` interprets a JSON list object as a Set, casting each string element as a `Word`.

```k
    syntax Int ::= #parseHexWord ( String ) [function]
                 | #parseWord    ( String ) [function]
 // --------------------------------------------------
    rule #parseHexWord("")   => 0
    rule #parseHexWord("0x") => 0
    rule #parseHexWord(S)    => String2Base(replaceAll(S, "0x", ""), 16) requires (S =/=String "") andBool (S =/=String "0x")

    rule #parseWord("") => 0
    rule #parseWord(S)  => #parseHexWord(S) requires lengthString(S) >=Int 2 andBool substrString(S, 0, 2) ==String "0x"
    rule #parseWord(S)  => String2Int(S) [owise]

    syntax String ::= #alignHexString ( String ) [function, functional]
 // -------------------------------------------------------------------
    rule #alignHexString(S) => S             requires         lengthString(S) modInt 2 ==Int 0
    rule #alignHexString(S) => "0" +String S requires notBool lengthString(S) modInt 2 ==Int 0
```

```{.k .bytes}
    syntax ByteArray ::= #parseHexBytes     ( String ) [function]
                       | #parseHexBytesAux  ( String ) [function]
                       | #parseByteStack    ( String ) [function, memo]
                       | #parseByteStackRaw ( String ) [function]
 // -------------------------------------------------------------------
    rule #parseByteStack(S) => #parseHexBytes(replaceAll(S, "0x", ""))

    rule #parseHexBytes(S)  => #parseHexBytesAux(#alignHexString(S))
    rule #parseHexBytesAux("") => .ByteArray
    rule #parseHexBytesAux(S)  => Int2Bytes(lengthString(S) /Int 2, String2Base(S, 16), BE)
      requires lengthString(S) >=Int 2

    rule #parseByteStackRaw(S) => String2Bytes(S)
```

```{.k .nobytes}
    syntax ByteArray ::= #parseHexBytes     ( String ) [function]
                       | #parseHexBytesAux  ( String ) [function]
                       | #parseByteStack    ( String ) [function]
                       | #parseByteStackRaw ( String ) [function]
 // -------------------------------------------------------------
    rule #parseByteStack(S) => #parseHexBytes(replaceAll(S, "0x", ""))

    rule #parseHexBytes(S)  => #parseHexBytesAux(#alignHexString(S))
    rule #parseHexBytesAux("") => .WordStack
    rule #parseHexBytesAux(S)  => #parseHexWord(substrString(S, 0, 2)) : #parseHexBytesAux(substrString(S, 2, lengthString(S)))
       requires lengthString(S) >=Int 2

    rule #parseByteStackRaw(S) => ordChar(substrString(S, 0, 1)) : #parseByteStackRaw(substrString(S, 1, lengthString(S))) requires lengthString(S) >=Int 1
    rule #parseByteStackRaw("") => .WordStack
```

```k
    syntax Map ::= #parseMap ( JSON ) [function]
 // --------------------------------------------
    rule #parseMap( { .JSONs                      } ) => .Map
    rule #parseMap( { _   : (VALUE:String) , REST } ) => #parseMap({ REST })                                                requires #parseHexWord(VALUE) ==K 0
    rule #parseMap( { KEY : (VALUE:String) , REST } ) => #parseMap({ REST }) [ #parseHexWord(KEY) <- #parseHexWord(VALUE) ] requires #parseHexWord(VALUE) =/=K 0

    syntax Int ::= #parseAddr ( String ) [function]
 // -----------------------------------------------
    rule #parseAddr(S) => #addr(#parseHexWord(S))

   syntax List ::= #parseAccessListStorageKeys ( JSONs )        [function]
                 | #parseAccessListStorageKeys ( JSONs , List ) [function, klabel(#parseAccessListStorageKeysAux)]
 // --------------------------------------------------------------------------------------------------------------
    rule #parseAccessListStorageKeys( J                           ) => #parseAccessListStorageKeys(J, .List)
    rule #parseAccessListStorageKeys([S:String, REST], RESULT:List) => #parseAccessListStorageKeys([REST], ListItem(#asWord(#parseByteStackRaw(S))) RESULT )
    rule #parseAccessListStorageKeys([ .JSONs       ], RESULT:List) => RESULT
```

Unparsing
---------

We need to interperet a `ByteArray` as a `String` again so that we can call `Keccak256` on it from `KRYPTO`.

-   `#unparseByteStack` turns a stack of bytes (as a `ByteArray`) into a `String`.
-   `#padByte` ensures that the `String` interperetation of a `Int` is wide enough.

```{.k .bytes}
    syntax String ::= #unparseByteStack ( ByteArray ) [function, klabel(unparseByteStack), symbol]
 // ----------------------------------------------------------------------------------------------
    rule #unparseByteStack(WS) => Bytes2String(WS)
```

```{.k .nobytes}
    syntax String ::= #unparseByteStack ( ByteArray )                [function, klabel(unparseByteStack), symbol]
                    | #unparseByteStack ( ByteArray , StringBuffer ) [function, klabel(#unparseByteStackAux)]
 // ---------------------------------------------------------------------------------------------------------
    rule #unparseByteStack ( WS ) => #unparseByteStack(WS, .StringBuffer)

    rule #unparseByteStack( .WordStack, BUFFER ) => StringBuffer2String(BUFFER)
    rule #unparseByteStack( W : WS, BUFFER )     => #unparseByteStack(WS, BUFFER +String chrChar(W modInt (2 ^Int 8)))
```

```k
    syntax String ::= #padByte( String ) [function]
 // -----------------------------------------------
    rule #padByte( S ) => S             requires lengthString(S) ==K 2
    rule #padByte( S ) => "0" +String S requires lengthString(S) ==K 1

    syntax String ::= #unparseQuantity( Int ) [function]
 // ----------------------------------------------------
    rule #unparseQuantity( I ) => "0x" +String Base2String(I, 16)

    syntax String ::= #unparseData          ( Int, Int  ) [function]
                    | #unparseDataByteArray ( ByteArray ) [function]
 // ----------------------------------------------------------------
    rule #unparseData( DATA, LENGTH ) => #unparseDataByteArray(#padToWidth(LENGTH,#asByteStack(DATA)))

    rule #unparseDataByteArray( DATA ) => replaceFirst(Base2String(#asInteger(#asByteStack(1) ++ DATA), 16), "1", "0x")
```

String Helper Functions
-----------------------

- `Hex2Raw` Takes a string of hex encoded bytes and converts it to a raw bytestring
- `Raw2Hex` Takes a string of raw bytes and converts it to a hex representation

```k
    syntax String ::= Hex2Raw ( String ) [function]
                    | Raw2Hex ( String ) [function]
 // -----------------------------------------------
    rule Hex2Raw ( S ) => #unparseByteStack( #parseByteStack ( S ) )
    rule Raw2Hex ( S ) => #unparseDataByteArray( #parseByteStackRaw ( S ) )
```

Recursive Length Prefix (RLP)
=============================

RLP encoding is used extensively for executing the blocks of a transaction.
For details about RLP encoding, see the [YellowPaper Appendix B](http://gavwood.com/paper.pdf).

Encoding
--------

-   `#rlpEncodeWord` RLP encodes a single EVM word.
-   `#rlpEncodeString` RLP encodes a single `String`.

```k
    syntax String ::= #rlpEncodeWord ( Int )            [function]
                    | #rlpEncodeBytes ( Int , Int )     [function]
                    | #rlpEncodeWordStack ( WordStack ) [function]
                    | #rlpEncodeString ( String )       [function]
                    | #rlpEncodeAccount ( Account )     [function]
 // --------------------------------------------------------------
    rule #rlpEncodeWord(0) => "\x80"
    rule #rlpEncodeWord(WORD) => chrChar(WORD) requires WORD >Int 0 andBool WORD <Int 128
    rule #rlpEncodeWord(WORD) => #rlpEncodeLength(#unparseByteStack(#asByteStack(WORD)), 128) requires WORD >=Int 128

    rule #rlpEncodeBytes(WORD, LEN) => #rlpEncodeString(#unparseByteStack(#padToWidth(LEN, #asByteStack(WORD))))

    rule #rlpEncodeWordStack(.WordStack) => ""
    rule #rlpEncodeWordStack(W : WS)     => #rlpEncodeWord(W) +String #rlpEncodeWordStack(WS)

    rule #rlpEncodeString(STR) => "\x80"                     requires lengthString(STR)  <Int 1
    rule #rlpEncodeString(STR) => STR                        requires lengthString(STR) ==Int 1 andBool ordChar(substrString(STR, 0, 1)) <Int 128
    rule #rlpEncodeString(STR) => #rlpEncodeLength(STR, 128) [owise]

    rule #rlpEncodeAccount(.Account) => "\x80"
    rule #rlpEncodeAccount(ACCT)     => #rlpEncodeBytes(ACCT, 20) requires ACCT =/=K .Account

    syntax String ::= #rlpEncodeLength ( String , Int )          [function]
                    | #rlpEncodeLength ( String , Int , String ) [function, klabel(#rlpEncodeLengthAux)]
 // ----------------------------------------------------------------------------------------------------
    rule #rlpEncodeLength(STR, OFFSET) => chrChar(lengthString(STR) +Int OFFSET) +String STR                                requires           lengthString(STR) <Int 56
    rule #rlpEncodeLength(STR, OFFSET) => #rlpEncodeLength(STR, OFFSET, #unparseByteStack(#asByteStack(lengthString(STR)))) requires notBool ( lengthString(STR) <Int 56 )
    rule #rlpEncodeLength(STR, OFFSET, BL) => chrChar(lengthString(BL) +Int OFFSET +Int 55) +String BL +String STR

    syntax String ::= #rlpEncodeTransaction( Int , Int , Int , Account , Int , ByteArray , Int , ByteArray , ByteArray ) [function]
 // -------------------------------------------------------------------------------------------------------------------------------
    rule [rlpTx]: #rlpEncodeTransaction(TN, TP, TG, TT, TV, TD, TW, TR, TS)
               => #rlpEncodeLength(         #rlpEncodeWord(TN)
                                    +String #rlpEncodeWord(TP)
                                    +String #rlpEncodeWord(TG)
                                    +String #rlpEncodeAccount(TT)
                                    +String #rlpEncodeWord(TV)
                                    +String #rlpEncodeString(#unparseByteStack(TD))
                                    +String #rlpEncodeWord(TW)
                                    +String #rlpEncodeString(#unparseByteStack(#asByteStack(#asWord(TR))))
                                    +String #rlpEncodeString(#unparseByteStack(#asByteStack(#asWord(TS))))
                                  , 192
                                  )

    syntax String ::= #rlpEncodeFullAccount( Int, Int, Map, ByteArray ) [function]
 // ------------------------------------------------------------------------------
    rule [rlpAcct]: #rlpEncodeFullAccount( NONCE, BAL, STORAGE, CODE )
                 => #rlpEncodeLength(         #rlpEncodeWord(NONCE)
                                      +String #rlpEncodeWord(BAL)
                                      +String #rlpEncodeString( Hex2Raw( Keccak256( #rlpEncodeMerkleTree( #storageRoot( STORAGE ) ) ) ) )
                                      +String #rlpEncodeString( Hex2Raw( Keccak256( #unparseByteStack( CODE ) ) ) )
                                    , 192
                                    )

    syntax String ::= #rlpEncodeReceipt ( Int , Int , ByteArray , List ) [function]
                    | #rlpEncodeLogs    ( List )                         [function]
                    | #rlpEncodeLogsAux ( List, String )                 [function]
                    | #rlpEncodeTopics  ( List, String )                 [function]
 // -------------------------------------------------------------------------------
    rule [rlpReceipt]: #rlpEncodeReceipt(RS, RG, RB, RL)
                    => #rlpEncodeLength(         #rlpEncodeWord(RS)
                                         +String #rlpEncodeWord(RG)
                                         +String #rlpEncodeString(#unparseByteStack(RB))
                                         +String #rlpEncodeLogs(RL)
                                       , 192
                                       )

    rule #rlpEncodeLogs( LOGS ) => #rlpEncodeLogsAux( LOGS, "" )

    rule #rlpEncodeLogsAux( .List, OUT ) => #rlpEncodeLength(OUT,192)
    rule #rlpEncodeLogsAux( ( ListItem({ ACCT | TOPICS | DATA }) => .List ) _
                          , ( OUT => OUT +String #rlpEncodeLength(         #rlpEncodeBytes(ACCT,20)
                                                                   +String #rlpEncodeTopics(TOPICS,"")
                                                                   +String #rlpEncodeString(#unparseByteStack(DATA))
                                                                 , 192
                                                                 )
                            )
                          )

    rule #rlpEncodeTopics( .List, OUT ) => #rlpEncodeLength(OUT,192)
    rule #rlpEncodeTopics( ( ListItem( X:Int ) => .List ) _
                         , ( OUT => OUT +String #rlpEncodeBytes(X,32) )
                         )

    syntax String ::= #rlpEncodeMerkleTree ( MerkleTree ) [function]
 // ----------------------------------------------------------------
    rule #rlpEncodeMerkleTree ( .MerkleTree ) => "\x80"

    rule #rlpEncodeMerkleTree ( MerkleLeaf ( PATH, VALUE ) )
      => #rlpEncodeLength(         #rlpEncodeString( #unparseByteStack( #HPEncode( PATH, 1 ) ) )
                           +String #rlpEncodeString( VALUE )
                         , 192
                         )

    rule #rlpEncodeMerkleTree ( MerkleExtension ( PATH, TREE ) )
      => #rlpEncodeLength(         #rlpEncodeString( #unparseByteStack( #HPEncode( PATH, 0 ) ) )
                           +String #rlpMerkleH( #rlpEncodeMerkleTree( TREE ) )
                         , 192
                         )

    rule #rlpEncodeMerkleTree ( MerkleBranch ( M , VALUE ) )
      => #rlpEncodeLength(         MerkleMapRLP(M, 0) +String MerkleMapRLP(M, 1)
                           +String MerkleMapRLP(M, 2) +String MerkleMapRLP(M, 3)
                           +String MerkleMapRLP(M, 4) +String MerkleMapRLP(M, 5)
                           +String MerkleMapRLP(M, 6) +String MerkleMapRLP(M, 7)
                           +String MerkleMapRLP(M, 8) +String MerkleMapRLP(M, 9)
                           +String MerkleMapRLP(M,10) +String MerkleMapRLP(M,11)
                           +String MerkleMapRLP(M,12) +String MerkleMapRLP(M,13)
                           +String MerkleMapRLP(M,14) +String MerkleMapRLP(M,15)
                           +String #rlpEncodeString( VALUE )
                         , 192
                         )

    syntax String ::= MerkleMapRLP( Map, Int ) [function]
 // -----------------------------------------------------
    rule MerkleMapRLP(M, I) => #rlpMerkleH( #rlpEncodeMerkleTree( { M[I] orDefault .MerkleTree }:>MerkleTree ) )

    syntax String ::= #rlpMerkleH ( String ) [function,klabel(MerkleRLPAux)]
 // ------------------------------------------------------------------------
    rule #rlpMerkleH ( X ) => #rlpEncodeString( Hex2Raw( Keccak256( X ) ) )
      requires lengthString(X) >=Int 32

    rule #rlpMerkleH ( X ) => X
      requires notBool lengthString(X) >=Int 32

    syntax String ::= #rlpEncodeJSONBytes ( JSONs , String ) [function]
 // -------------------------------------------------------------------
    rule #rlpEncodeJSONBytes([ S:String, REST ], RESULT:String) => #rlpEncodeJSONBytes([REST], RESULT +String #rlpEncodeBytes(#asWord(#parseByteStackRaw(S)),32))
    rule #rlpEncodeJSONBytes([.JSONs ], RESULT:String) => #rlpEncodeLength(RESULT, 192)

    syntax String ::= #rlpEncodeAccessList ( JSONs , String ) [function]
 // --------------------------------------------------------------------
    rule #rlpEncodeAccessList([[A, [S:JSONs]], REST], RESULT:String) => #rlpEncodeAccessList([REST], RESULT +String #rlpEncodeLength(#rlpEncodeAccount(#asAccount(#parseByteStackRaw(A))) +String #rlpEncodeJSONBytes([S],""), 192 ))
    rule #rlpEncodeAccessList([.JSONs], RESULT:String) => #rlpEncodeLength(RESULT, 192)
```

Decoding
--------

-   `#rlpDecode` RLP decodes a single `String` into a `JSON`.
-   `#rlpDecodeList` RLP decodes a single `String` into a `JSONs`, interpereting the string as the RLP encoding of a list.

```k
    syntax JSON ::= #rlpDecode(String)               [function]
                  | #rlpDecode(String, LengthPrefix) [function, klabel(#rlpDecodeAux)]
 // ----------------------------------------------------------------------------------
    rule #rlpDecode(STR) => #rlpDecode(STR, #decodeLengthPrefix(STR, 0))
    rule #rlpDecode(STR,  #str( LEN, POS)) => substrString(STR, POS, POS +Int LEN)
    rule #rlpDecode(STR, #list(_LEN, POS)) => [#rlpDecodeList(STR, POS)]

    syntax JSONs ::= #rlpDecodeList(String, Int)               [function]
                   | #rlpDecodeList(String, Int, LengthPrefix) [function, klabel(#rlpDecodeListAux)]
 // ------------------------------------------------------------------------------------------------
    rule #rlpDecodeList(STR, POS) => #rlpDecodeList(STR, POS, #decodeLengthPrefix(STR, POS)) requires POS <Int lengthString(STR)
    rule #rlpDecodeList(  _,   _) => .JSONs [owise]
    rule #rlpDecodeList(STR, POS, _:LengthPrefixType(L, P)) => #rlpDecode(substrString(STR, POS, L +Int P)) , #rlpDecodeList(STR, L +Int P)

    syntax LengthPrefixType ::= "#str" | "#list"
    syntax LengthPrefix ::= LengthPrefixType "(" Int "," Int ")"
                          | #decodeLengthPrefix ( String , Int )                                [function]
                          | #decodeLengthPrefix ( String , Int , Int )                          [function, klabel(#decodeLengthPrefixAux)]
                          | #decodeLengthPrefixLength ( LengthPrefixType , String , Int , Int ) [function]
                          | #decodeLengthPrefixLength ( LengthPrefixType , Int    , Int , Int ) [function, klabel(#decodeLengthPrefixLengthAux)]
 // --------------------------------------------------------------------------------------------------------------------------------------------
    rule #decodeLengthPrefix(STR, START) => #decodeLengthPrefix(STR, START, ordChar(substrString(STR, START, START +Int 1)))

    rule #decodeLengthPrefix(  _, START, B0) => #str(1, START)                                   requires B0 <Int 128
    rule #decodeLengthPrefix(  _, START, B0) => #str(B0 -Int 128, START +Int 1)                  requires B0 >=Int 128 andBool B0 <Int (128 +Int 56)
    rule #decodeLengthPrefix(STR, START, B0) => #decodeLengthPrefixLength(#str, STR, START, B0)  requires B0 >=Int (128 +Int 56) andBool B0 <Int 192
    rule #decodeLengthPrefix(  _, START, B0) => #list(B0 -Int 192, START +Int 1)                 requires B0 >=Int 192 andBool B0 <Int 192 +Int 56
    rule #decodeLengthPrefix(STR, START, B0) => #decodeLengthPrefixLength(#list, STR, START, B0) [owise]

    rule #decodeLengthPrefixLength(#str,  STR, START, B0) => #decodeLengthPrefixLength(#str,  START, B0 -Int 128 -Int 56 +Int 1, #asWord(#parseByteStackRaw(substrString(STR, START +Int 1, START +Int 1 +Int (B0 -Int 128 -Int 56 +Int 1)))))
    rule #decodeLengthPrefixLength(#list, STR, START, B0) => #decodeLengthPrefixLength(#list, START, B0 -Int 192 -Int 56 +Int 1, #asWord(#parseByteStackRaw(substrString(STR, START +Int 1, START +Int 1 +Int (B0 -Int 192 -Int 56 +Int 1)))))
    rule #decodeLengthPrefixLength(TYPE, START, LL, L) => TYPE(L, START +Int 1 +Int LL)

    syntax JSONs ::= #rlpDecodeTransaction(ByteArray) [function]
 // ------------------------------------------------------------
    rule #rlpDecodeTransaction(T) => #unparseByteStack(T[0 .. 1]), #rlpDecode(#unparseByteStack(T[1 .. #sizeByteArray(T) -Int 1]))
```

Merkle Patricia Tree
====================

- Appendix C and D from the Ethereum Yellow Paper
- https://github.com/ethereum/wiki/wiki/Patricia-Tree

```k
    syntax KItem ::= Int | MerkleTree // For testing purposes

    syntax MerkleTree ::= ".MerkleTree"
                        | MerkleBranch    ( Map, String )
                        | MerkleExtension ( ByteArray, MerkleTree )
                        | MerkleLeaf      ( ByteArray, String )
 // -----------------------------------------------------------

    syntax MerkleTree ::= MerkleUpdate ( MerkleTree,     String, String ) [function]
                        | MerkleUpdate ( MerkleTree,  ByteArray, String ) [function,klabel(MerkleUpdateAux)]
                        | MerklePut    ( MerkleTree,  ByteArray, String ) [function]
                        | MerkleDelete ( MerkleTree,  ByteArray )         [function]
 // --------------------------------------------------------------------------------
    rule MerkleUpdate ( TREE, S:String, VALUE ) => MerkleUpdate ( TREE, #nibbleize ( #parseByteStackRaw( S ) ), VALUE )

    rule MerkleUpdate ( TREE, PATH:ByteArray, VALUE ) => MerklePut ( TREE, PATH, VALUE ) requires VALUE =/=String ""
    rule MerkleUpdate ( TREE, PATH:ByteArray, ""    ) => MerkleDelete ( TREE, PATH )

    rule MerklePut ( .MerkleTree, PATH:ByteArray, VALUE ) => MerkleLeaf ( PATH, VALUE )

    rule MerklePut ( MerkleLeaf ( LEAFPATH, _ ), PATH, VALUE )
      => MerkleLeaf( LEAFPATH, VALUE )
      requires LEAFPATH ==K PATH

    rule MerklePut ( MerkleLeaf ( LEAFPATH, LEAFVALUE ), PATH, VALUE )
      => MerklePut ( MerklePut ( MerkleBranch( .Map, "" ), LEAFPATH, LEAFVALUE ), PATH, VALUE )
      requires #sizeByteArray( LEAFPATH ) >Int 0
       andBool #sizeByteArray( PATH ) >Int 0
       andBool LEAFPATH[0] =/=Int PATH[0]

    rule MerklePut ( MerkleLeaf ( LEAFPATH, LEAFVALUE ), PATH, VALUE )
      => #merkleExtensionBuilder( .ByteArray, LEAFPATH, LEAFVALUE, PATH, VALUE )
      requires #unparseByteStack( LEAFPATH ) =/=String #unparseByteStack( PATH )
       andBool #sizeByteArray( LEAFPATH ) >Int 0
       andBool #sizeByteArray( PATH )     >Int 0
       andBool LEAFPATH[0] ==Int PATH[0]

    rule MerklePut ( MerkleExtension ( EXTPATH, EXTTREE ), PATH, VALUE )
      => MerkleExtension ( EXTPATH, MerklePut ( EXTTREE, .ByteArray, VALUE ) )
      requires EXTPATH ==K PATH

    rule MerklePut ( MerkleExtension ( EXTPATH, EXTTREE ), PATH, VALUE )
      => #merkleExtensionBrancher( MerklePut( MerkleBranch( .Map, "" ), PATH, VALUE ), EXTPATH, EXTTREE )
      requires #sizeByteArray( PATH ) >Int 0
       andBool EXTPATH[0] =/=Int PATH[0]

    rule MerklePut ( MerkleExtension ( EXTPATH, EXTTREE ), PATH, VALUE )
      => #merkleExtensionSplitter( .ByteArray, EXTPATH, EXTTREE, PATH, VALUE )
      requires #unparseByteStack( EXTPATH ) =/=String #unparseByteStack( PATH )
       andBool #sizeByteArray( PATH ) >Int 0
       andBool EXTPATH[0] ==Int PATH[0]

    rule MerklePut ( MerkleBranch( M, _ ), PATH, VALUE )
      => MerkleBranch( M, VALUE )
      requires #sizeByteArray( PATH ) ==Int 0

    rule MerklePut ( MerkleBranch( M, BRANCHVALUE ), PATH, VALUE )
      => #merkleUpdateBranch ( M, BRANCHVALUE, PATH[0], PATH[1 .. #sizeByteArray(PATH) -Int 1], VALUE )
      requires #sizeByteArray( PATH ) >Int 0

    rule MerkleDelete( .MerkleTree, _ ) => .MerkleTree

    rule MerkleDelete( MerkleLeaf( LPATH, _V ), PATH ) => .MerkleTree                           requires LPATH ==K  PATH
    rule MerkleDelete( MerkleLeaf( LPATH,  V ), PATH ) => MerkleCheck( MerkleLeaf( LPATH, V ) ) requires LPATH =/=K PATH

    rule MerkleDelete( MerkleExtension( EXTPATH, TREE ), PATH ) => MerkleExtension( EXTPATH, TREE ) requires notBool (#sizeByteArray(EXTPATH) <=Int #sizeByteArray(PATH) andBool PATH[0 .. #sizeByteArray(EXTPATH)] ==K EXTPATH)
    rule MerkleDelete( MerkleExtension( EXTPATH, TREE ), PATH )
      => MerkleCheck( MerkleExtension( EXTPATH, MerkleDelete( TREE, PATH[#sizeByteArray(EXTPATH) .. #sizeByteArray(PATH) -Int #sizeByteArray(EXTPATH)] ) ) )
      requires #sizeByteArray(EXTPATH) <=Int #sizeByteArray(PATH) andBool PATH[0 .. #sizeByteArray(EXTPATH)] ==K EXTPATH

    rule MerkleDelete( MerkleBranch( M, _V ), PATH ) => MerkleCheck( MerkleBranch( M, "" ) ) requires #sizeByteArray(PATH) ==Int 0
    rule MerkleDelete( MerkleBranch( M,  V ), PATH ) => MerkleBranch( M, V )                 requires #sizeByteArray(PATH) >Int 0 andBool notBool PATH[0] in_keys(M)
    rule MerkleDelete( MerkleBranch( M,  V ), PATH )
      => MerkleCheck( MerkleBranch( M[PATH[0] <- MerkleDelete( {M[PATH[0]]}:>MerkleTree, PATH[1 .. #sizeByteArray(PATH) -Int 1] )], V ) )
      requires #sizeByteArray(PATH) >Int 0 andBool PATH[0] in_keys(M)

    syntax MerkleTree ::= MerkleCheck( MerkleTree ) [function]
 // ----------------------------------------------------------
    rule MerkleCheck( TREE ) => TREE [owise]

    rule MerkleCheck( MerkleLeaf( _, "" ) => .MerkleTree )

    rule MerkleCheck( MerkleBranch( .Map                   , V  ) => MerkleLeaf( .ByteArray, V )                   )
    rule MerkleCheck( MerkleBranch( X |-> T                , "" ) => MerkleExtension( #asByteStack(X)[0 .. 1], T ) ) requires T =/=K .MerkleTree
    rule MerkleCheck( MerkleBranch( M => #cleanBranchMap(M), _  )                                                  ) requires .MerkleTree in values(M)

    rule MerkleCheck( MerkleExtension( _, .MerkleTree                                      ) => .MerkleTree               )
    rule MerkleCheck( MerkleExtension( P1, MerkleLeaf( P2, V )                             ) => MerkleLeaf( P1 ++ P2, V ) )
    rule MerkleCheck( MerkleExtension( P1 => P1 ++ P2, MerkleExtension( P2, TREE ) => TREE )                              )
```

- `MerkleUpdateMap` Takes a mapping of `ByteArray |-> String` and generates a trie

```k
    syntax MerkleTree ::= MerkleUpdateMap    ( MerkleTree , Map        ) [function]
                        | MerkleUpdateMapAux ( MerkleTree , Map , List ) [function]
 // -------------------------------------------------------------------------------
    rule MerkleUpdateMap(TREE, MMAP) => MerkleUpdateMapAux(TREE, MMAP, keys_list(MMAP))

    rule MerkleUpdateMapAux(TREE, _, .List ) => TREE
    rule MerkleUpdateMapAux(TREE                                                    , MMAP, ListItem(KEY) REST)
      => MerkleUpdateMapAux(MerkleUpdate(TREE, #nibbleize(KEY), {MMAP[KEY]}:>String), MMAP,               REST)
```

Merkle Tree Aux Functions
-------------------------

```k
    syntax ByteArray ::= #nibbleize ( ByteArray ) [function]
                       | #byteify   ( ByteArray ) [function]
 // --------------------------------------------------------
    rule #nibbleize ( B ) => (      #asByteStack ( B [ 0 ] /Int 16 )[0 .. 1]
                               ++ ( #asByteStack ( B [ 0 ] %Int 16 )[0 .. 1] )
                             ) ++ #nibbleize ( B[1 .. #sizeByteArray(B) -Int 1] )
      requires #sizeByteArray(B) >Int 0

    rule #nibbleize ( B ) => .ByteArray
      requires notBool #sizeByteArray(B) >Int 0

    rule #byteify ( B ) =>    #asByteStack ( B[0] *Int 16 +Int B[1] )[0 .. 1]
                           ++ #byteify ( B[2 .. #sizeByteArray(B) -Int 2] )
      requires #sizeByteArray(B) >Int 0

    rule #byteify ( B ) => .ByteArray
      requires notBool #sizeByteArray(B) >Int 0

    syntax ByteArray ::= #HPEncode ( ByteArray, Int ) [function]
 // ------------------------------------------------------------
    rule #HPEncode ( X, T ) => #asByteStack ( ( HPEncodeAux(T) +Int 1 ) *Int 16 +Int X[0] ) ++ #byteify( X[1 .. #sizeByteArray(X) -Int 1] )
      requires #sizeByteArray(X) %Int 2 =/=Int 0

    rule #HPEncode ( X, T ) => #asByteStack ( HPEncodeAux(T) *Int 16 )[0 .. 1] ++ #byteify( X )
      requires notBool #sizeByteArray(X) %Int 2 =/=Int 0

    syntax Int ::= HPEncodeAux ( Int ) [function]
 // ---------------------------------------------
    rule HPEncodeAux ( X ) => 0 requires         X ==Int 0
    rule HPEncodeAux ( X ) => 2 requires notBool X ==Int 0

    syntax Map ::= #cleanBranchMap    ( Map )            [function]
                 | #cleanBranchMapAux ( Map, List, Set ) [function]
 // ---------------------------------------------------------------
    rule #cleanBranchMap( M ) => #cleanBranchMapAux( M, keys_list(M), .Set )

    rule #cleanBranchMapAux(                   M,                        .List,                      S ) => removeAll( M, S )
    rule #cleanBranchMapAux( X |-> .MerkleTree _, (ListItem(X) => .List) _    , (.Set => SetItem(X)) _ )
    rule #cleanBranchMapAux(                   _, (ListItem(_) => .List) _    ,                      _ ) [owise]

    syntax MerkleTree ::= #merkleUpdateBranch ( Map, String, Int, ByteArray, String ) [function]
 // --------------------------------------------------------------------------------------------
    rule #merkleUpdateBranch ( X |-> TREE M, BRANCHVALUE, X, PATH, VALUE )
      => MerkleBranch( M[X <- MerklePut( TREE, PATH, VALUE )], BRANCHVALUE )

    rule #merkleUpdateBranch ( M, BRANCHVALUE, X, PATH, VALUE )
      => MerkleBranch( M[X <- MerkleLeaf( PATH, VALUE )], BRANCHVALUE ) [owise]

    syntax MerkleTree ::= #merkleExtensionBuilder(    ByteArray , ByteArray , String , ByteArray , String ) [function]
                        | #merkleExtensionBuilderAux( ByteArray , ByteArray , String , ByteArray , String ) [function]
 // ------------------------------------------------------------------------------------------------------------------------
    rule #merkleExtensionBuilder(PATH, P1, V1, P2, V2)
      => #merkleExtensionBuilderAux(PATH, P1, V1, P2, V2)
      requires #sizeByteArray(P1) >Int 0
       andBool #sizeByteArray(P2) >Int 0

    rule #merkleExtensionBuilder(PATH, P1, V1, P2, V2)
      => MerkleExtension( PATH, MerklePut( MerklePut( MerkleBranch( .Map, "" ), P1, V1 ), P2, V2 ) )
      [owise]

    rule #merkleExtensionBuilderAux( PATH, P1, V1, P2, V2 )
      => #merkleExtensionBuilder( PATH ++ (P1[0 .. 1])
                                , P1[1 .. #sizeByteArray(P1) -Int 1], V1
                                , P2[1 .. #sizeByteArray(P2) -Int 1], V2
                                )
      requires P1[0] ==Int P2[0]

    rule #merkleExtensionBuilderAux( PATH, P1, V1, P2, V2 )
      => MerkleExtension( PATH, MerklePut( MerklePut( MerkleBranch( .Map, "" ), P1, V1 ), P2, V2 ) )
      [owise]

    syntax MerkleTree ::= #merkleExtensionBrancher ( MerkleTree, ByteArray, MerkleTree ) [function]
 // -----------------------------------------------------------------------------------------------
    rule #merkleExtensionBrancher( MerkleBranch(M, VALUE), PATH, EXTTREE )
      => MerkleBranch( M[PATH[0] <- MerkleExtension( PATH[1 .. #sizeByteArray(PATH) -Int 1], EXTTREE )], VALUE )
      requires #sizeByteArray(PATH) >Int 1

    rule #merkleExtensionBrancher( MerkleBranch(M, VALUE), PATH, EXTTREE )
      => MerkleBranch( M[PATH[0] <- EXTTREE], VALUE )
      requires #sizeByteArray(PATH) ==Int 1

    syntax MerkleTree ::= #merkleExtensionSplitter ( ByteArray, ByteArray, MerkleTree, ByteArray, String ) [function]
 // -----------------------------------------------------------------------------------------------------------------
    rule #merkleExtensionSplitter( PATH => PATH ++ (P1[0 .. 1])
                                 , P1   => P1[1 .. #sizeByteArray(P1) -Int 1], _
                                 , P2   => P2[1 .. #sizeByteArray(P2) -Int 1], _
                                 )
      requires #sizeByteArray(P1) >Int 0
       andBool #sizeByteArray(P2) >Int 0
       andBool P1[0] ==Int P2[0]

    rule #merkleExtensionSplitter( PATH, P1, TREE, P2, VALUE )
      => MerkleExtension( PATH, #merkleExtensionBrancher( MerklePut( MerkleBranch( .Map, "" ), P2, VALUE ), P1, TREE ) )
      requires #sizeByteArray(P1) >Int 0
       andBool #sizeByteArray(P2) >Int 0
       andBool P1[0] =/=Int P2[0]

    rule #merkleExtensionSplitter( PATH, P1, TREE, P2, VALUE )
      => MerkleExtension( PATH, MerklePut( TREE, P2, VALUE ) )
      requires #sizeByteArray(P1) ==Int 0

    rule #merkleExtensionSplitter( PATH, P1, TREE, P2, VALUE )
      => MerkleExtension( PATH, #merkleExtensionBrancher( MerklePut( MerkleBranch( .Map, "" ), P2, VALUE ), P1, TREE ) )
      requires #sizeByteArray(P2) ==Int 0
```

Tree Root Helper Functions
--------------------------

### Storage Root

```k
    syntax Map ::= #intMap2StorageMap( Map )               [function]
                 | #intMap2StorageMapAux( Map, Map, List ) [function]
 // -----------------------------------------------------------------
    rule #intMap2StorageMap( M ) => #intMap2StorageMapAux( .Map, M, keys_list(M) )

    rule #intMap2StorageMapAux( SMAP, _, .List ) => SMAP
    rule #intMap2StorageMapAux( SMAP, IMAP, ListItem(K) REST )
      => #intMap2StorageMapAux( #padToWidth( 32, #asByteStack(K) ) |-> #rlpEncodeWord({IMAP[K]}:>Int) SMAP, IMAP, REST )
      requires {IMAP[K]}:>Int =/=Int 0

    rule #intMap2StorageMapAux( SMAP, IMAP, ListItem(K) REST )
      => #intMap2StorageMapAux( SMAP, IMAP, REST )
      requires {IMAP[K]}:>Int ==Int 0


    syntax MerkleTree ::= #storageRoot( Map ) [function]
 // ----------------------------------------------------
    rule #storageRoot( STORAGE ) => MerkleUpdateMap( .MerkleTree, #intMap2StorageMap( STORAGE ) )
```

### State Root

```k
    syntax Map ::= #precompiledAccountsMap   ( Set )       [function]
                 | #precompiledAccountsMapAux( List, Map ) [function]
 // -----------------------------------------------------------------
    rule #precompiledAccountsMap( ACCTS ) => #precompiledAccountsMapAux( Set2List( ACCTS ), .Map )

    rule #precompiledAccountsMapAux( .List, M ) => M
    rule #precompiledAccountsMapAux( (ListItem( ACCT ) => .List) _, M => M[#parseByteStackRaw( Hex2Raw( #unparseData( ACCT, 20 ) ) ) <- #emptyContractRLP] )

    syntax String ::= "#emptyContractRLP" [function]
 // ------------------------------------------------
    rule #emptyContractRLP => #rlpEncodeLength(         #rlpEncodeWord(0)
                                                +String #rlpEncodeWord(0)
                                                +String #rlpEncodeString( Hex2Raw( Keccak256("\x80") ) )
                                                +String #rlpEncodeString( Hex2Raw( Keccak256("") ) )
                                              , 192
                                              )

endmodule
```
