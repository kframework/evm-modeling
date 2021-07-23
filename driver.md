Ethereum Simulations
====================

Ethereum is using the EVM to drive updates over the world state.
Actual execution of the EVM is defined in [the EVM file](../evm).

```k
requires "evm.md"
requires "optimizations.md"
requires "asm.md"
requires "state-loader.md"

module ETHEREUM-SIMULATION
    imports EVM
    imports EVM-OPTIMIZATIONS
    imports EVM-ASSEMBLY
    imports STATE-LOADER
```

An Ethereum simulation is a list of Ethereum commands.
Some Ethereum commands take an Ethereum specification (eg. for an account or transaction).

```k
    syntax EthereumSimulation ::= ".EthereumSimulation"
                                | EthereumCommand EthereumSimulation
 // ----------------------------------------------------------------
    rule <k> .EthereumSimulation                        => .          ... </k>
    rule <k> ETC                 .EthereumSimulation    => ETC        ... </k>
    rule <k> ETC                 ETS:EthereumSimulation => ETC ~> ETS ... </k> requires ETS =/=K .EthereumSimulation

    rule <k> #halt ~> ETC ETS:EthereumSimulation => #halt ~> ETC ~> ETS ... </k>

    syntax EthereumSimulation ::= JSON
 // ----------------------------------
    rule <k> JSONINPUT:JSON => run JSONINPUT success .EthereumSimulation </k>
```

For verification purposes, it's much easier to specify a program in terms of its op-codes and not the hex-encoding that the tests use.
To do so, we'll extend sort `JSON` with some EVM specific syntax, and provide a "pretti-fication" to the nicer input form.

```k
    syntax JSON ::= ByteArray | OpCodes | Map | SubstateLogEntry | Account
 // ----------------------------------------------------------------------
```

### Driving Execution

-   `start` places `#next` on the `<k>` cell so that execution of the loaded state begin.
-   `flush` places `#finalize` on the `<k>` cell.

```k
    syntax EthereumCommand ::= "start"
 // ----------------------------------
    rule <mode> NORMAL  </mode> <k> start => #execute ... </k>
    rule <mode> VMTESTS </mode> <k> start => #execute ... </k>

    syntax EthereumCommand ::= "flush"
 // ----------------------------------
    rule <mode> EXECMODE </mode> <statusCode> EVMC_SUCCESS            </statusCode> <k> #halt ~> flush => #finalizeTx(EXECMODE ==K VMTESTS)          ... </k>
    rule <mode> EXECMODE </mode> <statusCode> _:ExceptionalStatusCode </statusCode> <k> #halt ~> flush => #finalizeTx(EXECMODE ==K VMTESTS) ~> #halt ... </k>
```

-   `startTx` computes the sender of the transaction, and places loadTx on the `k` cell.
-   `loadTx(_)` loads the next transaction to be executed into the current state.
-   `finishTx` is a place-holder for performing necessary cleanup after a transaction.

**TODO**: `loadTx(_) => loadTx_`

