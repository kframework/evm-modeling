Web3 RPC JSON Handler
=====================

```k
requires "evm.k"
requires "state-loader.k"
requires "json.k"
```

```k
module WEB3
    imports STATE-LOADER
    imports JSON-RPC

    configuration
      <kevm-client>
        <kevm/>
        <json-rpc/>
        <execPhase> .Phase </execPhase>
        <opcodeCoverage> .Map </opcodeCoverage>
        <opcodeLists> .Map </opcodeLists>
        <errorPC> 0 </errorPC>
        <blockchain>
          <chainID> $CHAINID:Int </chainID>
          <blockList> .List </blockList>
        </blockchain>
        <accountKeys> .Map </accountKeys>
        <nextFilterSlot> 0 </nextFilterSlot>
        <txReceipts>
          <txReceipt multiplicity ="*" type="Map">
            <txHash>          "":String  </txHash>
            <txCumulativeGas> 0          </txCumulativeGas>
            <logSet>          .List      </logSet>
            <bloomFilter>     .ByteArray </bloomFilter>
            <txStatus>        0          </txStatus>
            <txID>            0          </txID>
            <sender>          .Account   </sender>
            <txBlockNumber>   0          </txBlockNumber>
          </txReceipt>
        </txReceipts>
        <filters>
          <filter multiplicity="*" type="Map">
            <filterID>  0   </filterID>
            <fromBlock> 0   </fromBlock>
            <toBlock>   0   </toBlock>
            <address>   0   </address>
            <topics>  .List </topics>
          </filter>
        </filters>
        <snapshots> .List </snapshots>
        <web3shutdownable> $SHUTDOWNABLE:Bool </web3shutdownable>
      </kevm-client>
```

The Blockchain State
--------------------

A `BlockchainItem` contains the information of a block and its network state.
The `blockList` cell stores a list of previous blocks and network states.
-   `#pushBlockchainState` saves a copy of the block state and network state as a `BlockchainItem` in the `blockList` cell.
-   `#getBlockchainState(Int)` restores a blockchain state for a given block number.
-   `#setBlockchainState(BlockchainItem)` helper rule for `#getBlockchainState(Int)`.
-   `#getBlockByNumber(Int)` retrieves a specific `BlockchainItem` from the `blockList` cell.

```k
    syntax BlockchainItem ::= ".BlockchainItem"
                            | "{" NetworkCell "|" BlockCell "}"
 // -----------------------------------------------------------

    syntax KItem ::= "#pushBlockchainState"
 // ---------------------------------------
    rule <k> #pushBlockchainState => . ... </k>
         <blockList> (.List => ListItem({ <network> NETWORK </network> | <block> BLOCK </block> })) ... </blockList>
         <network> NETWORK </network>
         <block>   BLOCK   </block>

    syntax KItem ::= #getBlockchainState ( Int )
 // --------------------------------------------
    rule <k> #getBlockchainState(BLOCKNUM) => #setBlockchainState(#getBlockByNumber(BLOCKNUM, BLOCKLIST)) ... </k>
         <blockList> BLOCKLIST </blockList>

    syntax KItem ::= #setBlockchainState ( BlockchainItem )
 // -------------------------------------------------------
    rule <k> #setBlockchainState({ <network> NETWORK </network> | <block> BLOCK </block> }) => . ... </k>
         <network> _ => NETWORK </network>
         <block>   _ => BLOCK   </block>

    rule <k> #setBlockchainState(.BlockchainItem) => #rpcResponseError(-37600, "Unable to find block by number.") ... </k>

    syntax BlockchainItem ::= #getBlockByNumber ( BlockIdentifier , List ) [function]
 // ---------------------------------------------------------------------------------
    rule #getBlockByNumber( ( _:String => "pending" ) , .List) [owise]
    rule #getBlockByNumber( _:Int, .List) => .BlockchainItem
    rule #getBlockByNumber("earliest", _ ListItem( BLOCK )) => BLOCK
    rule #getBlockByNumber("latest", ListItem( BLOCK ) _) => BLOCK

    rule [[ #getBlockByNumber("pending",  BLOCKLIST) => {<network> NETWORK </network> | <block> BLOCK </block>} ]]
         <network> NETWORK </network>
         <block>   BLOCK   </block>

    rule #getBlockByNumber(BLOCKNUM:Int,  ListItem({ _ | <block> <number> BLOCKNUM </number> ... </block> } #as BLOCKCHAINITEM) REST ) => BLOCKCHAINITEM
    rule #getBlockByNumber(BLOCKNUM':Int, ListItem({ _ | <block> <number> BLOCKNUM </number> ... </block> }                   ) REST ) => #getBlockByNumber(BLOCKNUM', REST)
      requires BLOCKNUM =/=Int BLOCKNUM'

    syntax AccountItem ::= AccountCell | ".AccountItem"
 // ---------------------------------------------------

    syntax AccountItem ::= #getAccountFromBlockchainItem( BlockchainItem , Int ) [function]
 // ---------------------------------------------------------------------------------------
    rule #getAccountFromBlockchainItem ( { <network> <accounts> (<account> <acctID> ACCT </acctID> ACCOUNTDATA </account>) ... </accounts>  ... </network> | _ } , ACCT ) => <account> <acctID> ACCT </acctID> ACCOUNTDATA </account>
    rule #getAccountFromBlockchainItem(_, _) => .AccountItem [owise]

    syntax BlockIdentifier ::= Int | String
 // ---------------------------------------

    syntax BlockIdentifier ::= #parseBlockIdentifier ( String ) [function]
 // ----------------------------------------------------------------------
    rule #parseBlockIdentifier(TAG) => TAG
      requires TAG ==String "earliest"
        orBool TAG ==String "latest"
        orBool TAG ==String "pending"

    rule #parseBlockIdentifier(BLOCKNUM) => #parseHexWord(BLOCKNUM) [owise]

    syntax KItem ::= #getAccountAtBlock ( BlockIdentifier , Int )
 // -------------------------------------------------------------
    rule <k> #getAccountAtBlock(BLOCKNUM , ACCTID) => #getAccountFromBlockchainItem(#getBlockByNumber(BLOCKNUM, BLOCKLIST), ACCTID) ... </k>
         <blockList> BLOCKLIST </blockList>

```

WEB3 JSON RPC
-------------