```k
    syntax EthereumCommand ::= "startTx"
 // ------------------------------------
    rule <k> startTx => #finalizeBlock ... </k>
         <txPending> .List </txPending>

    rule <k> startTx => loadTx(#sender(TN, TP, TG, TT, TV, #unparseByteStack(DATA), TW, TR, TS, CID)) ... </k>
         <chainID> CID </chainID>
         <txPending> ListItem(TXID:Int) ... </txPending>
         <message>
           <msgID>      TXID </msgID>
           <txNonce>    TN   </txNonce>
           <txGasPrice> TP   </txGasPrice>
           <txGasLimit> TG   </txGasLimit>
           <to>         TT   </to>
           <value>      TV   </value>
           <sigV>       TW   </sigV>
           <sigR>       TR   </sigR>
           <sigS>       TS   </sigS>
           <data>       DATA </data>
           <txType>     0    </txType>
           ...
         </message>

    rule <k> startTx => loadTx(#sender(1 , CID, TN, TP, TG, TT, TV, #unparseByteStack(DATA), TA, TW, TR, TS)) ... </k>
         <chainID> CID </chainID>
         <txPending> ListItem(TXID:Int) ... </txPending>
         <message>
           <msgID>      TXID </msgID>
           <txNonce>    TN   </txNonce>
           <txGasPrice> TP   </txGasPrice>
           <txGasLimit> TG   </txGasLimit>
           <to>         TT   </to>
           <value>      TV   </value>
           <sigV>       TW   </sigV>
           <sigR>       TR   </sigR>
           <sigS>       TS   </sigS>
           <data>       DATA </data>
           <txType>     1    </txType>
           <txChainID>  CID  </txChainID>
           <txAccess>   TA   </txAccess>
           ...
         </message>

    syntax EthereumCommand ::= loadTx ( Account )
 // ---------------------------------------------
    rule <k> loadTx(ACCTFROM)
          => #accessAccounts ACCTFROM #newAddr(ACCTFROM, NONCE) #precompiledAccounts(SCHED)
          ~> #loadAccessList(TA)
          ~> #create ACCTFROM #newAddr(ACCTFROM, NONCE) VALUE CODE
          ~> #finishTx ~> #finalizeTx(false) ~> startTx
         ...
         </k>
         <schedule> SCHED </schedule>
         <gasPrice> _ => GPRICE </gasPrice>
         <callGas> _ => GLIMIT -Int G0(SCHED, CODE, true) </callGas>
         <origin> _ => ACCTFROM </origin>
         <callDepth> _ => -1 </callDepth>
         <txPending> ListItem(TXID:Int) ... </txPending>
         <coinbase> MINER </coinbase>
         <message>
           <msgID>      TXID     </msgID>
           <txGasPrice> GPRICE   </txGasPrice>
           <txGasLimit> GLIMIT   </txGasLimit>
           <to>         .Account </to>
           <value>      VALUE    </value>
           <data>       CODE     </data>
           <txAccess>   TA       </txAccess>
           ...
         </message>
         <account>
           <acctID> ACCTFROM </acctID>
           <balance> BAL => BAL -Int (GLIMIT *Int GPRICE) </balance>
           <nonce> NONCE </nonce>
           ...
         </account>
         <accessedAccounts> _ => .Set </accessedAccounts>
         <touchedAccounts> _ => SetItem(MINER) </touchedAccounts>

    rule <k> loadTx(ACCTFROM)
          => #accessAccounts ACCTFROM ACCTTO #precompiledAccounts(SCHED)
          ~> #loadAccessList(TA)
          ~> #call ACCTFROM ACCTTO ACCTTO VALUE VALUE DATA false
          ~> #finishTx ~> #finalizeTx(false) ~> startTx
         ...
         </k>
         <schedule> SCHED </schedule>
         <gasPrice> _ => GPRICE </gasPrice>
         <callGas> _ => GLIMIT -Int G0(SCHED, DATA, false) </callGas>
         <origin> _ => ACCTFROM </origin>
         <callDepth> _ => -1 </callDepth>
         <txPending> ListItem(TXID:Int) ... </txPending>
         <coinbase> MINER </coinbase>
         <message>
           <msgID>      TXID   </msgID>
           <txGasPrice> GPRICE </txGasPrice>
           <txGasLimit> GLIMIT </txGasLimit>
           <to>         ACCTTO </to>
           <value>      VALUE  </value>
           <data>       DATA   </data>
           <txAccess>   TA     </txAccess>
           ...
         </message>
         <account>
           <acctID> ACCTFROM </acctID>
           <balance> BAL => BAL -Int (GLIMIT *Int GPRICE) </balance>
           <nonce> NONCE => NONCE +Int 1 </nonce>
           ...
         </account>
         <accessedAccounts> _ => .Set </accessedAccounts>
         <touchedAccounts> _ => SetItem(MINER) </touchedAccounts>
      requires ACCTTO =/=K .Account

    syntax EthereumCommand ::= "#finishTx"
 // --------------------------------------
    rule <statusCode> _:ExceptionalStatusCode </statusCode> <k> #halt ~> #finishTx => #popCallStack ~> #popWorldState                   ... </k>
    rule <statusCode> EVMC_REVERT             </statusCode> <k> #halt ~> #finishTx => #popCallStack ~> #popWorldState ~> #refund GAVAIL ... </k> <gas> GAVAIL </gas>

    rule <statusCode> EVMC_SUCCESS </statusCode>
         <k> #halt ~> #finishTx => #mkCodeDeposit ACCT ... </k>
         <id> ACCT </id>
         <txPending> ListItem(TXID:Int) ... </txPending>
         <message>
           <msgID> TXID     </msgID>
           <to>    .Account </to>
           ...
         </message>

    rule <statusCode> EVMC_SUCCESS </statusCode>
         <k> #halt ~> #finishTx => #popCallStack ~> #dropWorldState ~> #refund GAVAIL ... </k>
         <gas> GAVAIL </gas>
         <txPending> ListItem(TXID:Int) ... </txPending>
         <message>
           <msgID> TXID </msgID>
           <to>    TT   </to>
           ...
         </message>
      requires TT =/=K .Account

    syntax EthereumCommand ::= #loadAccessList ( JSON )
                             | #loadAccessListAux ( Account , List )
 // ----------------------------------------------------------------
    rule <k> #loadAccessList ([ .JSONs ]) => . ... </k>
         <schedule> SCHED </schedule>
      requires Ghasaccesslist << SCHED >>

    rule <k> #loadAccessList ([ _ ]) => . ... </k>
         <schedule> SCHED </schedule>
      requires notBool Ghasaccesslist << SCHED >>

    rule <k> #loadAccessList ([[ACCT, [STRG:JSONs]], REST])
          => #loadAccessListAux (#asAccount(#parseByteStackRaw(ACCT)), #parseAccessListStorageKeys([STRG]))
          ~> #loadAccessList ([REST])
         ...
         </k>
         <schedule> SCHED </schedule>
      requires Ghasaccesslist << SCHED >>

    rule <k> #loadAccessListAux (ACCT, (ListItem(STRGK) STRGKS))
          => #accessStorage ACCT STRGK:Int
          ~> #loadAccessListAux (ACCT, STRGKS)
         ...
         </k>
         <schedule> SCHED </schedule>
         <callGas> GLIMIT => GLIMIT -Int Gaccessliststoragekey < SCHED > </callGas>

    rule <k> #loadAccessListAux (ACCT, .List) => #accessAccounts ACCT ... </k>
         <schedule> SCHED </schedule>
         <callGas> GLIMIT => GLIMIT -Int Gaccesslistaddress < SCHED > </callGas>
```