```k
    syntax JSON ::= #getJSON ( JSONKey , JSON ) [function]
 // ------------------------------------------------------
    rule #getJSON( KEY, { KEY : J, _ } )     => J
    rule #getJSON( _, { .JSONs } )           => undef
    rule #getJSON( KEY, { KEY2 : _, REST } ) => #getJSON( KEY, { REST } )
      requires KEY =/=K KEY2

    syntax Int ::= #getInt ( JSONKey , JSON ) [function]
 // ----------------------------------------------------
    rule #getInt( KEY, J ) => {#getJSON( KEY, J )}:>Int

    syntax String ::= #getString ( JSONKey , JSON ) [function]
 // ----------------------------------------------------------
    rule #getString( KEY, J ) => {#getJSON( KEY, J )}:>String

    syntax Bool ::= isJSONUndef ( JSON ) [function]
 // -----------------------------------------------
    rule isJSONUndef(J) => J ==K undef

    syntax IOJSON ::= JSON | IOError
 // --------------------------------

    syntax EthereumSimulation ::= accept() [symbol]
 // -----------------------------------------------
    rule <k> accept() => getRequest() ... </k>
         <web3socket> SOCK </web3socket>
         <web3clientsocket> _ => #accept(SOCK) </web3clientsocket>

    syntax KItem ::= getRequest()
 // -----------------------------
    rule <k> getRequest() => #loadRPCCall(#getRequest(SOCK)) ... </k>
         <web3clientsocket> SOCK </web3clientsocket>
         <batch> _ => undef </batch>

    syntax IOJSON ::= #getRequest(Int) [function, hook(JSON.read)]
 // --------------------------------------------------------------

    syntax K ::= #putResponse(JSON, Int) [function, hook(JSON.write)]
 // -----------------------------------------------------------------

    syntax IOJSON ::= #putResponseError ( JSON ) [klabel(JSON-RPC_putResponseError), symbol]
 // ----------------------------------------------------------------------------------------

    syntax KItem ::= #loadRPCCall(IOJSON)
 // -------------------------------------
    rule <k> #loadRPCCall({ _ } #as J) => #checkRPCCall ~> #runRPCCall ... </k>
         <jsonrpc> _ => #getJSON("jsonrpc", J) </jsonrpc>
         <callid>  _ => #getJSON("id"     , J) </callid>
         <method>  _ => #getJSON("method" , J) </method>
         <params>  _ => #getJSON("params" , J) </params>

    rule <k> #loadRPCCall(#EOF) => #shutdownWrite(SOCK) ~> #close(SOCK) ~> accept() ... </k>
         <web3clientsocket> SOCK </web3clientsocket>

    rule <k> #loadRPCCall([ _, _ ] #as J) => #loadFromBatch ... </k>
         <batch> _ => J </batch>
         <web3response> _ => .List </web3response>

    rule <k> #loadRPCCall(_:String #Or null #Or _:Int #Or [ .JSONs ]) => #rpcResponseError(-32600,  "Invalid Request") ... </k>
         <callid> _ => null </callid>

    rule <k> #loadRPCCall(undef) => #rpcResponseError(-32700,  "Parse error") ... </k>
         <callid> _ => null </callid>

    syntax KItem ::= "#loadFromBatch"
 // ---------------------------------
    rule <k> #loadFromBatch ~> _ => #loadRPCCall(J) </k>
         <batch> [ J , JS => JS ] </batch>

    rule <k> #loadFromBatch ~> _ => #putResponse(List2JSON(RESPONSE), SOCK) ~> getRequest() </k>
         <batch> [ .JSONs ] </batch>
         <web3clientsocket> SOCK </web3clientsocket>
         <web3response> RESPONSE </web3response>
      requires size(RESPONSE) >Int 0

    rule <k> #loadFromBatch ~> _ => getRequest() </k>
         <batch> [ .JSONs ] </batch>
         <web3response> .List </web3response>

    syntax JSON ::= List2JSON(List)        [function]
                  | List2JSON(List, JSONs) [function, klabel(List2JSONAux)]
 // -----------------------------------------------------------------------
    rule List2JSON(L) => List2JSON(L, .JSONs)

    rule List2JSON(L ListItem(J), JS) => List2JSON(L, (J, JS))
    rule List2JSON(.List        , JS) => [ JS ]

    syntax KItem ::= #sendResponse ( JSONs )
 // ----------------------------------------
    rule <k> #sendResponse(J) ~> _ => #putResponse({ "jsonrpc": "2.0", "id": CALLID, J }, SOCK) ~> getRequest() </k>
         <callid> CALLID </callid>
         <web3clientsocket> SOCK </web3clientsocket>
         <batch> undef </batch>
      requires CALLID =/=K undef

    rule <k> #sendResponse(_) ~> _ => getRequest() </k>
         <callid> undef </callid>
         <batch> undef </batch>

    rule <k> #sendResponse(J) ~> _ => #loadFromBatch </k>
         <callid> CALLID </callid>
         <batch> [ _ ] </batch>
         <web3response> ... .List => ListItem({ "jsonrpc": "2.0", "id": CALLID, J }) </web3response>
      requires CALLID =/=K undef

    rule <k> #sendResponse(_) ~> _ => #loadFromBatch </k>
         <callid> undef </callid>
         <batch> [ _ ] </batch>

    syntax KItem ::= #rpcResponseSuccess          ( JSON                )
                   | #rpcResponseSuccessException ( JSON , JSON         )
                   | #rpcResponseError            ( JSON                )
                   | #rpcResponseError            ( Int , String        )
                   | #rpcResponseError            ( Int , String , JSON )
                   | "#rpcResponseUnimplemented"
 // --------------------------------------------
    rule <k> #rpcResponseSuccess(J)                 => #sendResponse( "result" : J )                                                ... </k> requires isProperJson(J)
    rule <k> #rpcResponseSuccessException(RES, ERR) => #sendResponse( ( "result" : RES, "error": ERR ) )                            ... </k> requires isProperJson(RES) andBool isProperJson(ERR)
    rule <k> #rpcResponseError(ERR)                 => #sendResponse( "error" : ERR )                                               ... </k>
    rule <k> #rpcResponseError(CODE, MSG)           => #sendResponse( "error" : { "code": CODE , "message": MSG } )                 ... </k>
    rule <k> #rpcResponseError(CODE, MSG, DATA)     => #sendResponse( "error" : { "code": CODE , "message": MSG , "data" : DATA } ) ... </k> requires isProperJson(DATA)
    rule <k> #rpcResponseUnimplemented              => #sendResponse( "unimplemented" : RPCCALL )                                   ... </k> <method> RPCCALL </method>

    syntax KItem ::= "#checkRPCCall"
 // --------------------------------
    rule <k> #checkRPCCall => . ...</k>
         <jsonrpc> "2.0" </jsonrpc>
         <method> _:String </method>
         <params> undef #Or [ _ ] #Or { _ } </params>
         <callid> _:String #Or null #Or _:Int #Or undef </callid>

    rule <k> #checkRPCCall => #rpcResponseError(-32600, "Invalid Request") ... </k>
         <callid> undef #Or [ _ ] #Or { _ } => null </callid> [owise]

    rule <k> #checkRPCCall => #rpcResponseError(-32600, "Invalid Request") ... </k>
         <callid> _:Int </callid> [owise]

    rule <k> #checkRPCCall => #rpcResponseError(-32600, "Invalid Request") ... </k>
         <callid> _:String </callid> [owise]

    syntax KItem ::= "#runRPCCall"
 // ------------------------------
    rule <k> #runRPCCall => #net_version                             ... </k> <method> "net_version"                             </method>
    rule <k> #runRPCCall => #shh_version                             ... </k> <method> "shh_version"                             </method>

    rule <k> #runRPCCall => #web3_clientVersion                      ... </k> <method> "web3_clientVersion"                      </method>
    rule <k> #runRPCCall => #web3_sha3                               ... </k> <method> "web3_sha3"                               </method>

    rule <k> #runRPCCall => #eth_gasPrice                            ... </k> <method> "eth_gasPrice"                            </method>
    rule <k> #runRPCCall => #eth_blockNumber                         ... </k> <method> "eth_blockNumber"                         </method>
    rule <k> #runRPCCall => #eth_accounts                            ... </k> <method> "eth_accounts"                            </method>
    rule <k> #runRPCCall => #eth_getBalance                          ... </k> <method> "eth_getBalance"                          </method>
    rule <k> #runRPCCall => #eth_getStorageAt                        ... </k> <method> "eth_getStorageAt"                        </method>
    rule <k> #runRPCCall => #eth_getCode                             ... </k> <method> "eth_getCode"                             </method>
    rule <k> #runRPCCall => #eth_getTransactionCount                 ... </k> <method> "eth_getTransactionCount"                 </method>
    rule <k> #runRPCCall => #eth_sign                                ... </k> <method> "eth_sign"                                </method>
    rule <k> #runRPCCall => #eth_newBlockFilter                      ... </k> <method> "eth_newBlockFilter"                      </method>
    rule <k> #runRPCCall => #eth_uninstallFilter                     ... </k> <method> "eth_uninstallFilter"                     </method>
    rule <k> #runRPCCall => #eth_sendTransaction                     ... </k> <method> "eth_sendTransaction"                     </method>
    rule <k> #runRPCCall => #eth_sendRawTransaction                  ... </k> <method> "eth_sendRawTransaction"                  </method>
    rule <k> #runRPCCall => #eth_call                                ... </k> <method> "eth_call"                                </method>
    rule <k> #runRPCCall => #eth_estimateGas                         ... </k> <method> "eth_estimateGas"                         </method>
    rule <k> #runRPCCall => #eth_getTransactionReceipt               ... </k> <method> "eth_getTransactionReceipt"               </method>
    rule <k> #runRPCCall => #eth_getBlockByNumber                    ... </k> <method> "eth_getBlockByNumber"                    </method>
    rule <k> #runRPCCall => #eth_coinbase                            ... </k> <method> "eth_coinbase"                            </method>
    rule <k> #runRPCCall => #eth_getBlockByHash                      ... </k> <method> "eth_getBlockByHash"                      </method>
    rule <k> #runRPCCall => #eth_getBlockTransactionCountByHash      ... </k> <method> "eth_getBlockTransactionCountByHash"      </method>
    rule <k> #runRPCCall => #eth_getBlockTransactionCountByNumber    ... </k> <method> "eth_getBlockTransactionCountByNumber"    </method>
    rule <k> #runRPCCall => #eth_getCompilers                        ... </k> <method> "eth_getCompilers"                        </method>
    rule <k> #runRPCCall => #eth_getFilterChanges                    ... </k> <method> "eth_getFilterChanges"                    </method>
    rule <k> #runRPCCall => #eth_getFilterLogs                       ... </k> <method> "eth_getFilterLogs"                       </method>
    rule <k> #runRPCCall => #eth_getLogs                             ... </k> <method> "eth_getLogs"                             </method>
    rule <k> #runRPCCall => #eth_getTransactionByHash                ... </k> <method> "eth_getTransactionByHash"                </method>
    rule <k> #runRPCCall => #eth_getTransactionByBlockHashAndIndex   ... </k> <method> "eth_getTransactionByBlockHashAndIndex"   </method>
    rule <k> #runRPCCall => #eth_getTransactionByBlockNumberAndIndex ... </k> <method> "eth_getTransactionByBlockNumberAndIndex" </method>
    rule <k> #runRPCCall => #eth_hashrate                            ... </k> <method> "eth_hashrate"                            </method>
    rule <k> #runRPCCall => #eth_newFilter                           ... </k> <method> "eth_newFilter"                           </method>
    rule <k> #runRPCCall => #eth_protocolVersion                     ... </k> <method> "eth_protocolVersion"                     </method>
    rule <k> #runRPCCall => #eth_signTypedData                       ... </k> <method> "eth_signTypedData"                       </method>
    rule <k> #runRPCCall => #eth_subscribe                           ... </k> <method> "eth_subscribe"                           </method>
    rule <k> #runRPCCall => #eth_unsubscribe                         ... </k> <method> "eth_unsubscribe"                         </method>
    rule <k> #runRPCCall => #net_peerCount                           ... </k> <method> "net_peerCount"                           </method>
    rule <k> #runRPCCall => #net_listening                           ... </k> <method> "net_listening"                           </method>
    rule <k> #runRPCCall => #eth_syncing                             ... </k> <method> "eth_syncing"                             </method>
    rule <k> #runRPCCall => #bzz_hive                                ... </k> <method> "bzz_hive"                                </method>
    rule <k> #runRPCCall => #bzz_info                                ... </k> <method> "bzz_info"                                </method>

    rule <k> #runRPCCall => #evm_snapshot                            ... </k> <method> "evm_snapshot"                            </method>
    rule <k> #runRPCCall => #evm_revert                              ... </k> <method> "evm_revert"                              </method>
    rule <k> #runRPCCall => #evm_increaseTime                        ... </k> <method> "evm_increaseTime"                        </method>
    rule <k> #runRPCCall => #evm_mine                                ... </k> <method> "evm_mine"                                </method>

    rule <k> #runRPCCall => #firefly_shutdown                        ... </k> <method> "firefly_shutdown"                        </method>
    rule <k> #runRPCCall => #firefly_addAccount                      ... </k> <method> "firefly_addAccount"                      </method>
    rule <k> #runRPCCall => #firefly_getCoverageData                 ... </k> <method> "firefly_getCoverageData"                 </method>
    rule <k> #runRPCCall => #firefly_getStateRoot                    ... </k> <method> "firefly_getStateRoot"                    </method>
    rule <k> #runRPCCall => #firefly_getTxRoot                       ... </k> <method> "firefly_getTxRoot"                       </method>
    rule <k> #runRPCCall => #firefly_getReceiptsRoot                 ... </k> <method> "firefly_getReceiptsRoot"                 </method>
    rule <k> #runRPCCall => #firefly_getTime                         ... </k> <method> "firefly_getTime"                         </method>
    rule <k> #runRPCCall => #firefly_setTime                         ... </k> <method> "firefly_setTime"                         </method>
    rule <k> #runRPCCall => #firefly_genesisBlock                    ... </k> <method> "firefly_genesisBlock"                    </method>
    rule <k> #runRPCCall => #firefly_setGasLimit                     ... </k> <method> "firefly_setGasLimit"                     </method>

    rule <k> #runRPCCall => #debug_traceTransaction                  ... </k> <method> "debug_traceTransaction"                  </method>
    rule <k> #runRPCCall => #miner_start                             ... </k> <method> "miner_start"                             </method>
    rule <k> #runRPCCall => #miner_stop                              ... </k> <method> "miner_stop"                              </method>
    rule <k> #runRPCCall => #personal_importRawKey                   ... </k> <method> "personal_importRawKey"                   </method>
    rule <k> #runRPCCall => #personal_sendTransaction                ... </k> <method> "personal_sendTransaction"                </method>
    rule <k> #runRPCCall => #personal_unlockAccount                  ... </k> <method> "personal_unlockAccount"                  </method>
    rule <k> #runRPCCall => #personal_newAccount                     ... </k> <method> "personal_newAccount"                     </method>
    rule <k> #runRPCCall => #personal_lockAccount                    ... </k> <method> "personal_lockAccount"                    </method>
    rule <k> #runRPCCall => #personal_listAccounts                   ... </k> <method> "personal_listAccounts"                   </method>

    rule <k> #runRPCCall => #rpcResponseError(-32601, "Method not found") ... </k> [owise]

    syntax KItem ::= "#firefly_shutdown"
 // ------------------------------------
    rule <k> #firefly_shutdown ~> _ => #putResponse({ "jsonrpc": "2.0" , "id": CALLID , "result": "Firefly client shutting down!" }, SOCK) </k>
         <web3shutdownable> true </web3shutdownable>
         <callid> CALLID </callid>
         <web3clientsocket> SOCK </web3clientsocket>
         <exit-code> _ => 0 </exit-code>

    rule <k> #firefly_shutdown => #rpcResponseError(-32800, "Firefly client not started with `--shutdownable`!") ... </k>
         <web3shutdownable> false </web3shutdownable>

    syntax KItem ::= "#net_version"
 // -------------------------------
    rule <k> #net_version => #rpcResponseSuccess(Int2String( CHAINID )) ... </k>
         <chainID> CHAINID </chainID>

    syntax KItem ::= "#web3_clientVersion"
 // --------------------------------------
    rule <k> #web3_clientVersion => #rpcResponseSuccess("Firefly RPC/v0.0.1/kevm") ... </k>

    syntax KItem ::= "#eth_gasPrice"
 // --------------------------------
    rule <k> #eth_gasPrice => #rpcResponseSuccess(#unparseQuantity( PRICE )) ... </k>
         <gasPrice> PRICE </gasPrice>

    syntax KItem ::= "#eth_blockNumber"
 // -----------------------------------
    rule <k> #eth_blockNumber => #rpcResponseSuccess(#unparseQuantity( BLOCKNUM )) ... </k>
         <number> BLOCKNUM </number>

    syntax KItem ::= "#eth_accounts"
 // --------------------------------
    rule <k> #eth_accounts => #rpcResponseSuccess([ #acctsToJArray( qsort(Set2List(ACCTS)) ) ]) ... </k>
         <activeAccounts> ACCTS </activeAccounts>

    syntax JSONs ::= #acctsToJArray ( List ) [function]
 // ---------------------------------------------------
    rule #acctsToJArray( .List                       ) => .JSONs
    rule #acctsToJArray( ListItem( ACCT ) ACCTS:List ) => #unparseData( ACCT, 20 ), #acctsToJArray( ACCTS )

    syntax KItem ::= "#eth_getBalance"
 // ----------------------------------
    rule <k> #eth_getBalance ... </k>
         <params> [ (DATA => #parseHexWord(DATA)), _, .JSONs ] </params>

    rule <k> #eth_getBalance => #getAccountAtBlock(#parseBlockIdentifier(TAG), DATA) ~> #eth_getBalance ... </k>
         <params> [ DATA, TAG, .JSONs ] </params>

    rule <k> <account> ... <balance> ACCTBALANCE </balance> ... </account> ~> #eth_getBalance => #rpcResponseSuccess(#unparseQuantity( ACCTBALANCE )) ... </k>

    rule <k> .AccountItem ~> #eth_getBalance => #rpcResponseSuccess(#unparseQuantity( 0 )) ... </k>

    rule <k> #eth_getBalance => #rpcResponseError(-32000, "Incorrect number of arguments. Method 'eth_getBalance' requires exactly 2 arguments.") ... </k> [owise]

    syntax KItem ::= "#eth_getStorageAt"
 // ------------------------------------
    rule <k> #eth_getStorageAt ... </k>
         <params> [ (DATA => #parseHexWord(DATA)), (QUANTITY => #parseHexWord(QUANTITY)), _, .JSONs ] </params>

    rule <k> #eth_getStorageAt => #getAccountAtBlock(#parseBlockIdentifier(TAG), DATA) ~> #eth_getStorageAt ... </k>
         <params> [ DATA, QUANTITY, TAG, .JSONs ] </params>

    rule <k> <account> ... <storage> STORAGE </storage> ... </account> ~> #eth_getStorageAt => #rpcResponseSuccess(#unparseQuantity( #lookup (STORAGE, QUANTITY) )) ... </k>
         <params> [ DATA, QUANTITY, TAG, .JSONs ] </params>

    rule <k> .AccountItem ~> #eth_getStorageAt => #rpcResponseSuccess(#unparseQuantity( 0 )) ... </k>

    rule <k> #eth_getStorageAt => #rpcResponseError(-32000, "Incorrect number of arguments. Method 'eth_getStorageAt' requires exactly 3 arguments.") ... </k> [owise]

    syntax KItem ::= "#eth_getCode"
 // -------------------------------
    rule <k> #eth_getCode ... </k>
         <params> [ (DATA => #parseHexWord(DATA)), _, .JSONs ] </params>

    rule <k> #eth_getCode => #getAccountAtBlock(#parseBlockIdentifier(TAG), DATA) ~> #eth_getCode ... </k>
         <params> [ DATA, TAG, .JSONs ] </params>

     rule <k> <account> ... <code> CODE </code> ... </account> ~> #eth_getCode =>  #rpcResponseSuccess(#unparseDataByteArray( CODE )) ... </k>

     rule <k> .AccountItem ~> #eth_getCode => #rpcResponseSuccess(#unparseDataByteArray( .ByteArray )) ... </k>

    rule <k> #eth_getCode => #rpcResponseError(-32000, "Incorrect number of arguments. Method 'eth_getCode' requires exactly 2 arguments.") ... </k> [owise]

    syntax KItem ::= "#eth_getTransactionCount"
 // -------------------------------------------
    rule <k> #eth_getTransactionCount ... </k>
         <params> [ (DATA => #parseHexWord(DATA)), _, .JSONs ] </params>

    rule <k> #eth_getTransactionCount => #getAccountAtBlock(#parseBlockIdentifier(TAG), DATA) ~> #eth_getTransactionCount ... </k>
         <params> [ DATA, TAG, .JSONs ] </params>

    rule <k> <account> ... <nonce> NONCE </nonce> ... </account> ~> #eth_getTransactionCount => #rpcResponseSuccess(#unparseQuantity( NONCE )) ... </k>

    rule <k> .AccountItem ~> #eth_getTransactionCount => #rpcResponseSuccess(#unparseQuantity( 0 )) ... </k>

    rule <k> #eth_getTransactionCount => #rpcResponseError(-32000, "Incorrect number of arguments. Method 'eth_getTransactionCount' requires exactly 2 arguments.") ... </k> [owise]

    syntax KItem ::= "#eth_sign"
 // ----------------------------
    rule <k> #eth_sign => #signMessage(KEY, #hashMessage(#unparseByteStack(#parseByteStack(MESSAGE)))) ... </k>
         <params> [ ACCTADDR, MESSAGE, .JSONs ] </params>
         <accountKeys>... #parseHexWord(ACCTADDR) |-> KEY ...</accountKeys>

    rule <k> #eth_sign => #rpcResponseError(3, "Execution error", [{ "code": 100, "message": "Account key doesn't exist, account locked!" }]) ... </k>
         <params> [ ACCTADDR, _ ] </params>
         <accountKeys> KEYMAP </accountKeys>
      requires notBool #parseHexWord(ACCTADDR) in_keys(KEYMAP)

    syntax KItem ::= #signMessage ( String , String )
 // -------------------------------------------------
    rule <k> #signMessage(KEY, MHASH) => #rpcResponseSuccess("0x" +String ECDSASign( MHASH, KEY )) ... </k>

    syntax String ::= #hashMessage ( String ) [function]
 // ----------------------------------------------------
    rule #hashMessage( S ) => #unparseByteStack(#parseHexBytes(Keccak256("\x19Ethereum Signed Message:\n" +String Int2String(lengthString(S)) +String S)))

    syntax SnapshotItem ::= "{" BlockListCell "|" NetworkCell "|" BlockCell "|" TxReceiptsCell "}"
 // ----------------------------------------------------------------------------------------------

    syntax KItem ::= "#evm_snapshot"
 // --------------------------------
    rule <k> #evm_snapshot => #pushNetworkState ~> #rpcResponseSuccess(#unparseQuantity( size ( SNAPSHOTS ) +Int 1 )) ... </k>
         <snapshots> SNAPSHOTS </snapshots>

    syntax KItem ::= "#pushNetworkState"
 // ------------------------------------
    rule <k> #pushNetworkState => . ... </k>
         <snapshots> ... (.List => ListItem({ <blockList> BLOCKLIST </blockList> | <network> NETWORK </network> | <block> BLOCK </block> | <txReceipts> RECEIPTS </txReceipts>})) </snapshots>
         <network>    NETWORK   </network>
         <block>      BLOCK     </block>
         <blockList>  BLOCKLIST </blockList>
         <txReceipts> RECEIPTS  </txReceipts>

    syntax KItem ::= "#popNetworkState"
 // -----------------------------------
    rule <k> #popNetworkState => . ... </k>
         <snapshots> ... ( ListItem({ <blockList> BLOCKLIST </blockList> | <network> NETWORK </network> | <block> BLOCK </block> | <txReceipts> RECEIPTS </txReceipts>}) => .List ) </snapshots>
         <network>    ( _ => NETWORK )   </network>
         <block>      ( _ => BLOCK )     </block>
         <blockList>  ( _ => BLOCKLIST ) </blockList>
         <txReceipts> ( _ => RECEIPTS )  </txReceipts>

    syntax KItem ::= "#evm_revert"
 // ------------------------------
    rule <k> #evm_revert => #popNetworkState ~> #rpcResponseSuccess(true) ... </k>
         <params>    [ DATA:Int, .JSONs ] </params>
         <snapshots> SNAPSHOTS </snapshots>
      requires DATA ==Int ( size(SNAPSHOTS) -Int 1 )

    rule <k> #evm_revert ... </k>
         <params> [ (DATA => #parseHexWord(DATA)), .JSONs ] </params>

    rule <k> #evm_revert ... </k>
         <params> ( [ DATA:Int, .JSONs ] ) </params>
         <snapshots> ( SNAPSHOTS => range(SNAPSHOTS, 0, DATA ) ) </snapshots>
      requires size(SNAPSHOTS) >Int (DATA +Int 1)

    rule <k> #evm_revert => #rpcResponseError(-32000, "Incorrect number of arguments. Method 'evm_revert' requires exactly 1 arguments. Request specified 0 arguments: [null].")  ... </k>
         <params> [ .JSONs ] </params>

     rule <k> #evm_revert => #rpcResponseSuccess(false) ... </k> [owise]

    syntax KItem ::= "#evm_increaseTime"
 // ------------------------------------
    rule <k> #evm_increaseTime => #rpcResponseSuccess(Int2String(TS +Int DATA)) ... </k>
         <params> [ DATA:Int, .JSONs ] </params>
         <timestamp> ( TS:Int => ( TS +Int DATA ) ) </timestamp>

    syntax KItem ::= "#eth_newBlockFilter"
 // --------------------------------------
    rule <k> #eth_newBlockFilter => #rpcResponseSuccess(#unparseQuantity( FILTID )) ... </k>
         <filters>
           ( .Bag
          => <filter>
               <filterID> FILTID </filterID>
               <fromBlock> BLOCKNUM </fromBlock>
               ...
             </filter>
           )
           ...
         </filters>
         <number> BLOCKNUM </number>
         <nextFilterSlot> ( FILTID:Int => FILTID +Int 1 ) </nextFilterSlot>

    syntax KItem ::= "#eth_uninstallFilter"
 // ---------------------------------------
    rule <k> #eth_uninstallFilter ... </k>
         <params> [ (DATA => #parseHexWord(DATA)), .JSONs ] </params>

    rule <k> #eth_uninstallFilter => #rpcResponseSuccess(true) ... </k>
         <params> [ FILTID, .JSONs ] </params>
         <filters>
           ( <filter>
               <filterID> FILTID </filterID>
               ...
             </filter>
          => .Bag
           )
           ...
         </filters>

    rule <k> #eth_uninstallFilter => #rpcResponseSuccess(false) ... </k> [owise]
```