-   `exception` only clears from the `<k>` cell if there is an exception preceding it.
-   `failure_` holds the name of a test that failed if a test does fail.
-   `success` sets the `<exit-code>` to `0` and the `<mode>` to `SUCCESS`.

```k
    syntax Mode ::= "SUCCESS"
 // -------------------------

    syntax EthereumCommand ::= "exception" | "status" StatusCode
 // ------------------------------------------------------------
    rule <statusCode> _:ExceptionalStatusCode </statusCode>
         <k> #halt ~> exception => . ... </k>

    rule <k> status SC => . ... </k> <statusCode> SC </statusCode>

    syntax EthereumCommand ::= "failure" String | "success"
 // -------------------------------------------------------
    rule <k> success => . ... </k>
         <exit-code> _ => 0 </exit-code>
         <mode> _ => SUCCESS </mode>
         <endPC> _ => 0 </endPC>

    rule <k>          failure _ => . ... </k>
    rule <k> #halt ~> failure _ => . ... </k>
```

### Running Tests

-   `run` runs a given set of Ethereum tests (from the test-set).

Note that `TEST` is sorted here so that key `"network"` comes before key `"pre"`.

```k
    syntax EthereumCommand ::= "run" JSON
 // -------------------------------------
    rule <k> run { .JSONs } => . ... </k>
    rule <k> run { TESTID : { TEST:JSONs } , TESTS }
          => run ( TESTID : { qsortJSONs(TEST) } )
          ~> #if #hasPost?( { TEST } ) #then .K #else exception #fi
          ~> clear
          ~> run { TESTS }
         ...
         </k>

    syntax Bool ::= "#hasPost?" "(" JSON ")" [function]
 // ---------------------------------------------------
    rule #hasPost? ({ .JSONs }) => false
    rule #hasPost? ({ (KEY:String) : _ , REST }) => (KEY in #postKeys) orBool #hasPost? ({ REST })
```

-   `#loadKeys` are all the JSON nodes which should be considered as loads before execution.

```k
    syntax Set ::= "#loadKeys" [function]
 // -------------------------------------
    rule #loadKeys => ( SetItem("env") SetItem("pre") SetItem("rlp") SetItem("network") SetItem("genesisRLP") )

    rule <k> run  TESTID : { KEY : (VAL:JSON) , REST } => load KEY : VAL ~> run TESTID : { REST } ... </k>
      requires KEY in #loadKeys

    rule <k> run _TESTID : { "blocks" : [ { KEY : VAL , REST1 => REST1 }, .JSONs ] , ( REST2 => KEY : VAL , REST2 ) } ... </k>
    rule <k> run  TESTID : { "blocks" : [ { .JSONs }, .JSONs ] , REST } => run TESTID : { REST }                      ... </k>
```

-   `#execKeys` are all the JSON nodes which should be considered for execution (between loading and checking).

```k
    syntax Set ::= "#execKeys" [function]
 // -------------------------------------
    rule #execKeys => ( SetItem("exec") SetItem("lastblockhash") )

    rule <k> run  TESTID : { KEY : (VAL:JSON) , NEXT , REST } => run TESTID : { NEXT , KEY : VAL , REST } ... </k>
      requires KEY in #execKeys

    rule <k> run _TESTID : { "exec" : (EXEC:JSON) } => loadCallState EXEC ~> start ~> flush ... </k>
    rule <k> run _TESTID : { "lastblockhash" : (_:String) } => #startBlock ~> startTx    ... </k>

    rule <k> load "exec" : J => loadCallState J ... </k>

    rule <k> loadCallState { "caller" : (ACCTFROM:Int), REST => REST } ... </k> <caller> _ => ACCTFROM </caller>
    rule <k> loadCallState { "origin" : (ORIG:Int), REST => REST }     ... </k> <origin> _ => ORIG     </origin>
    rule <k> loadCallState { "address" : (ACCTTO:Int), REST => REST }  ... </k> <id>     _ => ACCTTO   </id>

    rule <k> loadCallState { "code" : (CODE:OpCodes), REST } => #loadProgram #asmOpCodes(CODE) ~> loadCallState { REST } ... </k>

    rule <k> loadCallState { KEY : ((VAL:String) => #parseWord(VAL)), _ } ... </k>
      requires KEY in (SetItem("gas") SetItem("gasPrice") SetItem("value"))

    rule <k> loadCallState { KEY : ((VAL:String) => #parseHexWord(VAL)), _ } ... </k>
      requires KEY in (SetItem("address") SetItem("caller") SetItem("origin"))

    rule <k> loadCallState { "code" : ((CODE:String) => #parseByteStack(CODE)), _ } ... </k>
```

-   `#postKeys` are a subset of `#checkKeys` which correspond to post-state account checks.
-   `#checkKeys` are all the JSON nodes which should be considered as checks after execution.

```k
    syntax Set ::= "#postKeys" [function] | "#allPostKeys" [function] | "#checkKeys" [function]
 // -------------------------------------------------------------------------------------------
    rule #postKeys    => ( SetItem("post") SetItem("postState") SetItem("postStateHash") )
    rule #allPostKeys => ( #postKeys SetItem("expect") SetItem("export") SetItem("expet") )
    rule #checkKeys   => ( #allPostKeys SetItem("logs") SetItem("out") SetItem("gas")
                           SetItem("blockHeader") SetItem("transactions") SetItem("uncleHeaders") SetItem("genesisBlockHeader")
                         )

    rule <k> run TESTID : { KEY : (VAL:JSON) , REST } => run TESTID : { REST } ~> check TESTID : { "post" : VAL } ... </k> requires KEY in #allPostKeys
    rule <k> run TESTID : { KEY : (VAL:JSON) , REST } => run TESTID : { REST } ~> check TESTID : { KEY    : VAL } ... </k> requires KEY in #checkKeys andBool notBool KEY in #allPostKeys
```

-   `#discardKeys` are all the JSON nodes in the tests which should just be ignored.

```k
    syntax Set ::= "#discardKeys" [function]
 // ----------------------------------------
    rule #discardKeys => ( SetItem("//") SetItem("_info") SetItem("callcreates") SetItem("sealEngine") )

    rule <k> run TESTID : { KEY : _ , REST } => run TESTID : { REST } ... </k> requires KEY in #discardKeys
```

-   `driver.md` specific handling of state-loader commands