eth_sendTransaction
-------------------

**TODO**: Only call `#executeTx TXID` when mining is turned on, or when the mining interval comes around.

```k
    syntax KItem ::= "#eth_sendTransaction"
                   | "#eth_sendTransaction_final"
 // ---------------------------------------------
    rule <k> #eth_sendTransaction => #loadTx J ~> #eth_sendTransaction_final ... </k>
         <params> [ ({ _ } #as J), .JSONs ] </params>
      requires isString( #getJSON("from",J) )

    rule <k> #eth_sendTransaction => #rpcResponseError(-32000, "\"from\" field not found; is required") ... </k>
         <params> [ ({ _ } #as J), .JSONs ] </params>
      requires notBool isString( #getJSON("from",J) )

    rule <k> #eth_sendTransaction => #rpcResponseError(-32000, "Incorrect number of arguments. Method 'eth_sendTransaction' requires exactly 1 argument.") ... </k> [owise]

    rule <k> (TXID:Int => "0x" +String #hashSignedTx(TN, TP, TG, TT, TV, TD, TW, TR, TS)) ~> #eth_sendTransaction_final ... </k>
         <message>
           <msgID> TXID </msgID>
           <txNonce>    TN </txNonce>
           <txGasPrice> TP </txGasPrice>
           <txGasLimit> TG </txGasLimit>
           <to>         TT </to>
           <value>      TV </value>
           <sigV>       TW </sigV>
           <sigR>       TR </sigR>
           <sigS>       TS </sigS>
           <data>       TD </data>
         </message>

    rule <k> TXHASH:String ~> #eth_sendTransaction_final => #rpcResponseSuccess(TXHASH) ... </k>
         <statusCode> EVMC_SUCCESS </statusCode>

    rule <k> TXHASH:String ~> #eth_sendTransaction_final => #rpcResponseSuccessException(TXHASH,
               { "message": "VM Exception while processing transaction: revert",
                 "code": -32000,
                 "data": {
                     TXHASH: {
                     "error": "revert",
                     "program_counter": PCOUNT +Int 1,
                     "return": #unparseDataByteArray( RD )
                   }
                 }
               } )
          ...
         </k>
         <statusCode> EVMC_REVERT </statusCode>
         <output> RD </output>
         <errorPC> PCOUNT </errorPC>

    rule <k> _:String ~> #eth_sendTransaction_final => #rpcResponseError(-32000, "base fee exceeds gas limit") ... </k>
         <statusCode> EVMC_OUT_OF_GAS </statusCode>

    rule <k> _:String ~> #eth_sendTransaction_final => #rpcResponseError(-32000, "sender doesn't have enough funds to send tx.") ... </k>
         <statusCode> EVMC_BALANCE_UNDERFLOW </statusCode>

    rule <k> _:String ~> #eth_sendTransaction_final => #rpcResponseError(-32000, "VM exception: " +String StatusCode2String( SC )) ... </k>
         <statusCode> SC:ExceptionalStatusCode </statusCode> [owise]

    rule <k> loadTransaction _ { "gas"      : (TG:String => #parseHexWord(TG)), _                 } ... </k>
    rule <k> loadTransaction _ { "gasPrice" : (TP:String => #parseHexWord(TP)), _                 } ... </k>
    rule <k> loadTransaction _ { "nonce"    : (TN:String => #parseHexWord(TN)), _                 } ... </k>
    rule <k> loadTransaction _ { "v"        : (TW:String => #parseHexWord(TW)), _                 } ... </k>
    rule <k> loadTransaction _ { "value"    : (TV:String => #parseHexWord(TV)), _                 } ... </k>
    rule <k> loadTransaction _ { "to"       : (TT:String => #parseHexWord(TT)), _                 } ... </k>
    rule <k> loadTransaction _ { "data"     : (TI:String => #parseByteStack(TI)), _               } ... </k>
    rule <k> loadTransaction _ { "r"        : (TR:String => #padToWidth(32, #parseByteStack(TR))), _ } ... </k>
    rule <k> loadTransaction _ { "s"        : (TS:String => #padToWidth(32, #parseByteStack(TS))), _ } ... </k>
    rule <k> loadTransaction _ { ("from"    : _, REST => REST) } ... </k>

    syntax KItem ::= "#loadNonce" Int Int
 // -------------------------------------
    rule <k> #loadNonce ACCT TXID => . ... </k>
         <message>
           <msgID> TXID </msgID>
           <txNonce> _ => NONCE </txNonce>
           ...
         </message>
         <account>
           <acctID> ACCT </acctID>
           <nonce> NONCE </nonce>
           ...
         </account>
```

- `#hashSignedTx` Takes a transaction ID. Returns the hash of the rlp-encoded transaction with R S and V.

```k
    syntax String ::= #hashSignedTx ( Int ) [function]
                    | #hashSignedTx ( Int , Int , Int , Account , Int , ByteArray , Int , ByteArray , ByteArray ) [function]
 // ------------------------------------------------------------------------------------------------------------------------
    rule #hashSignedTx( TXID ) => Keccak256( #rlpEncodeTransaction( TXID ) )

    rule #hashSignedTx(TN, TP, TG, TT, TV, TD, TW, TR, TS) => Keccak256( #rlpEncodeTransaction(TN, TP, TG, TT, TV, TD, TW, TR, TS) )
```

-   signTX TXID ACCTFROM: Signs the transaction with TXID using ACCTFROM's private key

```k
    syntax KItem ::= "signTX" Int Int
                   | "signTX" Int String [klabel(signTXAux)]
 // --------------------------------------------------------
    rule <k> signTX TXID ACCTFROM:Int => signTX TXID ECDSASign( Hex2Raw( #hashUnsignedTx(TN, TP, TG, TT, TV, TD) ), #unparseByteStack( #padToWidth( 32, #asByteStack( KEY ) ) ) ) ... </k>
         <accountKeys> ... ACCTFROM |-> KEY ... </accountKeys>
         <mode> NORMAL </mode>
         <message>
           <msgID> TXID </msgID>
           <txNonce>    TN </txNonce>
           <txGasPrice> TP </txGasPrice>
           <txGasLimit> TG </txGasLimit>
           <to>         TT </to>
           <value>      TV </value>
           <data>       TD </data>
           ...
         </message>

    rule <k> signTX TXID ACCTFROM:Int => signTX TXID ECDSASign( Hex2Raw( #hashUnsignedTx(TN, TP, TG, TT, TV, TD) ), #unparseByteStack( ( #padToWidth( 20, #asByteStack( ACCTFROM ) ) ++ #padToWidth( 20, #asByteStack( ACCTFROM ) ) )[0 .. 32] ) ) ... </k>
         <mode> NOGAS </mode>
         <message>
           <msgID> TXID </msgID>
           <txNonce>    TN </txNonce>
           <txGasPrice> TP </txGasPrice>
           <txGasLimit> TG </txGasLimit>
           <to>         TT </to>
           <value>      TV </value>
           <data>       TD </data>
           ...
         </message>

    rule <k> signTX TXID SIG:String => . ... </k>
         <message>
           <msgID> TXID </msgID>
           <sigR> _ => #parseHexBytes( substrString( SIG, 0, 64 ) )           </sigR>
           <sigS> _ => #parseHexBytes( substrString( SIG, 64, 128 ) )         </sigS>
           <sigV> _ => #parseHexWord( substrString( SIG, 128, 130 ) ) +Int 27 </sigV>
           ...
         </message>
```

eth_sendRawTransaction
----------------------

**TODO**: Verify the signature provided for the transaction

```k

    syntax KItem ::= "#eth_sendRawTransaction"
                   | "#eth_sendRawTransactionLoad"
                   | "#eth_sendRawTransactionVerify" Int
                   | "#eth_sendRawTransactionSend" Int
 // ----------------------------------------------------
    rule <k> #eth_sendRawTransaction => #eth_sendRawTransactionLoad ... </k>
         <params> [ RAWTX:String, .JSONs ] => #rlpDecode( Hex2Raw( RAWTX ) ) </params>

    rule <k> #eth_sendRawTransaction => #rpcResponseError(-32000, "\"value\" argument must not be a number") ... </k>
         <params> [ _:Int, .JSONs ] </params>

    rule <k> #eth_sendRawTransaction => #rpcResponseError(-32000, "Invalid Signature") ... </k> [owise]

    rule <k> #eth_sendRawTransactionLoad
          => mkTX !ID:Int
          ~> loadTransaction !ID { "data"  : Raw2Hex(TI) , "gas"      : Raw2Hex(TG) , "gasPrice" : Raw2Hex(TP)
                                 , "nonce" : Raw2Hex(TN) , "r"        : Raw2Hex(TR) , "s"        : Raw2Hex(TS)
                                 , "to"    : Raw2Hex(TT) , "v"        : Raw2Hex(TW) , "value"    : Raw2Hex(TV)
                                 , .JSONs
                                 }
          ~> #eth_sendRawTransactionVerify !ID
         ...
         </k>
         <params> [ TN, TP, TG, TT, TV, TI, TW, TR, TS, .JSONs ] </params>

    rule <k> #eth_sendRawTransactionLoad => #rpcResponseError(-32000, "Invalid Signature") ... </k> [owise]

    rule <k> #eth_sendRawTransactionVerify TXID => #eth_sendRawTransactionSend TXID ... </k>
         <message>
           <msgID> TXID </msgID>
           <txNonce>    TN </txNonce>
           <txGasPrice> TP </txGasPrice>
           <txGasLimit> TG </txGasLimit>
           <to>         TT </to>
           <value>      TV </value>
           <data>       TD </data>
           <sigV>       TW </sigV>
           <sigR>       TR </sigR>
           <sigS>       TS </sigS>
         </message>
      requires ECDSARecover( Hex2Raw( #hashUnsignedTx(TN, TP, TG, TT, TV, TD) ), TW, #unparseByteStack(TR), #unparseByteStack(TS) ) =/=String ""

    rule <k> #eth_sendRawTransactionVerify _ => #rpcResponseError(-32000, "Invalid Signature") ... </k> [owise]

    rule <k> #eth_sendRawTransactionSend TXID => #rpcResponseSuccess("0x" +String #hashSignedTx(TN, TP, TG, TT, TV, TD, TW, TR, TS)) ... </k>
         <message>
           <msgID> TXID </msgID>
           <txNonce>    TN </txNonce>
           <txGasPrice> TP </txGasPrice>
           <txGasLimit> TG </txGasLimit>
           <to>         TT </to>
           <value>      TV </value>
           <data>       TD </data>
           <sigV>       TW </sigV>
           <sigR>       TR </sigR>
           <sigS>       TS </sigS>
         </message>
```

Retrieving Blocks
-----------------

**TODO**
- <logsBloom> defaults to .ByteArray, but maybe it should be 256 zero bytes? It also doesn't get updated.
- Ganache's gasLimit defaults to 6721975 (0x6691b7), but we default it at 0.
- After each txExecution which is not `eth_call`:
   - use `#setBlockchainItem`
   - clear <txPending> and <txOrder>
- Some initialization still needs to be done, like the trie roots and the 0 block in <blockList>
   - I foresee issues with firefly_addAccount and personal_importRawKey if we want those accounts
     in the stateRoot of the initial block

```k
    syntax KItem ::= "#eth_getBlockByNumber"
 // ----------------------------------------
    rule <k> #eth_getBlockByNumber => #eth_getBlockByNumber_finalize( #getBlockByNumber( #parseBlockIdentifier(TAG), BLOCKLIST)) ... </k>
         <params> [ TAG:String, TXOUT:Bool, .JSONs ] </params>
         <blockList> BLOCKLIST </blockList>
    rule <k> #eth_getBlockByNumber => #rpcResponseError(-32000, "Incorrect number of arguments. Method 'eth_getBlockByNumber' requires exactly 2 arguments.") ... </k>
         <params> [ VALUE, .JSONs ] </params>
      requires notBool isJSONs( VALUE )

    rule <k> #eth_getBlockByNumber => #rpcResponseError(-32000, "Incorrect number of arguments. Method 'eth_getBlockByNumber' requires exactly 2 arguments.") ... </k>
         <params> [ VALUE, VALUE2, _, .JSONs ] </params>
      requires notBool isJSONs( VALUE ) andBool notBool isJSONs( VALUE2 )

    syntax KItem ::= "#eth_getBlockByNumber_finalize" "(" BlockchainItem ")"
 // ------------------------------------------------------------------------
    rule <k> #eth_getBlockByNumber_finalize ({ _ |
         <block>
           <previousHash>      PARENTHASH  </previousHash>
           <ommersHash>        OMMERSHASH  </ommersHash>
           <coinbase>          MINER       </coinbase>
           <stateRoot>         STATEROOT   </stateRoot>
           <transactionsRoot>  TXROOT      </transactionsRoot>
           <receiptsRoot>      RCPTROOT    </receiptsRoot>
           <logsBloom>         LOGSBLOOM   </logsBloom> //#bloomFilter(<log> LOGS </>)
           <difficulty>        DFFCLTY     </difficulty>
           <number>            NUM         </number>
           <gasLimit>          GLIMIT      </gasLimit>
           <gasUsed>           GUSED       </gasUsed>
           <timestamp>         TIME        </timestamp>
           <extraData>         DATA        </extraData>
           <mixHash>           MIXHASH     </mixHash>
           <blockNonce>        NONCE       </blockNonce>
           ...
         </block> } #as BLOCKITEM)
          => #rpcResponseSuccess( { "number": #unparseQuantity( NUM )
                                  , "hash": "0x" +String Keccak256( #rlpEncodeBlock( BLOCKITEM ) )
                                  , "parentHash": #unparseData( PARENTHASH, 32 )
                                  , "mixHash": #unparseData( MIXHASH, 32 )
                                  , "nonce": #unparseData( NONCE, 8 )
                                  , "sha3Uncles": #unparseData( OMMERSHASH, 32 )
                                  , "logsBloom": #unparseDataByteArray( LOGSBLOOM )
                                  , "transactionsRoot": #unparseData( TXROOT, 32)
                                  , "stateRoot": #unparseData( STATEROOT, 32)
                                  , "receiptsRoot": #unparseData( RCPTROOT, 32)
                                  , "miner": #unparseData( MINER, 20 )
                                  , "difficulty": #unparseQuantity( DFFCLTY )
                                  , "totalDifficulty": #unparseQuantity( DFFCLTY )
                                  , "extraData": #unparseDataByteArray( DATA )
                                  , "size": "0x3e8"                                  // Ganache always returns 1000
                                  , "gasLimit": #unparseQuantity( GLIMIT )
                                  , "gasUsed": #unparseQuantity( GUSED )
                                  , "timestamp": #unparseQuantity( TIME )
                                  , "transactions": [ #getTransactionList( BLOCKITEM ) ]
                                  , "uncles": [ .JSONs ]
                                  }
                                )
          ...
         </k>

    rule <k> #eth_getBlockByNumber_finalize ( .BlockchainItem )=> #rpcResponseSuccess(null) ... </k>

    syntax JSONs ::= "#getTransactionList" "(" BlockchainItem ")" [function]
                   | #getTransactionHashList ( List, JSONs )      [function]
 // ------------------------------------------------------------------------
    rule [[ #getTransactionList ( { <network> <txOrder> TXIDLIST </txOrder> ... </network> | _ } )
         => #getTransactionHashList (TXIDLIST, .JSONs)
         ]]
         <params> [ _ , false, .JSONs ] </params>

    rule #getTransactionHashList ( .List, RESULT ) => RESULT
    rule [[ #getTransactionHashList ( ( ListItem(TXID) => .List ) TXIDLIST, ( RESULT => TXHASH, RESULT ) ) ]]
         <txReceipt>
           <txID>   TXID   </txID>
           <txHash> TXHASH </txHash>
           ...
         </txReceipt>
```

Transaction Receipts
--------------------

-   The transaction receipt is a tuple of four items comprising:

    -   the cumulative gas used in the block containing the transaction receipt as of immediately after the transaction has happened,
    -   the set of logs created through execution of the transaction,
    -   the Bloom filter composed from information in those logs, and
    -   the status code of the transaction.