```k
    rule <k> load "account" : { ACCTID : ACCT } => loadAccount ACCTID ACCT ... </k>

    rule <k> loadAccount _ { "balance" : ((VAL:String)      => #parseWord(VAL)),        _ } ... </k>
    rule <k> loadAccount _ { "nonce"   : ((VAL:String)      => #parseWord(VAL)),        _ } ... </k>
    rule <k> loadAccount _ { "code"    : ((CODE:String)     => #parseByteStack(CODE)),  _ } ... </k>
    rule <k> loadAccount _ { "storage" : ({ STORAGE:JSONs } => #parseMap({ STORAGE })), _ } ... </k>

    rule <k> loadTransaction _ { "type"       : (TT:String => #asWord(#parseByteStackRaw(TT))), _         } ... </k>
    rule <k> loadTransaction _ { "chainID"    : (TC:String => #asWord(#parseByteStackRaw(TC))), _         } ... </k>
    rule <k> loadTransaction _ { "gasLimit"   : (TG:String => #asWord(#parseByteStackRaw(TG))), _         } ... </k>
    rule <k> loadTransaction _ { "gasPrice"   : (TP:String => #asWord(#parseByteStackRaw(TP))), _         } ... </k>
    rule <k> loadTransaction _ { "nonce"      : (TN:String => #asWord(#parseByteStackRaw(TN))), _         } ... </k>
    rule <k> loadTransaction _ { "v"          : (TW:String => #asWord(#parseByteStackRaw(TW))), _         } ... </k>
    rule <k> loadTransaction _ { "value"      : (TV:String => #asWord(#parseByteStackRaw(TV))), _         } ... </k>
    rule <k> loadTransaction _ { "to"         : (TT:String => #asAccount(#parseByteStackRaw(TT))), _      } ... </k>
    rule <k> loadTransaction _ { "data"       : (TI:String => #parseByteStackRaw(TI)), _                  } ... </k>
    rule <k> loadTransaction _ { "r"          : (TR:String => #padToWidth(32, #parseByteStackRaw(TR))), _ } ... </k>
    rule <k> loadTransaction _ { "s"          : (TS:String => #padToWidth(32, #parseByteStackRaw(TS))), _ } ... </k>
```

### Checking State

-   `check_` checks if an account/transaction appears in the world-state as stated.

```k
    syntax EthereumCommand ::= "check" JSON
 // ---------------------------------------
    rule <k> #halt ~> check J:JSON => check J ~> #halt ... </k>

    rule <k> check DATA : { .JSONs } => . ... </k> requires DATA =/=String "transactions"
    rule <k> check DATA : [ .JSONs ] => . ... </k> requires DATA =/=String "ommerHeaders"

    rule <k> check DATA : { (KEY:String) : VALUE , REST } => check DATA : { KEY : VALUE } ~> check DATA : { REST } ... </k>
      requires REST =/=K .JSONs andBool notBool DATA in (SetItem("callcreates") SetItem("transactions"))

    rule <k> check DATA : [ { TEST } , REST ] => check DATA : { TEST } ~> check DATA : [ REST ] ... </k>
      requires DATA =/=String "transactions"

    rule <k> check (KEY:String) : { JS:JSONs => qsortJSONs(JS) } ... </k>
      requires KEY in (SetItem("callcreates")) andBool notBool sortedJSONs(JS)

    rule <k> check TESTID : { "post" : (POST:String) } => check "blockHeader" : {  "stateRoot" : #parseWord(POST) } ~> failure TESTID ... </k>
    rule <k> check TESTID : { "post" : { POST } } => check "account" : { POST } ~> failure TESTID ... </k>

    rule <k> check "account" : { ACCTID:Int : { KEY : VALUE , REST } } => check "account" : { ACCTID : { KEY : VALUE } } ~> check "account" : { ACCTID : { REST } } ... </k>
      requires REST =/=K .JSONs

    rule <k> check "account" : { ((ACCTID:String) => #parseAddr(ACCTID)) : _ACCT }                             ... </k>
    rule <k> check "account" : { (_ACCT:Int) : { "balance" : ((VAL:String)      => #parseWord(VAL)) } }        ... </k>
    rule <k> check "account" : { (_ACCT:Int) : { "nonce"   : ((VAL:String)      => #parseWord(VAL)) } }        ... </k>
    rule <k> check "account" : { (_ACCT:Int) : { "code"    : ((CODE:String)     => #parseByteStack(CODE)) } }  ... </k>
    rule <k> check "account" : { (_ACCT:Int) : { "storage" : ({ STORAGE:JSONs } => #parseMap({ STORAGE })) } } ... </k>

    rule <mode> EXECMODE </mode>
         <k> check "account" : { ACCT : { "balance" : (BAL:Int) } } => . ... </k>
         <account>
           <acctID> ACCT </acctID>
           <balance> BAL </balance>
           ...
         </account>
      requires EXECMODE =/=K VMTESTS

    rule <mode> VMTESTS </mode>
         <k> check "account" : { _ACCT : { "balance" : (_:Int) } } => . ... </k>

    rule <k> check "account" : {  ACCT : { "nonce" : (NONCE:Int) } } => . ... </k>
         <account>
           <acctID> ACCT </acctID>
           <nonce> NONCE </nonce>
           ...
         </account>

    rule <k> check "account" : { ACCT : { "storage" : (STORAGE:Map) } } => . ... </k>
         <account>
           <acctID> ACCT </acctID>
           <storage> ACCTSTORAGE </storage>
           ...
         </account>
      requires #removeZeros(ACCTSTORAGE) ==K STORAGE

    rule <k> check "account" : { ACCT : { "code" : (CODE:ByteArray) } } => . ... </k>
         <account>
           <acctID> ACCT </acctID>
           <code> CODE </code>
           ...
         </account>
```