```k
    syntax KItem ::= "#makeTxReceipt" Int
 // -------------------------------------
    rule <k> #makeTxReceipt TXID => . ... </k>
         <txReceipts>
           ( .Bag
          => <txReceipt>
               <txHash> "0x" +String #hashSignedTx(TN, TP, TG, TT, TV, TD, TW, TR, TS) </txHash>
               <txCumulativeGas> CGAS </txCumulativeGas>
               <logSet> LOGS </logSet>
               <bloomFilter> #bloomFilter(LOGS) </bloomFilter>
               <txStatus> bool2Word(STATUSCODE ==K EVMC_SUCCESS) </txStatus>
               <txID> TXID </txID>
               <sender> #parseHexWord(#unparseDataByteArray(#ecrecAddr(#sender(TN, TP, TG, TT, TV, #unparseByteStack(TD), TW , TR, TS)))) </sender>
               <txBlockNumber> BN +Int 1 </txBlockNumber>
             </txReceipt>
           )
           ...
         </txReceipts>
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
           <data>       TD   </data>
         </message>
         <statusCode> STATUSCODE </statusCode>
         <gasUsed> CGAS </gasUsed>
         <log> LOGS </log>
         <number> BN </number>

    syntax KItem ::= "#eth_getTransactionReceipt"
                   | "#eth_getTransactionReceipt_final" "(" BlockchainItem ")"
 // --------------------------------------------------------------------------
    rule <k> #eth_getTransactionReceipt => #eth_getTransactionReceipt_final(#getBlockByNumber (BN, BLOCKLIST)) ... </k>
         <params> [TXHASH:String, .JSONs] </params>
         <txReceipt>
           <txHash>          TXHASH </txHash>
           <txBlockNumber>   BN     </txBlockNumber>
           ...
         </txReceipt>
         <blockList> BLOCKLIST </blockList>

    rule <k> #eth_getTransactionReceipt_final ({
             <network>
               <txOrder> TXLIST </txOrder>
               <message>
                 <msgID>      TXID     </msgID>
                 <txNonce>    TN       </txNonce>
                 <to>         TT:Account </to>
                 <sigV>       TW       </sigV>
                 <sigR>       TR       </sigR>
                 <sigS>       TS       </sigS>
                 ...
               </message>
               <account>
                 <acctID> TXFROM </acctID>
                 <nonce>  NONCE  </nonce>
                 ...
               </account>
               ...
             </network> | _ } #as BLOCKITEM )
          => #rpcResponseSuccess( { "transactionHash": TXHASH
                                  , "transactionIndex": #unparseQuantity(getIndexOf(TXID, TXLIST))
                                  , "blockHash": "0x" +String Keccak256(#rlpEncodeBlock(BLOCKITEM))
                                  , "blockNumber": #unparseQuantity(BN)
                                  , "from": #unparseAccount(TXFROM)
                                  , "to": #unparseAccount(TT)
                                  , "gasUsed": #unparseQuantity(CGAS)
                                  , "cumulativeGasUsed": #unparseQuantity(CGAS)
                                  , "contractAddress": #if TT ==K .Account #then #unparseData(#newAddr(TXFROM, NONCE -Int 1), 20) #else null #fi
                                  , "logs": [#serializeLogs(LOGS, 0, getIndexOf(TXID, TXLIST), TXHASH, "0x" +String Keccak256(#rlpEncodeBlock(BLOCKITEM)), BN)]
                                  , "status": #unparseQuantity(TXSTATUS)
                                  , "logsBloom": #unparseDataByteArray(BLOOM)
                                  , "v": #unparseQuantity(TW)
                                  , "r": #unparseQuantity( #asWord(TR) )
                                  , "s": #unparseQuantity( #asWord(TS) )
                                  }
                                )
         ...
         </k>
         <params> [TXHASH:String, .JSONs] </params>
         <txReceipt>
           <txHash>          TXHASH </txHash>
           <txID>            TXID </txID>
           <txCumulativeGas> CGAS </txCumulativeGas>
           <logSet>          LOGS </logSet>
           <bloomFilter>     BLOOM </bloomFilter>
           <txStatus>        TXSTATUS </txStatus>
           <sender>          TXFROM </sender>
           <txBlockNumber>   BN     </txBlockNumber>
         </txReceipt>

    rule <k> #eth_getTransactionReceipt => #rpcResponseSuccess(null) ... </k> [owise]

    syntax Int ::= getIndexOf ( Int, List ) [function]
 // --------------------------------------------------
    rule getIndexOf(X:Int, L) => getIndexOfAux(X:Int, L, 0)

    syntax Int ::= getIndexOfAux (Int, List, Int) [function]
 // --------------------------------------------------------
    rule getIndexOfAux (X:Int, .List,         _:Int) => -1
    rule getIndexOfAux (X:Int, ListItem(X) L, INDEX) => INDEX
    rule getIndexOfAux (X:Int, ListItem(I) L, INDEX) => getIndexOfAux(X, L, INDEX +Int 1) requires X =/=Int I

    syntax JSON ::= #unparseAccount ( Account ) [function]
 // ------------------------------------------------------
    rule #unparseAccount (.Account) => null
    rule #unparseAccount (ACCT:Int) => #unparseData(ACCT, 20)

    syntax JSONs ::= #unparseIntList ( List ) [function]
 // ----------------------------------------------------
    rule #unparseIntList (L) => #unparseIntListAux( L, .JSONs)

    syntax JSONs ::= #unparseIntListAux ( List, JSONs ) [function]
 // --------------------------------------------------------------
    rule #unparseIntListAux(.List, RESULT) => RESULT
    rule #unparseIntListAux(L ListItem(I), RESULT) => #unparseIntListAux(L, (#unparseDataByteArray(#padToWidth(32,#asByteStack(I))), RESULT))

    syntax JSONs ::= #serializeLogs ( List, Int, Int, String, String, Int ) [function]
 // ----------------------------------------------------------------------------------
    rule #serializeLogs (.List, _, _, _, _, _)  => .JSONs
    rule #serializeLogs (ListItem({ ACCT | TOPICS:List | DATA }) L, LI, TI, TH, BH, BN) => {
                                                                         "logIndex": #unparseQuantity(LI),
                                                                         "transactionIndex": #unparseQuantity(TI),
                                                                         "transactionHash": TH,
                                                                         "blockHash": BH,
                                                                         "blockNumber": #unparseQuantity(BN),
                                                                         "address": #unparseData(ACCT, 20),
                                                                         "data": #unparseDataByteArray(DATA),
                                                                         "topics": [#unparseIntList(TOPICS)],
                                                                         "type" : "mined"
                                                                                           }, #serializeLogs(L, LI +Int 1, TI, TH, BH, BN)
```

- loadCallState: web3.md specific rules

```k
    rule <k> loadCallState { "from" : ( ACCTFROM:String => #parseHexWord( ACCTFROM ) ), REST } ... </k>
    rule <k> loadCallState { "to" : ( ACCTTO:String => #parseHexWord( ACCTTO ) ), REST } ... </k>
    rule <k> loadCallState { "gas" : ( GLIMIT:String => #parseHexWord( GLIMIT ) ), REST } ... </k>
    rule <k> loadCallState { "gasPrice" : ( GPRICE:String => #parseHexWord( GPRICE ) ), REST } ... </k>
    rule <k> loadCallState { "value" : ( VALUE:String => #parseHexWord( VALUE ) ), REST } ... </k>
    rule <k> loadCallState { "nonce" : _, REST => REST } ... </k>

    rule <k> loadCallState { "from" : ACCTFROM:Int, REST => REST } ... </k>
         <caller> _ => ACCTFROM </caller>
         <origin> _ => ACCTFROM </origin>

    rule <k> loadCallState { "to" : .Account   , REST => REST } ... </k>
    rule <k> loadCallState { ("to" : ACCTTO:Int => "code" : CODE), REST } ... </k>
         <id> _ => ACCTTO </id>
         <account>
           <acctID> ACCTTO </acctID>
           <code> CODE </code>
           ...
         </account>

    rule <k> ( . => #newAccount ACCTTO ) ~> loadCallState { "to" : ACCTTO:Int, REST } ... </k> [owise]

    rule <k> loadCallState TXID:Int
          => loadCallState {
               "from":     #unparseDataByteArray(#ecrecAddr(#sender(TN, TP, TG, TT, TV, #unparseByteStack(DATA), TW , TR, TS))),
               "to":       TT,
               "gas":      TG,
               "gasPrice": TP,
               "value":    TV,
               "data":     DATA
             }
         ...
         </k>
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
         </message>

    syntax ByteArray ::= #ecrecAddr ( Account ) [function]
 // ------------------------------------------------------
    rule #ecrecAddr(.Account) => .ByteArray
    rule #ecrecAddr(N:Int)    => #padToWidth(20, #asByteStack(N))
```

Transaction Execution
---------------------

- `#executeTx` takes a transaction, loads it into the current state and executes it.
**TODO**: treat the account creation case
**TODO**: record the logs after `finalizeTX`
**TODO**: execute all pending transactions

```k
    syntax KItem ::= "#loadTx" JSON
 // -------------------------------
    rule <k> #loadTx J
          => mkTX !ID:Int
          ~> #loadNonce #parseHexWord(#getString("from", J)) !ID
          ~> loadTransaction !ID J
          ~> signTX !ID #parseHexWord(#getString("from", J))
          ~> #prepareTx !ID #parseHexWord(#getString("from", J))
          ~> !ID
          ...
         </k>

    syntax KItem ::= "#prepareTx" Int Account
 // -----------------------------------------
    rule <k> #prepareTx TXID:Int ACCTFROM
          => #clearLogs
          ~> #validateTx TXID
         ...
         </k>
         <origin> _ => ACCTFROM </origin>

    syntax KItem ::= "#validateTx" Int
 // ----------------------------------
    rule <k> #validateTx TXID => . ... </k>
         <statusCode> ( _ => EVMC_OUT_OF_GAS) </statusCode>
         <schedule> SCHED </schedule>
         <message>
           <msgID>      TXID   </msgID>
           <txGasLimit> GLIMIT </txGasLimit>
           <data>       DATA   </data>
           <to>         ACCTTO </to>
           ...
         </message>
      requires ( GLIMIT -Int G0(SCHED, DATA, (ACCTTO ==K .Account)) ) <Int 0

    rule <k> #validateTx TXID => #executeTx TXID ~> #makeTxReceipt TXID ~> #finishTx ... </k>
         <schedule> SCHED </schedule>
         <callGas> _ => GLIMIT -Int G0(SCHED, DATA, (ACCTTO ==K .Account) ) </callGas>
         <message>
           <msgID>      TXID   </msgID>
           <txGasLimit> GLIMIT </txGasLimit>
           <data>       DATA   </data>
           <to>         ACCTTO </to>
           ...
         </message>
      requires ( GLIMIT -Int G0(SCHED, DATA, (ACCTTO ==K .Account)) ) >=Int 0

    syntax KItem ::= "#executeTx" Int
 // ---------------------------------
    rule <k> #executeTx TXID:Int
          => #create ACCTFROM #newAddr(ACCTFROM, NONCE) VALUE CODE
          ~> #catchHaltTx #newAddr(ACCTFROM, NONCE)
          ~> #finalizeTx(false)
         ...
         </k>
         <gasPrice> _ => GPRICE </gasPrice>
         <origin> ACCTFROM </origin>
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
           ...
         </message>
         <account>
           <acctID> ACCTFROM </acctID>
           <balance> BAL => BAL -Int (GLIMIT *Int GPRICE) </balance>
           <nonce> NONCE </nonce>
           ...
         </account>
         <touchedAccounts> _ => SetItem(MINER) </touchedAccounts>

    rule <k> #executeTx TXID:Int
          => #call ACCTFROM ACCTTO ACCTTO VALUE VALUE DATA false
          ~> #catchHaltTx .Account
          ~> #finalizeTx(false)
         ...
         </k>
         <origin> ACCTFROM </origin>
         <gasPrice> _ => GPRICE </gasPrice>
         <txPending> ListItem(TXID) ... </txPending>
         <callDepth> _ => -1 </callDepth>
         <coinbase> MINER </coinbase>
         <message>
           <msgID>      TXID   </msgID>
           <txGasPrice> GPRICE </txGasPrice>
           <txGasLimit> GLIMIT </txGasLimit>
           <to>         ACCTTO </to>
           <value>      VALUE  </value>
           <data>       DATA   </data>
           ...
         </message>
         <account>
           <acctID> ACCTFROM </acctID>
           <balance> BAL => BAL -Int (GLIMIT *Int GPRICE) </balance>
           <nonce> NONCE => NONCE +Int 1 </nonce>
           ...
         </account>
         <touchedAccounts> _ => SetItem(MINER) </touchedAccounts>
      requires ACCTTO =/=K .Account

    syntax KItem ::= "#finishTx"
 // ----------------------------
    rule <statusCode> STATUSCODE </statusCode>
         <k> #finishTx => #mineBlock ... </k>
         <mode> EXECMODE </mode>
      requires EXECMODE =/=K NOGAS
       andBool ( STATUSCODE ==K EVMC_SUCCESS orBool STATUSCODE ==K EVMC_REVERT )

    rule <k> #finishTx => #clearGas ... </k> [owise]

    syntax KItem ::= "#catchHaltTx" Account
 // ---------------------------------------
    rule <statusCode> _:ExceptionalStatusCode </statusCode>
         <k> #halt ~> #catchHaltTx _ => #popCallStack ~> #popWorldState ... </k>

    rule <statusCode> EVMC_REVERT </statusCode>
         <k> #halt ~> #catchHaltTx _ => #popCallStack ~> #popWorldState ~> #refund GAVAIL ... </k>
         <pc> PCOUNT </pc>
         <gas> GAVAIL </gas>
         <errorPC> _ => PCOUNT </errorPC>

    rule <statusCode> EVMC_SUCCESS </statusCode>
         <k> #halt ~> #catchHaltTx .Account => . ... </k>

    rule <statusCode> EVMC_SUCCESS </statusCode>
         <k> #halt ~> #catchHaltTx ACCT => #mkCodeDeposit ACCT ... </k>
      requires ACCT =/=K .Account

    syntax KItem ::= "#clearLogs"
 // -----------------------------
    rule <k> #clearLogs => . ... </k>
         <log> _ => .List </log>
```

- `#personal_importRawKey` Takes an unencrypted private key, encrypts it with a passphrase, stores it and returns the address of the key.

**TODO**: Currently nothing is done with the passphrase

```k
    syntax KItem ::= "#personal_importRawKey"
 // -----------------------------------------
    rule <k> #personal_importRawKey => #acctFromPrivateKey PRIKEY ~> #rpcResponseSuccess(#unparseData( #addrFromPrivateKey( PRIKEY ), 20 )) ... </k>
         <params> [ PRIKEY:String, PASSPHRASE:String, .JSONs ] </params>
      requires lengthString( PRIKEY ) ==Int 66

    rule <k> #personal_importRawKey => #rpcResponseError(-32000, "Private key length is invalid. Must be 32 bytes.") ... </k>
         <params> [ PRIKEY:String, _:String, .JSONs ] </params>
      requires lengthString( PRIKEY ) =/=Int 66

    rule <k> #personal_importRawKey => #rpcResponseError(-32000, "Method 'personal_importRawKey' requires exactly 2 parameters") ... </k> [owise]

    syntax KItem ::= "#acctFromPrivateKey" String
 // ---------------------------------------------
    rule <k> #acctFromPrivateKey KEY => #newAccount #addrFromPrivateKey(KEY) ... </k>
         <accountKeys> M => M[#addrFromPrivateKey(KEY) <- #parseHexWord(KEY)] </accountKeys>

    syntax KItem ::= "#firefly_addAccount" | "#firefly_addAccountByAddress" Int | "#firefly_addAccountByKey" String
 // ---------------------------------------------------------------------------------------------------------------
    rule <k> #firefly_addAccount => #firefly_addAccountByAddress #parseHexWord(#getString("address", J)) ... </k>
         <params> [ ({ _ } #as J), .JSONs ] </params>
      requires isString(#getJSON("address", J))

    rule <k> #firefly_addAccount => #firefly_addAccountByKey #getString("key", J) ... </k>
         <params> [ ({ _ } #as J), .JSONs ] </params>
      requires isString(#getJSON("key", J))

    rule <k> #firefly_addAccountByAddress ACCT_ADDR => #newAccount ACCT_ADDR ~> loadAccount ACCT_ADDR J ~> #rpcResponseSuccess(true) ... </k>
         <params> [ ({ _ } #as J), .JSONs ] </params>
         <activeAccounts> ACCTS </activeAccounts>
      requires notBool ACCT_ADDR in ACCTS

    rule <k> #firefly_addAccountByAddress ACCT_ADDR => #rpcResponseSuccess(false) ... </k>
         <params> [ ({ _ } #as J), .JSONs ] </params>
         <activeAccounts> ACCTS </activeAccounts>
      requires ACCT_ADDR in ACCTS

    rule <k> #firefly_addAccountByKey ACCT_KEY => #acctFromPrivateKey ACCT_KEY ~> loadAccount #addrFromPrivateKey(ACCT_KEY) J ~> #rpcResponseSuccess(true) ... </k>
         <params> [ ({ _ } #as J), .JSONs ] </params>
         <activeAccounts> ACCTS </activeAccounts>
      requires notBool #addrFromPrivateKey(ACCT_KEY) in ACCTS

    rule <k> #firefly_addAccountByKey ACCT_KEY => #rpcResponseSuccess(false) ... </k>
         <params> [ ({ _ } #as J), .JSONs ] </params>
          <activeAccounts> ACCTS </activeAccounts>
      requires #addrFromPrivateKey(ACCT_KEY) in ACCTS

    rule <k> #firefly_addAccount => #rpcResponseError(-32025, "Method 'firefly_addAccount' has invalid arguments") ... </k> [owise]

    rule <k> loadAccount _ { "balance" : ((VAL:String)         => #parseHexWord(VAL)),     _ } ... </k>
    rule <k> loadAccount _ { "nonce"   : ((VAL:String)         => #parseHexWord(VAL)),     _ } ... </k>
    rule <k> loadAccount _ { "code"    : ((CODE:String)        => #parseByteStack(CODE)),  _ } ... </k>
    rule <k> loadAccount _ { "storage" : ({ STORAGE:JSONs } => #parseMap({ STORAGE })), _ } ... </k>
    rule <k> loadAccount _ { "key" : _, REST => REST } ... </k>
    rule <k> loadAccount _ { "address" : _, REST => REST } ... </k>
```

- `#eth_call`
 **TODO**: add logic for the case in which "from" field is not present

```k
    syntax KItem ::= "#eth_call"
 // ----------------------------
    rule <k> #eth_call
          => #pushNetworkState
          ~> #setMode NOGAS
          ~> #loadTx J
          ~> #eth_call_finalize
         ...
         </k>
         <params> [ ({ _ } #as J), TAG, .JSONs ] </params>
      requires isString( #getJSON("from" , J) )

    rule <k> #eth_call => #rpcResponseError(-32027, "Method 'eth_call' has invalid arguments") ...  </k>
         <params> [ ({ _ } #as J), TAG, .JSONs ] </params>
      requires notBool isString( #getJSON("from", J) )

    syntax KItem ::= "#eth_call_finalize"
 // -------------------------------------
    rule <statusCode> EVMC_SUCCESS </statusCode>
         <k> _:Int ~> #eth_call_finalize
          => #setMode NORMAL
          ~> #popNetworkState
          ~> #clearGas
          ~> #rpcResponseSuccess(#unparseDataByteArray( OUTPUT ))
         ...
         </k>
         <output> OUTPUT </output>

    rule <statusCode> EVMC_REVERT </statusCode>
         <k> TXID:Int ~> #eth_call_finalize
          => #setMode NORMAL
          ~> #popNetworkState
          ~> #clearGas
          ~> #rpcResponseError(
               { "message": "VM Exception while processing transaction: revert",
                 "code": -32000,
                 "data": {
                     "0x" +String #hashSignedTx(TN, TP, TG, TT, TV, TD, TW, TR, TS): {
                     "error": "revert",
                     "program_counter": PCOUNT +Int 1,
                     "return": #unparseDataByteArray( RD )
                   }
                 }
               } )

         ...
         </k>
         <errorPC> PCOUNT </errorPC>
         <output> RD </output>
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
           <data>       TD   </data>
         </message>
```

- `#eth_estimateGas`
**TODO**: add test for EVMC_OUT_OF_GAS
**TODO**: implement funcionality for block number argument

```k
    syntax KItem ::= "#eth_estimateGas"
 // -----------------------------------
    rule <k> #eth_estimateGas
          => #pushNetworkState
          ~> #loadTx J
          ~> #eth_estimateGas_finalize GUSED
         ...
         </k>
         <params> [ ({ _ } #as J), TAG, .JSONs ] </params>
         <gasUsed>  GUSED  </gasUsed>
      requires isString(#getJSON("from", J) )

    rule <k> #eth_estimateGas => #rpcResponseError(-32028, "Method 'eth_estimateGas' has invalid arguments") ...  </k>
         <params> [ ({ _ } #as J), TAG, .JSONs ] </params>
      requires notBool isString( #getJSON("from", J) )

    syntax KItem ::= "#eth_estimateGas_finalize" Int
 // ------------------------------------------------
    rule <k> _:Int ~> #eth_estimateGas_finalize INITGUSED:Int => #popNetworkState ~> #rpcResponseSuccess(#unparseQuantity( #getGasUsed( #getBlockByNumber( "latest", BLOCKLIST ) ) -Int INITGUSED )) ... </k>
         <statusCode> STATUSCODE </statusCode>
         <blockList> BLOCKLIST </blockList>
      requires STATUSCODE =/=K EVMC_OUT_OF_GAS

    rule <k> _:Int ~> #eth_estimateGas_finalize _ => #popNetworkState ~> #rpcResponseError(-32000 , "base fee exceeds gas limit") ... </k>
         <statusCode> EVMC_OUT_OF_GAS </statusCode>

    syntax Int ::= #getGasUsed( BlockchainItem ) [function]
 // -------------------------------------------------------
    rule #getGasUsed( { _ | <block> <gasUsed> GUSED </gasUsed> ... </block> } ) => GUSED
```

NOGAS Mode
----------

- Used for `eth_call` RPC messages

```k
    syntax Mode ::= "NOGAS"
 // -----------------------
    rule <k> #gas [ OP , AOP ] => . ... </k>
         <mode> NOGAS </mode>
     [priority(25)]

    rule <k> #validateTx TXID => #executeTx TXID ~> #makeTxReceipt TXID ~> #finishTx ... </k>
         <mode> NOGAS </mode>
     [priority(25)]
```

Collecting Coverage Data
------------------------

- `<execPhase>` cell is used to differentiate between the generated code used for contract deployment and the bytecode of the contract.
- `<opcodeCoverage>` cell is a map which stores the program counters which were hit during the execution of a program. The key, named `CoverageIdentifier`, contains the hash of the bytecode which is executed, and the phase of the execution.
- `<opcodeLists>` cell is a map similar to `<opcodeCoverage>` which stores instead a list containing all the `OpcodeItem`s of the executed bytecode for each contract.
- `OpcodeItem` is a tuple which contains the Program Counter and the Opcode name.

**TODO**: instead of having both `#serializeCoverage` and `#serializePrograms` we could keep only the first rule as `#serializeCoverageMap` if `<opcodeLists>` would store `Sets` instead of `Lists`.
**TODO**: compute coverage percentages in `Float` instead of `Int`
**TODO**: `Set2List` won't return `ListItems` in order, causing tests to fail.