-   `#removeZeros` removes any entries in a map with zero values.

```k
    syntax Map ::= #removeZeros ( Map ) [function]
                 | #removeZeros ( List , Map ) [function, klabel(#removeZerosAux)]
 // ------------------------------------------------------------------------------
    rule #removeZeros( M )                                   => #removeZeros(Set2List(keys(M)), M)
    rule #removeZeros( .List, .Map )                         => .Map
    rule #removeZeros( ListItem(KEY) L, KEY |-> 0 REST )     => #removeZeros(L, REST)
    rule #removeZeros( ListItem(KEY) L, KEY |-> VALUE REST ) => KEY |-> VALUE #removeZeros(L, REST) requires VALUE =/=K 0
```

Here we check the other post-conditions associated with an EVM test.

```k
    rule <k> check TESTID : { "out" : OUT } => check "out" : OUT ~> failure TESTID ... </k>
 // ---------------------------------------------------------------------------------------
    rule <k> check "out" : ((OUT:String) => #parseByteStack(OUT)) ... </k>
    rule <k> check "out" : OUT => . ... </k> <output> OUT </output>

    rule <k> check TESTID : { "logs" : LOGS } => check "logs" : LOGS ~> failure TESTID ... </k>
 // -------------------------------------------------------------------------------------------
    rule <k> check "logs" : HASH:String => . ... </k> <log> SL </log> requires #parseHexBytes(Keccak256(#rlpEncodeLogs(SL))) ==K #parseByteStack(HASH)

    rule <k> check TESTID : { "gas" : GLEFT } => check "gas" : GLEFT ~> failure TESTID ... </k>
 // -------------------------------------------------------------------------------------------
    rule <k> check "gas" : ((GLEFT:String) => #parseWord(GLEFT)) ... </k>
    rule <k> check "gas" : GLEFT => . ... </k> <gas> GLEFT </gas>

    rule check TESTID : { "blockHeader" : BLOCKHEADER } => check "blockHeader" : BLOCKHEADER ~> failure TESTID
 // ----------------------------------------------------------------------------------------------------------
    rule <k> check "blockHeader" : { KEY : VALUE , REST } => check "blockHeader" : { KEY : VALUE } ~> check "blockHeader" : { REST } ... </k>
      requires REST =/=K .JSONs

    rule <k> check "blockHeader" : { _KEY : (VALUE:String => #parseByteStack(VALUE)) } ... </k>

    rule <k> check "blockHeader" : {  KEY : (VALUE:ByteArray => #asWord(VALUE)) } ... </k>
      requires KEY in ( SetItem("coinbase") SetItem("difficulty") SetItem("gasLimit") SetItem("gasUsed")
                        SetItem("mixHash") SetItem("nonce") SetItem("number") SetItem("parentHash")
                        SetItem("receiptTrie") SetItem("stateRoot") SetItem("timestamp")
                        SetItem("transactionsTrie") SetItem("uncleHash")
                      )

    rule <k> check "blockHeader" : { "bloom"            : VALUE } => . ... </k> <logsBloom>        VALUE </logsBloom>
    rule <k> check "blockHeader" : { "coinbase"         : VALUE } => . ... </k> <coinbase>         VALUE </coinbase>
    rule <k> check "blockHeader" : { "difficulty"       : VALUE } => . ... </k> <difficulty>       VALUE </difficulty>
    rule <k> check "blockHeader" : { "extraData"        : VALUE } => . ... </k> <extraData>        VALUE </extraData>
    rule <k> check "blockHeader" : { "gasLimit"         : VALUE } => . ... </k> <gasLimit>         VALUE </gasLimit>
    rule <k> check "blockHeader" : { "gasUsed"          : VALUE } => . ... </k> <gasUsed>          VALUE </gasUsed>
    rule <k> check "blockHeader" : { "mixHash"          : VALUE } => . ... </k> <mixHash>          VALUE </mixHash>
    rule <k> check "blockHeader" : { "nonce"            : VALUE } => . ... </k> <blockNonce>       VALUE </blockNonce>
    rule <k> check "blockHeader" : { "number"           : VALUE } => . ... </k> <number>           VALUE </number>
    rule <k> check "blockHeader" : { "parentHash"       : VALUE } => . ... </k> <previousHash>     VALUE </previousHash>
    rule <k> check "blockHeader" : { "receiptTrie"      : VALUE } => . ... </k> <receiptsRoot>     VALUE </receiptsRoot>
    rule <k> check "blockHeader" : { "stateRoot"        : VALUE } => . ... </k> <stateRoot>        VALUE </stateRoot>
    rule <k> check "blockHeader" : { "timestamp"        : VALUE } => . ... </k> <timestamp>        VALUE </timestamp>
    rule <k> check "blockHeader" : { "transactionsTrie" : VALUE } => . ... </k> <transactionsRoot> VALUE </transactionsRoot>
    rule <k> check "blockHeader" : { "uncleHash"        : VALUE } => . ... </k> <ommersHash>       VALUE </ommersHash>

    rule <k> check "blockHeader" : { "hash": HASH:ByteArray } => . ...</k>
         <previousHash>     HP </previousHash>
         <ommersHash>       HO </ommersHash>
         <coinbase>         HC </coinbase>
         <stateRoot>        HR </stateRoot>
         <transactionsRoot> HT </transactionsRoot>
         <receiptsRoot>     HE </receiptsRoot>
         <logsBloom>        HB </logsBloom>
         <difficulty>       HD </difficulty>
         <number>           HI </number>
         <gasLimit>         HL </gasLimit>
         <gasUsed>          HG </gasUsed>
         <timestamp>        HS </timestamp>
         <extraData>        HX </extraData>
         <mixHash>          HM </mixHash>
         <blockNonce>       HN </blockNonce>
      requires #blockHeaderHash(HP, HO, HC, HR, HT, HE, HB, HD, HI, HL, HG, HS, HX, HM, HN) ==Int #asWord(HASH)

    rule check TESTID : { "genesisBlockHeader" : BLOCKHEADER } => check "genesisBlockHeader" : BLOCKHEADER ~> failure TESTID
 // ------------------------------------------------------------------------------------------------------------------------
    rule <k> check "genesisBlockHeader" : { KEY : VALUE , REST } => check "genesisBlockHeader" : { KEY : VALUE } ~> check "genesisBlockHeader" : { REST } ... </k>
      requires REST =/=K .JSONs

    rule <k> check "genesisBlockHeader" : { KEY : _ } => .K ... </k> requires KEY =/=String "hash"

    rule <k> check "genesisBlockHeader" : { "hash": (HASH:String => #asWord(#parseByteStack(HASH))) } ... </k>
    rule <k> check "genesisBlockHeader" : { "hash": HASH } => . ... </k>
         <blockhashes> ... ListItem(HASH) ListItem(_) </blockhashes>

    rule <k> check TESTID : { "transactions" : TRANSACTIONS } => check "transactions" : TRANSACTIONS ~> failure TESTID ... </k>
 // ---------------------------------------------------------------------------------------------------------------------------
    rule <k> check "transactions" : [ .JSONs ] => . ... </k> <txOrder> .List                    </txOrder>
    rule <k> check "transactions" : { .JSONs } => . ... </k> <txOrder> ListItem(_) => .List ... </txOrder>

    rule <k> check "transactions" : [ TRANSACTION , REST ] => check "transactions" : TRANSACTION   ~> check "transactions" : [ REST ] ... </k>
    rule <k> check "transactions" : { KEY : VALUE , REST } => check "transactions" : (KEY : VALUE) ~> check "transactions" : { REST } ... </k>

    rule <k> check "transactions" : (_KEY : (VALUE:String    => #parseByteStack(VALUE))) ... </k>
    rule <k> check "transactions" : ("to" : (VALUE:ByteArray => #asAccount(VALUE)))      ... </k>
    rule <k> check "transactions" : ( KEY : (VALUE:ByteArray => #padToWidth(32, VALUE))) ... </k> requires KEY in (SetItem("r") SetItem("s")) andBool #sizeByteArray(VALUE) <Int 32
    rule <k> check "transactions" : ( KEY : (VALUE:ByteArray => #asWord(VALUE)))         ... </k> requires KEY in (SetItem("gasLimit") SetItem("gasPrice") SetItem("nonce") SetItem("v") SetItem("value") SetItem("chainId") SetItem("type"))

    rule <k> check "transactions" : "accessList" : [ ACCESSLIST , REST ] => check "transactions" : "accessList" : ACCESSLIST  ~> check "transactions" : "accessList" : [ REST ] ... </k>
    rule <k> check "transactions" : "accessList" : { "address" : V1 , "storageKeys": V2 , .JSONs } => check "transactions" : "accessList" : "address" : #parseHexWord(V1) : "storageKeys" : V2  ... </k>
    rule <k> check "transactions" : "accessList" : "address" : ADDR : "storageKeys" : [ KEY , REST ] => check "transactions" : "accessList" : "address" : ADDR : "storageKeys" : #parseHexWord(KEY) ~> check "transactions" : "accessList" : "address" : ADDR : "storageKeys" : [ REST ] ... </k>

    rule <k> check "transactions" : "accessList" : "address" : _    : "storageKeys" : [ .JSONs ] => . ... </k>
    rule <k> check "transactions" : "accessList" : [ .JSONs ] => . ... </k>

    rule <k> check "transactions" : "accessList" : "address" : ADDR : "storageKeys" : KEY        => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <txAccess> TA </txAccess> ... </message> requires isInAccessList(ADDR, KEY, TA)
    rule <k> check "transactions" : ("data"     : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <data>       VALUE </data>       ... </message>
    rule <k> check "transactions" : ("gasLimit" : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <txGasLimit> VALUE </txGasLimit> ... </message>
    rule <k> check "transactions" : ("gasPrice" : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <txGasPrice> VALUE </txGasPrice> ... </message>
    rule <k> check "transactions" : ("nonce"    : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <txNonce>    VALUE </txNonce>    ... </message>
    rule <k> check "transactions" : ("r"        : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <sigR>       VALUE </sigR>       ... </message>
    rule <k> check "transactions" : ("s"        : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <sigS>       VALUE </sigS>       ... </message>
    rule <k> check "transactions" : ("to"       : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <to>         VALUE </to>         ... </message>
    rule <k> check "transactions" : ("v"        : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <sigV>       VALUE </sigV>       ... </message>
    rule <k> check "transactions" : ("value"    : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <value>      VALUE </value>      ... </message>
    rule <k> check "transactions" : ("chainId"  : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <txChainID>  VALUE </txChainID>  ... </message>
    rule <k> check "transactions" : ("type"     : VALUE) => . ... </k> <txOrder> ListItem(TXID) ... </txOrder> <message> <msgID> TXID </msgID> <txType>     VALUE </txType>     ... </message>

    syntax Bool ::= isInAccessListStorage ( Int , JSON )    [function]
                  | isInAccessList ( Account , Int , JSON ) [function]
 // ------------------------------------------------------------------
    rule isInAccessList(_, _, [.JSONs]) => false
    rule isInAccessList(ADDR, KEY, [[ACCT, [STRG:JSONs]],  REST]) => isInAccessListStorage (KEY, [STRG]) orBool isInAccessList(ADDR, KEY, [REST]) requires ADDR ==K #asAccount(#parseByteStackRaw(ACCT))
    rule isInAccessList(ADDR, KEY, [[ACCT, [_STRG:JSONs]], REST]) => isInAccessList(ADDR, KEY, [REST])   requires notBool ADDR ==K #asAccount(#parseByteStackRaw(ACCT))

    rule isInAccessListStorage(_, [.JSONs]) => false
    rule isInAccessListStorage(KEY, [SKEY, _REST]) => true requires KEY ==Int #asWord(#parseByteStackRaw(SKEY))
    rule isInAccessListStorage(KEY, [SKEY, REST])  => isInAccessListStorage(KEY, [REST]) requires  notBool KEY ==Int #asWord(#parseByteStackRaw(SKEY))
```

TODO: case with nonzero ommers.

```k
    rule <k> check TESTID : { "uncleHeaders" : OMMERS } => check "ommerHeaders" : OMMERS ~> failure TESTID ... </k>
 // ---------------------------------------------------------------------------------------------------------------
    rule <k> check "ommerHeaders" : [ .JSONs ] => . ... </k> <ommerBlockHeaders> [ .JSONs ] </ommerBlockHeaders>
```

```k
endmodule
```