```k
    syntax Phase ::= ".Phase"
                   | "CONSTRUCTOR"
                   | "RUNTIME"

    syntax CoverageIdentifier ::= "{" Int "|" Phase "}"

    rule <k> #mkCall _ _ _ _ _ _ _ ... </k>
         <execPhase> ( EPHASE => RUNTIME ) </execPhase>
      requires EPHASE =/=K RUNTIME
      [priority(25)]

    rule <k> #mkCreate _ _ _ _ ... </k>
         <execPhase> ( EPHASE => CONSTRUCTOR ) </execPhase>
      requires EPHASE =/=K CONSTRUCTOR
      [priority(25)]

    rule <k> #initVM ... </k>
         <opcodeCoverage> OC => OC [ {keccak(PGM) | EPHASE} <- .Set ] </opcodeCoverage>
         <execPhase> EPHASE </execPhase>
         <program> PGM </program>
      requires notBool {keccak(PGM) | EPHASE} in_keys(OC)
      [priority(25)]


    rule <k> #initVM ... </k>
         <opcodeLists> OL => OL [ {keccak(PGM) | EPHASE} <- #parseByteCode(PGM,SCHED) ] </opcodeLists>
         <execPhase> EPHASE </execPhase>
         <schedule> SCHED </schedule>
         <program> PGM </program>
      requires notBool {keccak(PGM) | EPHASE} in_keys(OL)
      [priority(25)]

    syntax OpcodeItem ::= "{" Int "|" OpCode "}"

    syntax List ::= #parseByteCode( ByteArray, Schedule ) [function]
 // ----------------------------------------------------------------
    rule #parseByteCode(PGM , SCHED) => #parseByteCodeAux(0, #sizeByteArray(PGM), PGM, SCHED, .List)

    syntax List ::= #parseByteCodeAux ( Int, Int, ByteArray, Schedule, List ) [function]
 // ------------------------------------------------------------------------------------
    rule #parseByteCodeAux(PCOUNT, SIZE, _, _, OPLIST) => OPLIST
      requires PCOUNT >=Int SIZE
    rule #parseByteCodeAux(PCOUNT, SIZE, PGM, SCHED, OPLIST) => #parseByteCodeAux(PCOUNT +Int #widthOp(#dasmOpCode(PGM [ PCOUNT ], SCHED)), SIZE, PGM, SCHED, OPLIST ListItem({ PCOUNT | #dasmOpCode(PGM [ PCOUNT ], SCHED) } ) )
      requires PCOUNT <Int SIZE

    rule <k> #execute ... </k>
         <pc> PCOUNT </pc>
         <execPhase> EPHASE </execPhase>
         <program> PGM </program>
         <opcodeCoverage> ... { keccak(PGM) | EPHASE } |-> (PCS (.Set => SetItem(PCOUNT))) ... </opcodeCoverage>
      requires notBool PCOUNT in PCS
      [priority(25)]

    syntax KItem ::= "#firefly_getCoverageData"
 // -------------------------------------------
    rule <k> #firefly_getCoverageData => #rpcResponseSuccess(#makeCoverageReport(COVERAGE, PGMS)) ... </k>
         <opcodeCoverage> COVERAGE </opcodeCoverage>
         <opcodeLists>    PGMS     </opcodeLists>

    syntax JSON ::= #makeCoverageReport ( Map, Map ) [function]
 // -----------------------------------------------------------
    rule #makeCoverageReport (COVERAGE, PGMS) => {
                                                  "coverages": [#coveragePercentages(keys_list(PGMS),COVERAGE,PGMS)],
                                                  "coveredOpcodes": [#serializeCoverage(keys_list(COVERAGE),COVERAGE)],
                                                  "programs": [#serializePrograms(keys_list(PGMS),PGMS)]
                                                 }

    syntax JSONs ::= #serializeCoverage ( List, Map ) [function]
 // ------------------------------------------------------------
    rule #serializeCoverage (.List, _ ) => .JSONs
    rule #serializeCoverage ((ListItem({ CODEHASH | EPHASE } #as KEY) KEYS), KEY |-> X:Set COVERAGE:Map ) => { Int2String(CODEHASH):{ Phase2String(EPHASE): [IntList2JSONs(qsort(Set2List(X)))] }}, #serializeCoverage(KEYS, COVERAGE)

    syntax JSONs ::= #serializePrograms ( List, Map ) [function]
 // ------------------------------------------------------------
    rule #serializePrograms (.List, _ ) => .JSONs
    rule #serializePrograms ((ListItem({ CODEHASH | EPHASE } #as KEY) KEYS), KEY |-> X:List PGMS:Map ) => { Int2String(CODEHASH):{ Phase2String(EPHASE): [CoverageIDList2JSONs(X)] }}, #serializePrograms(KEYS, PGMS)

    syntax String ::= Phase2String ( Phase ) [function]
 // ----------------------------------------------------
    rule Phase2String (CONSTRUCTOR) => "CONSTRUCTOR"
    rule Phase2String (RUNTIME)     => "RUNTIME"

    syntax JSONs ::= CoverageIDList2JSONs ( List ) [function]
 // ---------------------------------------------------------
    rule CoverageIDList2JSONs (.List)                           => .JSONs
    rule CoverageIDList2JSONs (ListItem({I:Int | _:OpCode }) L) => I, CoverageIDList2JSONs(L)

    syntax JSONs ::= IntList2JSONs ( List ) [function]
 // --------------------------------------------------
    rule IntList2JSONs (.List)             => .JSONs
    rule IntList2JSONs (ListItem(I:Int) L) => I, IntList2JSONs(L)

    syntax List ::= getIntElementsSmallerThan ( Int, List, List ) [function]
 // ------------------------------------------------------------------------
    rule getIntElementsSmallerThan (_, .List,               RESULTS) => RESULTS
    rule getIntElementsSmallerThan (X, (ListItem(I:Int) L), RESULTS) => getIntElementsSmallerThan (X, L, ListItem(I) RESULTS) requires I  <Int X
    rule getIntElementsSmallerThan (X, (ListItem(I:Int) L), RESULTS) => getIntElementsSmallerThan (X, L, RESULTS)             requires I >=Int X

    syntax List ::= getIntElementsGreaterThan ( Int, List, List ) [function]
 // ------------------------------------------------------------------------
    rule getIntElementsGreaterThan (_, .List ,              RESULTS) => RESULTS
    rule getIntElementsGreaterThan (X, (ListItem(I:Int) L), RESULTS) => getIntElementsGreaterThan (X, L, ListItem(I) RESULTS) requires I  >Int X
    rule getIntElementsGreaterThan (X, (ListItem(I:Int) L), RESULTS) => getIntElementsGreaterThan (X, L, RESULTS)             requires I <=Int X

    syntax List ::= qsort ( List ) [function]
 // -----------------------------------------
    rule qsort ( .List )           => .List
    rule qsort (ListItem(I:Int) L) => qsort(getIntElementsSmallerThan(I, L, .List)) ListItem(I) qsort(getIntElementsGreaterThan(I, L, .List))

    syntax JSONs ::= #coveragePercentages ( List, Map, Map) [function]
 // ------------------------------------------------------------------
    rule #coveragePercentages (.List, _, _) => .JSONs
    rule #coveragePercentages ((ListItem({ CODEHASH | EPHASE } #as KEY) KEYS), KEY |-> X:Set COVERAGE:Map, KEY |-> Y:List PGMS:Map) => { Int2String(CODEHASH):{ Phase2String(EPHASE): #computePercentage(size(X),size(Y)) }}, #coveragePercentages(KEYS,COVERAGE,PGMS)

    syntax Int ::= #computePercentage ( Int, Int ) [function]
 // ---------------------------------------------------------
    rule #computePercentage (EXECUTED, TOTAL) => (100 *Int EXECUTED) /Int TOTAL
```

Helper Funcs
------------

```k
    syntax AccountData ::= #getAcctData( Account ) [function]
 // ---------------------------------------------------------
    rule [[ #getAcctData( ACCT ) => AcctData(NONCE, BAL, STORAGE, CODE) ]]
         <account>
           <acctID>  ACCT    </acctID>
           <nonce>   NONCE   </nonce>
           <balance> BAL     </balance>
           <storage> STORAGE </storage>
           <code>    CODE    </code>
           ...
         </account>

    syntax String ::= #rlpEncodeBlock( BlockchainItem ) [function]
 // --------------------------------------------------------------
    rule #rlpEncodeBlock( { _ |
         <block>
           <previousHash>      PARENTHASH  </previousHash>
           <ommersHash>        OMMERSHASH  </ommersHash>
           <coinbase>          MINER       </coinbase>
           <stateRoot>         STATEROOT   </stateRoot>
           <transactionsRoot>  TXROOT      </transactionsRoot>
           <receiptsRoot>      RCPTROOT    </receiptsRoot>
           <logsBloom>         LOGSBLOOM   </logsBloom>
           <difficulty>        DFFCLTY     </difficulty>
           <number>            NUM         </number>
           <gasLimit>          GLIMIT      </gasLimit>
           <gasUsed>           GUSED       </gasUsed>
           <timestamp>         TIME        </timestamp>
           <extraData>         DATA        </extraData>
           <mixHash>           MIXHASH     </mixHash>
           <blockNonce>        NONCE       </blockNonce>
           ...
         </block> } )
         => #rlpEncodeLength(         #rlpEncodeBytes( PARENTHASH, 32 )
                              +String #rlpEncodeBytes( OMMERSHASH, 32 )
                              +String #rlpEncodeBytes( MINER, 20 )
                              +String #rlpEncodeBytes( STATEROOT, 32 )
                              +String #rlpEncodeBytes( TXROOT, 32 )
                              +String #rlpEncodeBytes( RCPTROOT, 32 )
                              +String #rlpEncodeBytes( #asInteger( LOGSBLOOM ), 256 )
                              +String #rlpEncodeWord ( DFFCLTY )
                              +String #rlpEncodeWord ( NUM )
                              +String #rlpEncodeWord ( GLIMIT )
                              +String #rlpEncodeWord ( GUSED )
                              +String #rlpEncodeWord ( TIME )
                              +String #rlpEncodeBytes( #asInteger( DATA ), #sizeByteArray( DATA ) )
                              +String #rlpEncodeBytes( MIXHASH, 32 )
                              +String #rlpEncodeBytes( NONCE, 8 )
                            , 192
                            )

    syntax String ::= #rlpEncodeTransaction( Int ) [function]
                    | #rlpEncodeTransaction( Int , Int , Int , Account , Int , ByteArray , Int , ByteArray , ByteArray ) [function]
 // -------------------------------------------------------------------------------------------------------------------------------
    rule [[ #rlpEncodeTransaction( TXID )
         => #rlpEncodeLength(         #rlpEncodeWord( TXNONCE )
                              +String #rlpEncodeWord( GPRICE )
                              +String #rlpEncodeWord( GLIMIT )
                              +String #rlpEncodeAccount( ACCTTO )
                              +String #rlpEncodeWord( VALUE )
                              +String #rlpEncodeString( #unparseByteStack( DATA ) )
                              +String #rlpEncodeWord( V )
                              +String #rlpEncodeString( #unparseByteStack( #asByteStack( #asWord( R ) ) ) )
                              +String #rlpEncodeString( #unparseByteStack( #asByteStack( #asWord( S ) ) ) )
                            , 192
                            )
         ]]
         <message>
           <msgID> TXID </msgID>
           <txNonce>    TXNONCE </txNonce>
           <txGasPrice> GPRICE  </txGasPrice>
           <txGasLimit> GLIMIT  </txGasLimit>
           <to>         ACCTTO  </to>
           <value>      VALUE   </value>
           <data>       DATA    </data>
           <sigR>       R       </sigR>
           <sigS>       S       </sigS>
           <sigV>       V       </sigV>
         </message>

    rule #rlpEncodeTransaction(TN, TP, TG, TT, TV, TD, TW, TR, TS)
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

    syntax String ::= #rlpEncodeReceipt( Int )       [function]
                    | #rlpEncodeReceiptAux( String ) [function]
 // -----------------------------------------------------------
    rule #rlpEncodeReceipt( I ) => #rlpEncodeReceiptAux( "0x" +String #hashSignedTx( I ) )
    rule [[ #rlpEncodeReceiptAux( TXHASH ) =>
            #rlpEncodeLength(         #rlpEncodeWord( STATUS )
                              +String #rlpEncodeWord( CGAS )
                              +String #rlpEncodeString( #asString( BLOOM ) )
                              +String #rlpEncodeLogs( LOGS )
                            , 192
                            )
         ]]
         <txReceipt>
           <txHash> TXHASH </txHash>
           <txCumulativeGas> CGAS   </txCumulativeGas>
           <logSet>          LOGS   </logSet>
           <bloomFilter>     BLOOM  </bloomFilter>
           <txStatus>        STATUS </txStatus>
           ...
         </txReceipt>

    syntax String ::= #rlpEncodeLogs   ( List ) [function]
                    | #rlpEncodeLogsAux( List ) [function]
 // ------------------------------------------------------
    rule #rlpEncodeLogs( .List ) => "\xc0"
    rule #rlpEncodeLogs( LOGS )  => #rlpEncodeLength( #rlpEncodeLogsAux( LOGS ), 192 )
      requires LOGS =/=K .List

    rule #rlpEncodeLogsAux( .List ) => ""
    rule #rlpEncodeLogsAux( ListItem({ ACCT | TOPICS | DATA }) LOGS )
      => #rlpEncodeLength(         #rlpEncodeBytes( ACCT, 20 )
                           +String #rlpEncodeTopics( TOPICS )
                           +String #rlpEncodeString( #asString( DATA ) )
                         , 192 )
         +String #rlpEncodeLogsAux( LOGS )

    syntax String ::= #rlpEncodeTopics   ( List ) [function]
                    | #rlpEncodeTopicsAux( List ) [function]
 // --------------------------------------------------------
    rule #rlpEncodeTopics( .List )  => "\xc0"
    rule #rlpEncodeTopics( TOPICS ) => #rlpEncodeLength( #rlpEncodeTopicsAux( TOPICS ), 192 )
      requires TOPICS =/=K .List

    rule #rlpEncodeTopicsAux( .List ) => ""
    rule #rlpEncodeTopicsAux( ListItem( X:Int ) TOPICS ) => #rlpEncodeBytes( X, 32 ) +String #rlpEncodeTopicsAux( TOPICS )
```

State Root
----------

```k
    syntax MerkleTree ::= "#stateRoot" [function]
 // ---------------------------------------------
    rule #stateRoot => MerkleUpdateMap( .MerkleTree, #precompiledContracts #activeAccounts )

    syntax Map ::= "#activeAccounts"   [function]
                 | #accountsMap( Set ) [function]
 // ---------------------------------------------
    rule [[ #activeAccounts => #accountsMap( ACCTS ) ]]
         <activeAccounts> ACCTS </activeAccounts>

    rule #accountsMap( .Set ) => .Map
    rule #accountsMap( SetItem( ACCT:Int ) S ) => #parseByteStack( #unparseData( ACCT, 20 ) ) |-> #rlpEncodeFullAccount( #getAcctData( ACCT ) ) #accountsMap( S )

    syntax KItem ::= "#firefly_getStateRoot"
 // ----------------------------------------
    rule <k> #firefly_getStateRoot => #rpcResponseSuccess({ "stateRoot" : "0x" +String Keccak256( #rlpEncodeMerkleTree( #stateRoot ) ) }) ... </k>
```

Transactions Root
-----------------

```k
    syntax MerkleTree ::= "#transactionsRoot" [function]
 // ----------------------------------------------------
    rule #transactionsRoot => MerkleUpdateMap( .MerkleTree, #transactionsMap )

    syntax Map ::= "#transactionsMap"               [function]
                 | #transactionsMapAux( Int, List ) [function]
 // ----------------------------------------------------------
    rule [[ #transactionsMap => #transactionsMapAux( 0, TXLIST ) ]]
         <txOrder> TXLIST </txOrder>

    rule #transactionsMapAux( _, .List )    => .Map [owise]
    rule [[ #transactionsMapAux( I, ListItem(TXID:Int) REST )
         => #parseByteStackRaw( #rlpEncodeWord( I ) )[0 .. 1] |-> #rlpEncodeTransaction(TN, TP, TG, TT, TV, TD, TW, TR, TS) #transactionsMapAux( I +Int 1, REST )
         ]]
         <message>
           <msgID> TXID </msgID>
           <txNonce>    TN </txNonce>
           <txGasPrice> TP </txGasPrice>
           <txGasLimit> TG </txGasLimit>
           <to>         TT </to>
           <value>      TV </value>
           <sigV>       TW </sigV>
           <sigR>       TR </sigR>
           <sigS>       TS </sigS>
           <data>       TD </data>
         </message>

    syntax KItem ::= "#firefly_getTxRoot"
 // -------------------------------------
    rule <k> #firefly_getTxRoot => #rpcResponseSuccess({ "transactionsRoot" : #getTxRoot( #getBlockByNumber( "latest", BLOCKLIST ) ) }) ... </k>
         <blockList> BLOCKLIST </blockList>

    syntax String ::= #getTxRoot( BlockchainItem ) [function]
 // ---------------------------------------------------------
    rule #getTxRoot( { _ | <block> <transactionsRoot> TXROOT </transactionsRoot> ... </block> } ) => #unparseData( TXROOT, 32 )
```

Receipts Root
-------------

```k
    syntax MerkleTree ::= "#receiptsRoot" [function]
 // ------------------------------------------------
    rule #receiptsRoot => MerkleUpdateMap( .MerkleTree, #receiptsMap )

    syntax Map ::= "#receiptsMap"         [function]
                 | #receiptsMapAux( Int ) [function]
 // ------------------------------------------------
    rule #receiptsMap => #receiptsMapAux( 0 )

    rule    #receiptsMapAux( _ ) => .Map [owise]
    rule [[ #receiptsMapAux( I ) => #parseByteStackRaw( #rlpEncodeWord( I ) )[0 .. 1] |-> #rlpEncodeReceipt( { TXLIST[ I ] }:>Int ) #receiptsMapAux( I +Int 1 ) ]]
         <txOrder> TXLIST </txOrder>
      requires size(TXLIST) >Int I

    syntax KItem ::= "#firefly_getReceiptsRoot"
 // -------------------------------------------
    rule <k> #firefly_getReceiptsRoot => #rpcResponseSuccess({ "receiptsRoot" : #getReceiptRoot( #getBlockByNumber( "latest", BLOCKLIST ) ) }) ... </k>
         <blockList> BLOCKLIST </blockList>

    syntax String ::= #getReceiptRoot( BlockchainItem ) [function]
 // --------------------------------------------------------------
    rule #getReceiptRoot( { _ | <block> <receiptsRoot> RCPTROOT </receiptsRoot> ... </block> } ) => #unparseData( RCPTROOT, 32 )
```

Timestamp Calls
---------------

```k
    syntax KItem ::= "#firefly_getTime"
 // -----------------------------------
    rule <k> #firefly_getTime => #rpcResponseSuccess(#unparseQuantity( TIME )) ... </k>
         <timestamp> TIME </timestamp>

    syntax KItem ::= "#firefly_setTime"
 // -----------------------------------
    rule <k> #firefly_setTime => #rpcResponseSuccess(true) ... </k>
         <params> [ TIME:String, .JSONs ] </params>
         <timestamp> _ => #parseHexWord( TIME ) </timestamp>

    rule <k> #firefly_setTime => #rpcResponseSuccess(false) ... </k> [owise]
```

Gas Limit Call
--------------

```k
    syntax KItem ::= "#firefly_setGasLimit"
 // ---------------------------------------
    rule <k> #firefly_setGasLimit => #rpcResponseSuccess(true) ... </k>
         <params> [ GLIMIT:String, .JSONs ] </params>
         <gasLimit> _ => #parseWord( GLIMIT ) </gasLimit>

    rule <k> #firefly_setGasLimit => #rpcResponseSuccess(true) ... </k>
         <params> [ GLIMIT:Int, .JSONs ] </params>
         <gasLimit> _ => GLIMIT </gasLimit>

    rule <k> #firefly_setGasLimit => #rpcResponseError(-32000, "firefly_setGasLimit requires exactly 1 argument") ... </k> [owise]
```

Mining
------

```k
    syntax KItem ::= "#evm_mine"
 // ----------------------------
    rule <k> #evm_mine => #mineBlock ~> #rpcResponseSuccess("0x0") ... </k> [owise]

    rule <k> #evm_mine => #mineBlock ~> #rpcResponseSuccess("0x0") ... </k>
         <params> [ TIME:String, .JSONs ] </params>
         <timestamp> _ => #parseWord( TIME ) </timestamp>

    rule <k> #evm_mine => #rpcResponseError(-32000, "Incorrect number of arguments. Method 'evm_mine' requires between 0 and 1 arguments.") ... </k>
         <params> [ _ , _ , _:JSONs ] </params>

    syntax KItem ::= "#firefly_genesisBlock"
 // ----------------------------------------
    rule <k> #firefly_genesisBlock => #updateTrieRoots ~> #pushBlockchainState ~> #rpcResponseSuccess(true) ... </k>
         <logsBloom> _ => #padToWidth( 256, .ByteArray ) </logsBloom>
         <ommersHash> _ => 13478047122767188135818125966132228187941283477090363246179690878162135454535 </ommersHash>

    syntax KItem ::= "#mineBlock"
 // -----------------------------
    rule <k> #mineBlock => #finalizeBlock ~> #getParentHash ~> #updateTrieRoots ~> #saveState ~> #startBlock ~> #cleanTxLists ~> #clearGas ... </k>

    syntax KItem ::= "#saveState"
                   | "#incrementBlockNumber"
                   | "#cleanTxLists"
                   | "#clearGas"
                   | "#getParentHash"
                   | "#updateTrieRoots"
                   | "#updateStateRoot"
                   | "#updateTransactionsRoot"
                   | "#updateReceiptsRoot"
 // --------------------------------------
    rule <k> #saveState => #incrementBlockNumber ~> #pushBlockchainState ... </k>

    rule <k> #incrementBlockNumber => . ... </k>
         <number> BN => BN +Int 1 </number>

    rule <k> #cleanTxLists => . ... </k>
         <txPending> _ => .List </txPending>
         <txOrder>   _ => .List </txOrder>

    rule <k> #clearGas => . ... </k>
         <gas> _ => 0 </gas>

    rule <k> #getParentHash => . ... </k>
         <blockList> BLOCKLIST </blockList>
         <previousHash> _ => #parseHexWord( Keccak256( #rlpEncodeBlock( #getBlockByNumber( "latest", BLOCKLIST ) ) ) ) </previousHash>

    rule <k> #updateTrieRoots => #updateStateRoot ~> #updateTransactionsRoot ~> #updateReceiptsRoot ... </k>
    rule <k> #updateStateRoot => . ... </k>
         <stateRoot> _ => #parseHexWord( Keccak256( #rlpEncodeMerkleTree( #stateRoot ) ) ) </stateRoot>
    rule <k> #updateTransactionsRoot => . ... </k>
         <transactionsRoot> _ => #parseHexWord( Keccak256( #rlpEncodeMerkleTree( #transactionsRoot ) ) ) </transactionsRoot>
    rule <k> #updateReceiptsRoot => . ... </k>
         <receiptsRoot> _ => #parseHexWord( Keccak256( #rlpEncodeMerkleTree( #receiptsRoot ) ) ) </receiptsRoot>
```

Unimplemented Methods
---------------------

```k
    syntax KItem ::= "#eth_coinbase"
                   | "#eth_getBlockByHash"
                   | "#eth_getBlockTransactionCountByHash"
                   | "#eth_getBlockTransactionCountByNumber"
                   | "#eth_getCompilers"
                   | "#eth_getFilterChanges"
                   | "#eth_getFilterLogs"
                   | "#eth_getLogs"
                   | "#eth_getTransactionByHash"
                   | "#eth_getTransactionByBlockHashAndIndex"
                   | "#eth_getTransactionByBlockNumberAndIndex"
                   | "#eth_hashrate"
                   | "#eth_newFilter"
                   | "#eth_protocolVersion"
                   | "#eth_signTypedData"
                   | "#eth_subscribe"
                   | "#eth_unsubscribe"
                   | "#net_peerCount"
                   | "#net_listening"
                   | "#eth_syncing"
                   | "#bzz_hive"
                   | "#bzz_info"
                   | "#debug_traceTransaction"
                   | "#miner_start"
                   | "#miner_stop"
                   | "#personal_sendTransaction"
                   | "#personal_unlockAccount"
                   | "#personal_newAccount"
                   | "#personal_lockAccount"
                   | "#personal_listAccounts"
                   | "#web3_sha3"
                   | "#shh_version"
 // -------------------------------
    rule <k> #eth_coinbase                            => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_getBlockByHash                      => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_getBlockTransactionCountByHash      => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_getBlockTransactionCountByNumber    => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_getCompilers                        => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_getFilterChanges                    => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_getFilterLogs                       => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_getLogs                             => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_getTransactionByHash                => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_getTransactionByBlockHashAndIndex   => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_getTransactionByBlockNumberAndIndex => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_hashrate                            => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_newFilter                           => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_protocolVersion                     => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_signTypedData                       => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_subscribe                           => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_unsubscribe                         => #rpcResponseUnimplemented ... </k>
    rule <k> #net_peerCount                           => #rpcResponseUnimplemented ... </k>
    rule <k> #net_listening                           => #rpcResponseUnimplemented ... </k>
    rule <k> #eth_syncing                             => #rpcResponseUnimplemented ... </k>
    rule <k> #bzz_hive                                => #rpcResponseUnimplemented ... </k>
    rule <k> #bzz_info                                => #rpcResponseUnimplemented ... </k>
    rule <k> #debug_traceTransaction                  => #rpcResponseUnimplemented ... </k>
    rule <k> #miner_start                             => #rpcResponseUnimplemented ... </k>
    rule <k> #miner_stop                              => #rpcResponseUnimplemented ... </k>
    rule <k> #personal_sendTransaction                => #rpcResponseUnimplemented ... </k>
    rule <k> #personal_unlockAccount                  => #rpcResponseUnimplemented ... </k>
    rule <k> #personal_newAccount                     => #rpcResponseUnimplemented ... </k>
    rule <k> #personal_lockAccount                    => #rpcResponseUnimplemented ... </k>
    rule <k> #personal_listAccounts                   => #rpcResponseUnimplemented ... </k>
    rule <k> #web3_sha3                               => #rpcResponseUnimplemented ... </k>
    rule <k> #shh_version                             => #rpcResponseUnimplemented ... </k>

endmodule
```
