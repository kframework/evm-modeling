requires "verification.k"

module VAT-FORK-DIFF-PASS-ROUGH-SPEC
    imports VERIFICATION

    // Vat_fork-diff
    claim [Vat.fork-diff.pass.rough]:
      <k> #execute ~> CONTINUATION => #halt ~> CONTINUATION </k>
      <exit-code> 1 </exit-code>
      <mode> NORMAL </mode>
      <schedule> ISTANBUL </schedule>
      <ethereum>
        <evm>
          <output> .ByteArray </output>
          <statusCode> _ => EVMC_SUCCESS </statusCode>
          <endPC> _ => ?_ </endPC>
          <callStack> _VCallStack </callStack>
          <interimStates> _ </interimStates>
          <touchedAccounts> _ => ?_ </touchedAccounts>
          <callState>
            <program> Vat_bin_runtime </program>
            <jumpDests> #computeValidJumpDests(Vat_bin_runtime) </jumpDests>
            <id> ACCT_ID </id>
            <caller> CALLER_ID </caller>
            <callData> #abiCallData("fork", #bytes32(ABI_ilk), #address(ABI_src), #address(ABI_dst), #int256(ABI_dink), #int256(ABI_dart)) ++ CD => ?_ </callData>
            <callValue> VCallValue </callValue>
            <wordStack> .WordStack => ?_ </wordStack>
            <localMem> .Memory => ?_ </localMem>
            <pc> 0 => ?_ </pc>
            <gas> #gas(VGas) => ?_ </gas>
            <memoryUsed> 0 => ?_ </memoryUsed>
            <callGas> _ => ?_ </callGas>
            <static> false </static>
            <callDepth> VCallDepth </callDepth>
          </callState>
          <substate>
            <selfDestruct> _VSelfDestruct </selfDestruct>
            <log> _ => ?_ </log>
            <refund> _Vrefund => ?_ </refund>
            <accessedAccounts> _ => ?_ </accessedAccounts>
            <accessedStorage> _ => ?_ </accessedStorage>
          </substate>
          <gasPrice> _ </gasPrice>
          <origin> ORIGIN_ID </origin>
          <blockhashes> _ </blockhashes>
          <block>
            <previousHash> _ </previousHash>
            <ommersHash> _ </ommersHash>
            <coinbase> _ </coinbase>
            <stateRoot> _ </stateRoot>
            <transactionsRoot> _ </transactionsRoot>
            <receiptsRoot> _ </receiptsRoot>
            <logsBloom> _ </logsBloom>
            <difficulty> _ </difficulty>
            <number> _BLOCK_NUMBER </number>
            <gasLimit> _ </gasLimit>
            <gasUsed> _ </gasUsed>
            <timestamp> TIME </timestamp>
            <extraData> _ </extraData>
            <mixHash> _ </mixHash>
            <blockNonce> _ </blockNonce>
            <ommerBlockHeaders> _ </ommerBlockHeaders>
          </block>
        </evm>
        <network>
          <chainID> VChainId </chainID>
          <activeAccounts> SetItem(ACCT_ID)
          SetItem(1)
          SetItem(2)
          SetItem(3)
          SetItem(4)
          SetItem(5)
          SetItem(6)
          SetItem(7)
          SetItem(8)
          SetItem(9) _ </activeAccounts>
          <accounts>
            <account>
              <acctID> ACCT_ID </acctID>
              <balance> ACCT_ID_balance </balance>
              <code> Vat_bin_runtime </code>
              <storage> ACCT_ID_STORAGE => ACCT_ID_STORAGE [ #Vat.urns[ABI_ilk][ABI_src].ink <- Ink_u -Int ABI_dink ] [ #Vat.urns[ABI_ilk][ABI_src].art <- Art_u -Int ABI_dart ] [ #Vat.urns[ABI_ilk][ABI_dst].ink <- Ink_v +Int ABI_dink ] [ #Vat.urns[ABI_ilk][ABI_dst].art <- Art_v +Int ABI_dart ] </storage>
              <origStorage> ACCT_ID_ORIG_STORAGE </origStorage>
              <nonce> _Nonce_Vat => ?_ </nonce>
            </account>
            <account>
              <acctID> 1 </acctID>
              <balance> ECREC_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 2 </acctID>
              <balance> SHA256_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 3 </acctID>
              <balance> RIP160_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 4 </acctID>
              <balance> ID_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 5 </acctID>
              <balance> MODEXP_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 6 </acctID>
              <balance> ECADD_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 7 </acctID>
              <balance> ECMUL_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 8 </acctID>
              <balance> ECPAIRING_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 9 </acctID>
              <balance> BLAKE2_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
           ...
          </accounts>
          <txOrder> _ </txOrder>
          <txPending> _ </txPending>
          <messages> _ </messages>
        </network>
      </ethereum>
      requires #rangeAddress(ACCT_ID)
       andBool ACCT_ID =/=Int 0
       andBool #notPrecompileAddress(ACCT_ID)
       andBool #rangeAddress(CALLER_ID)
       andBool #rangeAddress(ORIGIN_ID)
       andBool #rangeUInt(256, TIME)
       andBool #rangeUInt(256, ACCT_ID_balance)
       andBool #rangeUInt(256, ECREC_BAL)
       andBool #rangeUInt(256, SHA256_BAL)
       andBool #rangeUInt(256, RIP160_BAL)
       andBool #rangeUInt(256, ID_BAL)
       andBool #rangeUInt(256, MODEXP_BAL)
       andBool #rangeUInt(256, ECADD_BAL)
       andBool #rangeUInt(256, ECMUL_BAL)
       andBool #rangeUInt(256, ECPAIRING_BAL)
       andBool #rangeUInt(256, BLAKE2_BAL)
       andBool VCallDepth <=Int 1024
       andBool #rangeUInt(256, VCallValue)
       andBool #rangeUInt(256, VChainId)

       andBool (#rangeBytes(32, ABI_ilk)
       andBool (#rangeAddress(ABI_src)
       andBool (#rangeAddress(ABI_dst)
       andBool (#rangeSInt(256, ABI_dink)
       andBool (#rangeSInt(256, ABI_dart)
       andBool (#rangeUInt(256, Can_src)
       andBool (#rangeUInt(256, Can_dst)
       andBool (#rangeUInt(256, Rate)
       andBool (#rangeUInt(256, Spot)
       andBool (#rangeUInt(256, Dust)
       andBool (#rangeUInt(256, Ink_u)
       andBool (#rangeUInt(256, Art_u)
       andBool (#rangeUInt(256, Ink_v)
       andBool (#rangeUInt(256, Art_v)
       andBool ((#sizeByteArray(CD) <=Int 1250000000)
       andBool ((ABI_src =/=Int ABI_dst)
       andBool (#rangeUInt(256, Junk_0)
       andBool (#rangeUInt(256, Junk_1)
       andBool (#rangeUInt(256, Junk_2)
       andBool (#rangeUInt(256, Junk_3)
       andBool (#rangeUInt(256, Junk_4)
       andBool (#rangeUInt(256, Junk_5)
       andBool (#rangeUInt(256, Junk_6)
       andBool (#rangeUInt(256, Junk_7)
       andBool (#rangeUInt(256, Junk_8)
       andBool (((VCallValue ==Int 0))
       andBool ((((ABI_src ==Int CALLER_ID) orBool (Can_src ==Int 1)))
       andBool ((((ABI_dst ==Int CALLER_ID) orBool (Can_dst ==Int 1)))
       andBool ((((Art_u -Int ABI_dart) *Int Rate <=Int (Ink_u -Int ABI_dink) *Int Spot))
       andBool ((((Art_v +Int ABI_dart) *Int Rate <=Int (Ink_v +Int ABI_dink) *Int Spot))
       andBool (((((Art_u -Int ABI_dart) *Int Rate >=Int Dust) orBool (Art_u -Int ABI_dart ==Int 0)))
       andBool (((((Art_v +Int ABI_dart) *Int Rate >=Int Dust) orBool (Art_v +Int ABI_dart ==Int 0)))
       andBool ((#rangeUInt(256, Ink_u -Int ABI_dink))
       andBool ((#rangeUInt(256, Ink_v +Int ABI_dink))
       andBool ((#rangeUInt(256, Art_u -Int ABI_dart))
       andBool ((#rangeUInt(256, Art_v +Int ABI_dart))
       andBool ((#rangeUInt(256, (Ink_u -Int ABI_dink) *Int Spot))
       andBool ((#rangeUInt(256, (Ink_v +Int ABI_dink) *Int Spot))))))))))))))))))))))))))))))))))))))))

       andBool #lookup(ACCT_ID_STORAGE, #Vat.can[ABI_src][CALLER_ID]) ==Int Can_src
       andBool #lookup(ACCT_ID_STORAGE, #Vat.can[ABI_dst][CALLER_ID]) ==Int Can_dst
       andBool #lookup(ACCT_ID_STORAGE, #Vat.ilks[ABI_ilk].rate) ==Int Rate
       andBool #lookup(ACCT_ID_STORAGE, #Vat.ilks[ABI_ilk].spot) ==Int Spot
       andBool #lookup(ACCT_ID_STORAGE, #Vat.ilks[ABI_ilk].dust) ==Int Dust
       andBool #lookup(ACCT_ID_STORAGE, #Vat.urns[ABI_ilk][ABI_src].ink) ==Int Ink_u
       andBool #lookup(ACCT_ID_STORAGE, #Vat.urns[ABI_ilk][ABI_src].art) ==Int Art_u
       andBool #lookup(ACCT_ID_STORAGE, #Vat.urns[ABI_ilk][ABI_dst].ink) ==Int Ink_v
       andBool #lookup(ACCT_ID_STORAGE, #Vat.urns[ABI_ilk][ABI_dst].art) ==Int Art_v
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.can[ABI_src][CALLER_ID]) ==Int Junk_0
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.can[ABI_dst][CALLER_ID]) ==Int Junk_1
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.ilks[ABI_ilk].rate) ==Int Junk_2
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.ilks[ABI_ilk].spot) ==Int Junk_3
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.ilks[ABI_ilk].dust) ==Int Junk_4
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.urns[ABI_ilk][ABI_src].ink) ==Int Junk_5
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.urns[ABI_ilk][ABI_src].art) ==Int Junk_6
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.urns[ABI_ilk][ABI_dst].ink) ==Int Junk_7
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.urns[ABI_ilk][ABI_dst].art) ==Int Junk_8
       andBool #Vat.can[ABI_src][CALLER_ID] =/=Int #Vat.can[ABI_dst][CALLER_ID]
       andBool #Vat.can[ABI_src][CALLER_ID] =/=Int #Vat.ilks[ABI_ilk].rate
       andBool #Vat.can[ABI_src][CALLER_ID] =/=Int #Vat.ilks[ABI_ilk].spot
       andBool #Vat.can[ABI_src][CALLER_ID] =/=Int #Vat.ilks[ABI_ilk].dust
       andBool #Vat.can[ABI_src][CALLER_ID] =/=Int #Vat.urns[ABI_ilk][ABI_src].ink
       andBool #Vat.can[ABI_src][CALLER_ID] =/=Int #Vat.urns[ABI_ilk][ABI_src].art
       andBool #Vat.can[ABI_src][CALLER_ID] =/=Int #Vat.urns[ABI_ilk][ABI_dst].ink
       andBool #Vat.can[ABI_src][CALLER_ID] =/=Int #Vat.urns[ABI_ilk][ABI_dst].art
       andBool #Vat.can[ABI_dst][CALLER_ID] =/=Int #Vat.ilks[ABI_ilk].rate
       andBool #Vat.can[ABI_dst][CALLER_ID] =/=Int #Vat.ilks[ABI_ilk].spot
       andBool #Vat.can[ABI_dst][CALLER_ID] =/=Int #Vat.ilks[ABI_ilk].dust
       andBool #Vat.can[ABI_dst][CALLER_ID] =/=Int #Vat.urns[ABI_ilk][ABI_src].ink
       andBool #Vat.can[ABI_dst][CALLER_ID] =/=Int #Vat.urns[ABI_ilk][ABI_src].art
       andBool #Vat.can[ABI_dst][CALLER_ID] =/=Int #Vat.urns[ABI_ilk][ABI_dst].ink
       andBool #Vat.can[ABI_dst][CALLER_ID] =/=Int #Vat.urns[ABI_ilk][ABI_dst].art
       andBool #Vat.ilks[ABI_ilk].rate =/=Int #Vat.ilks[ABI_ilk].spot
       andBool #Vat.ilks[ABI_ilk].rate =/=Int #Vat.ilks[ABI_ilk].dust
       andBool #Vat.ilks[ABI_ilk].rate =/=Int #Vat.urns[ABI_ilk][ABI_src].ink
       andBool #Vat.ilks[ABI_ilk].rate =/=Int #Vat.urns[ABI_ilk][ABI_src].art
       andBool #Vat.ilks[ABI_ilk].rate =/=Int #Vat.urns[ABI_ilk][ABI_dst].ink
       andBool #Vat.ilks[ABI_ilk].rate =/=Int #Vat.urns[ABI_ilk][ABI_dst].art
       andBool #Vat.ilks[ABI_ilk].spot =/=Int #Vat.ilks[ABI_ilk].dust
       andBool #Vat.ilks[ABI_ilk].spot =/=Int #Vat.urns[ABI_ilk][ABI_src].ink
       andBool #Vat.ilks[ABI_ilk].spot =/=Int #Vat.urns[ABI_ilk][ABI_src].art
       andBool #Vat.ilks[ABI_ilk].spot =/=Int #Vat.urns[ABI_ilk][ABI_dst].ink
       andBool #Vat.ilks[ABI_ilk].spot =/=Int #Vat.urns[ABI_ilk][ABI_dst].art
       andBool #Vat.ilks[ABI_ilk].dust =/=Int #Vat.urns[ABI_ilk][ABI_src].ink
       andBool #Vat.ilks[ABI_ilk].dust =/=Int #Vat.urns[ABI_ilk][ABI_src].art
       andBool #Vat.ilks[ABI_ilk].dust =/=Int #Vat.urns[ABI_ilk][ABI_dst].ink
       andBool #Vat.ilks[ABI_ilk].dust =/=Int #Vat.urns[ABI_ilk][ABI_dst].art
       andBool #Vat.urns[ABI_ilk][ABI_src].ink =/=Int #Vat.urns[ABI_ilk][ABI_src].art
       andBool #Vat.urns[ABI_ilk][ABI_src].ink =/=Int #Vat.urns[ABI_ilk][ABI_dst].ink
       andBool #Vat.urns[ABI_ilk][ABI_src].ink =/=Int #Vat.urns[ABI_ilk][ABI_dst].art
       andBool #Vat.urns[ABI_ilk][ABI_src].art =/=Int #Vat.urns[ABI_ilk][ABI_dst].ink
       andBool #Vat.urns[ABI_ilk][ABI_src].art =/=Int #Vat.urns[ABI_ilk][ABI_dst].art
       andBool #Vat.urns[ABI_ilk][ABI_dst].ink =/=Int #Vat.urns[ABI_ilk][ABI_dst].art

    // Vat_addui
    claim [Vat.addui.pass]:
      <k> #execute ~> CONTINUATION => #execute ~> CONTINUATION </k>
      <exit-code> 1 </exit-code>
      <mode> NORMAL </mode>
      <schedule> ISTANBUL </schedule>
      <ethereum>
        <evm>
          <output> VOutput => VOutput </output>
          <statusCode> _ => ?_ </statusCode>
          <endPC> _ => ?_ </endPC>
          <callStack> _VCallStack </callStack>
          <interimStates> _ </interimStates>
          <touchedAccounts> _ => ?_ </touchedAccounts>
          <callState>
            <program> Vat_bin_runtime </program>
            <jumpDests> #computeValidJumpDests(Vat_bin_runtime) </jumpDests>
            <id> ACCT_ID </id>
            <caller> CALLER_ID </caller>
            <callData> _ => ?_ </callData>
            <callValue> VCallValue </callValue>
            <wordStack> chop(ABI_y) : ABI_x : JMPTO : WS  =>  JMPTO : ABI_x +Int ABI_y : WS </wordStack>
            <localMem> _ </localMem>
            <pc> 13112 => 13174 </pc>
            <gas> #gas(VGas) => #if ( ABI_y <Int 0 andBool 0 <=Int ( ABI_x +Int ABI_y ) )
              #then   #gas ( ( VGas +Int -128 ) )
              #else   #if chop( ABI_y ) <=Int 0
                #then   #gas ( ( VGas +Int -114 ) )
                #else   #gas ( ( VGas +Int -128 ) )
              #fi
            #fi </gas>
            <memoryUsed> VMemoryUsed </memoryUsed>
            <callGas> _ => ?_ </callGas>
            <static> _ </static>
            <callDepth> VCallDepth </callDepth>
          </callState>
          <substate>
            <selfDestruct> _VSelfDestruct </selfDestruct>
            <log> _ => ?_ </log>
            <refund> _Vrefund => ?_ </refund>
            <accessedAccounts> _ => ?_ </accessedAccounts>
            <accessedStorage> _ => ?_ </accessedStorage>
          </substate>
          <gasPrice> _ </gasPrice>
          <origin> ORIGIN_ID </origin>
          <blockhashes> _ </blockhashes>
          <block>
            <previousHash> _ </previousHash>
            <ommersHash> _ </ommersHash>
            <coinbase> _ </coinbase>
            <stateRoot> _ </stateRoot>
            <transactionsRoot> _ </transactionsRoot>
            <receiptsRoot> _ </receiptsRoot>
            <logsBloom> _ </logsBloom>
            <difficulty> _ </difficulty>
            <number> _BLOCK_NUMBER </number>
            <gasLimit> _ </gasLimit>
            <gasUsed> _ </gasUsed>
            <timestamp> TIME </timestamp>
            <extraData> _ </extraData>
            <mixHash> _ </mixHash>
            <blockNonce> _ </blockNonce>
            <ommerBlockHeaders> _ </ommerBlockHeaders>
          </block>
        </evm>
        <network>
          <chainID> VChainId </chainID>
          <activeAccounts> SetItem(ACCT_ID)
          SetItem(1)
          SetItem(2)
          SetItem(3)
          SetItem(4)
          SetItem(5)
          SetItem(6)
          SetItem(7)
          SetItem(8)
          SetItem(9) _ </activeAccounts>
          <accounts>
            <account>
              <acctID> ACCT_ID </acctID>
              <balance> ACCT_ID_balance </balance>
              <code> Vat_bin_runtime </code>
              <storage> ACCT_ID_STORAGE => ACCT_ID_STORAGE  </storage>
              <origStorage> ACCT_ID_ORIG_STORAGE </origStorage>
              <nonce> _Nonce_Vat => ?_ </nonce>
            </account>
            <account>
              <acctID> 1 </acctID>
              <balance> ECREC_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 2 </acctID>
              <balance> SHA256_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 3 </acctID>
              <balance> RIP160_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 4 </acctID>
              <balance> ID_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 5 </acctID>
              <balance> MODEXP_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 6 </acctID>
              <balance> ECADD_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 7 </acctID>
              <balance> ECMUL_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 8 </acctID>
              <balance> ECPAIRING_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 9 </acctID>
              <balance> BLAKE2_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
           ...
          </accounts>
          <txOrder> _ </txOrder>
          <txPending> _ </txPending>
          <messages> _ </messages>
        </network>
      </ethereum>
      requires #rangeAddress(ACCT_ID)
       andBool ACCT_ID =/=Int 0
       andBool #notPrecompileAddress(ACCT_ID)
       andBool #rangeAddress(CALLER_ID)
       andBool #rangeAddress(ORIGIN_ID)
       andBool #rangeUInt(256, TIME)
       andBool #rangeUInt(256, ACCT_ID_balance)
       andBool #rangeUInt(256, ECREC_BAL)
       andBool #rangeUInt(256, SHA256_BAL)
       andBool #rangeUInt(256, RIP160_BAL)
       andBool #rangeUInt(256, ID_BAL)
       andBool #rangeUInt(256, MODEXP_BAL)
       andBool #rangeUInt(256, ECADD_BAL)
       andBool #rangeUInt(256, ECMUL_BAL)
       andBool #rangeUInt(256, ECPAIRING_BAL)
       andBool #rangeUInt(256, BLAKE2_BAL)
       andBool VCallDepth <=Int 1024
       andBool #rangeUInt(256, VCallValue)
       andBool #rangeUInt(256, VChainId)

       andBool (#rangeUInt(256, ABI_x)
       andBool (#rangeSInt(256, ABI_y)
       andBool ((#sizeWordStack(WS) <=Int 1015)
       andBool (#rangeUInt(256, VMemoryUsed)
       andBool ((#rangeUInt(256, ABI_x +Int ABI_y)))))))


    [trusted, matching(infGas)]


    // Vat_subui
    claim [Vat.subui.pass]:
      <k> #execute ~> CONTINUATION => #execute ~> CONTINUATION </k>
      <exit-code> 1 </exit-code>
      <mode> NORMAL </mode>
      <schedule> ISTANBUL </schedule>
      <ethereum>
        <evm>
          <output> VOutput => VOutput </output>
          <statusCode> _ => ?_ </statusCode>
          <endPC> _ => ?_ </endPC>
          <callStack> _VCallStack </callStack>
          <interimStates> _ </interimStates>
          <touchedAccounts> _ => ?_ </touchedAccounts>
          <callState>
            <program> Vat_bin_runtime </program>
            <jumpDests> #computeValidJumpDests(Vat_bin_runtime) </jumpDests>
            <id> ACCT_ID </id>
            <caller> CALLER_ID </caller>
            <callData> _ => ?_ </callData>
            <callValue> VCallValue </callValue>
            <wordStack> chop(ABI_y) : ABI_x : JMPTO : WS  =>  JMPTO : ABI_x -Int ABI_y : WS </wordStack>
            <localMem> _ </localMem>
            <pc> 13304 => 13366 </pc>
            <gas> #gas(VGas) => #if ( ABI_y =/=Int 0 andBool 0 <=Int ABI_y )
              #then   #gas ( ( VGas +Int -128 ) )
              #else   #if 0 <=Int ABI_y
                #then   #gas ( ( VGas +Int -114 ) )
                #else   #gas ( ( VGas +Int -128 ) )
              #fi
            #fi </gas>
            <memoryUsed> VMemoryUsed </memoryUsed>
            <callGas> _ => ?_ </callGas>
            <static> _ </static>
            <callDepth> VCallDepth </callDepth>
          </callState>
          <substate>
            <selfDestruct> _VSelfDestruct </selfDestruct>
            <log> _ => ?_ </log>
            <refund> _Vrefund => ?_ </refund>
            <accessedAccounts> _ => ?_ </accessedAccounts>
            <accessedStorage> _ => ?_ </accessedStorage>
          </substate>
          <gasPrice> _ </gasPrice>
          <origin> ORIGIN_ID </origin>
          <blockhashes> _ </blockhashes>
          <block>
            <previousHash> _ </previousHash>
            <ommersHash> _ </ommersHash>
            <coinbase> _ </coinbase>
            <stateRoot> _ </stateRoot>
            <transactionsRoot> _ </transactionsRoot>
            <receiptsRoot> _ </receiptsRoot>
            <logsBloom> _ </logsBloom>
            <difficulty> _ </difficulty>
            <number> _BLOCK_NUMBER </number>
            <gasLimit> _ </gasLimit>
            <gasUsed> _ </gasUsed>
            <timestamp> TIME </timestamp>
            <extraData> _ </extraData>
            <mixHash> _ </mixHash>
            <blockNonce> _ </blockNonce>
            <ommerBlockHeaders> _ </ommerBlockHeaders>
          </block>
        </evm>
        <network>
          <chainID> VChainId </chainID>
          <activeAccounts> SetItem(ACCT_ID)
          SetItem(1)
          SetItem(2)
          SetItem(3)
          SetItem(4)
          SetItem(5)
          SetItem(6)
          SetItem(7)
          SetItem(8)
          SetItem(9) _ </activeAccounts>
          <accounts>
            <account>
              <acctID> ACCT_ID </acctID>
              <balance> ACCT_ID_balance </balance>
              <code> Vat_bin_runtime </code>
              <storage> ACCT_ID_STORAGE => ACCT_ID_STORAGE  </storage>
              <origStorage> ACCT_ID_ORIG_STORAGE </origStorage>
              <nonce> _Nonce_Vat => ?_ </nonce>
            </account>
            <account>
              <acctID> 1 </acctID>
              <balance> ECREC_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 2 </acctID>
              <balance> SHA256_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 3 </acctID>
              <balance> RIP160_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 4 </acctID>
              <balance> ID_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 5 </acctID>
              <balance> MODEXP_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 6 </acctID>
              <balance> ECADD_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 7 </acctID>
              <balance> ECMUL_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 8 </acctID>
              <balance> ECPAIRING_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 9 </acctID>
              <balance> BLAKE2_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
           ...
          </accounts>
          <txOrder> _ </txOrder>
          <txPending> _ </txPending>
          <messages> _ </messages>
        </network>
      </ethereum>
      requires #rangeAddress(ACCT_ID)
       andBool ACCT_ID =/=Int 0
       andBool #notPrecompileAddress(ACCT_ID)
       andBool #rangeAddress(CALLER_ID)
       andBool #rangeAddress(ORIGIN_ID)
       andBool #rangeUInt(256, TIME)
       andBool #rangeUInt(256, ACCT_ID_balance)
       andBool #rangeUInt(256, ECREC_BAL)
       andBool #rangeUInt(256, SHA256_BAL)
       andBool #rangeUInt(256, RIP160_BAL)
       andBool #rangeUInt(256, ID_BAL)
       andBool #rangeUInt(256, MODEXP_BAL)
       andBool #rangeUInt(256, ECADD_BAL)
       andBool #rangeUInt(256, ECMUL_BAL)
       andBool #rangeUInt(256, ECPAIRING_BAL)
       andBool #rangeUInt(256, BLAKE2_BAL)
       andBool VCallDepth <=Int 1024
       andBool #rangeUInt(256, VCallValue)
       andBool #rangeUInt(256, VChainId)

       andBool (#rangeUInt(256, ABI_x)
       andBool (#rangeSInt(256, ABI_y)
       andBool ((#sizeWordStack(WS) <=Int 1015)
       andBool (#rangeUInt(256, VMemoryUsed)
       andBool ((#rangeUInt(256, ABI_x -Int ABI_y)))))))


    [trusted, matching(infGas)]


    // Vat_muluu
    claim [Vat.muluu.pass]:
      <k> #execute ~> CONTINUATION => #execute ~> CONTINUATION </k>
      <exit-code> 1 </exit-code>
      <mode> NORMAL </mode>
      <schedule> ISTANBUL </schedule>
      <ethereum>
        <evm>
          <output> VOutput => VOutput </output>
          <statusCode> _ => ?_ </statusCode>
          <endPC> _ => ?_ </endPC>
          <callStack> _VCallStack </callStack>
          <interimStates> _ </interimStates>
          <touchedAccounts> _ => ?_ </touchedAccounts>
          <callState>
            <program> Vat_bin_runtime </program>
            <jumpDests> #computeValidJumpDests(Vat_bin_runtime) </jumpDests>
            <id> ACCT_ID </id>
            <caller> CALLER_ID </caller>
            <callData> _ => ?_ </callData>
            <callValue> VCallValue </callValue>
            <wordStack> ABI_y : ABI_x : JMPTO : WS  =>  JMPTO : ABI_x *Int ABI_y : WS </wordStack>
            <localMem> _ </localMem>
            <pc> 13234 => 13277 </pc>
            <gas> #gas(VGas) => #if ABI_y ==Int 0
              #then   #gas ( ( VGas +Int -54 ) )
              #else   #gas ( ( VGas +Int -106 ) )
            #fi </gas>
            <memoryUsed> VMemoryUsed </memoryUsed>
            <callGas> _ => ?_ </callGas>
            <static> _ </static>
            <callDepth> VCallDepth </callDepth>
          </callState>
          <substate>
            <selfDestruct> _VSelfDestruct </selfDestruct>
            <log> _ => ?_ </log>
            <refund> _Vrefund => ?_ </refund>
            <accessedAccounts> _ => ?_ </accessedAccounts>
            <accessedStorage> _ => ?_ </accessedStorage>
          </substate>
          <gasPrice> _ </gasPrice>
          <origin> ORIGIN_ID </origin>
          <blockhashes> _ </blockhashes>
          <block>
            <previousHash> _ </previousHash>
            <ommersHash> _ </ommersHash>
            <coinbase> _ </coinbase>
            <stateRoot> _ </stateRoot>
            <transactionsRoot> _ </transactionsRoot>
            <receiptsRoot> _ </receiptsRoot>
            <logsBloom> _ </logsBloom>
            <difficulty> _ </difficulty>
            <number> _BLOCK_NUMBER </number>
            <gasLimit> _ </gasLimit>
            <gasUsed> _ </gasUsed>
            <timestamp> TIME </timestamp>
            <extraData> _ </extraData>
            <mixHash> _ </mixHash>
            <blockNonce> _ </blockNonce>
            <ommerBlockHeaders> _ </ommerBlockHeaders>
          </block>
        </evm>
        <network>
          <chainID> VChainId </chainID>
          <activeAccounts> SetItem(ACCT_ID)
          SetItem(1)
          SetItem(2)
          SetItem(3)
          SetItem(4)
          SetItem(5)
          SetItem(6)
          SetItem(7)
          SetItem(8)
          SetItem(9) _ </activeAccounts>
          <accounts>
            <account>
              <acctID> ACCT_ID </acctID>
              <balance> ACCT_ID_balance </balance>
              <code> Vat_bin_runtime </code>
              <storage> ACCT_ID_STORAGE => ACCT_ID_STORAGE  </storage>
              <origStorage> ACCT_ID_ORIG_STORAGE </origStorage>
              <nonce> _Nonce_Vat => ?_ </nonce>
            </account>
            <account>
              <acctID> 1 </acctID>
              <balance> ECREC_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 2 </acctID>
              <balance> SHA256_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 3 </acctID>
              <balance> RIP160_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 4 </acctID>
              <balance> ID_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 5 </acctID>
              <balance> MODEXP_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 6 </acctID>
              <balance> ECADD_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 7 </acctID>
              <balance> ECMUL_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 8 </acctID>
              <balance> ECPAIRING_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
            <account>
              <acctID> 9 </acctID>
              <balance> BLAKE2_BAL </balance>
              <code> .ByteArray </code>
              <storage> _:Map </storage>
              <origStorage> _ </origStorage>
              <nonce> _ </nonce>
            </account>
           ...
          </accounts>
          <txOrder> _ </txOrder>
          <txPending> _ </txPending>
          <messages> _ </messages>
        </network>
      </ethereum>
      requires #rangeAddress(ACCT_ID)
       andBool ACCT_ID =/=Int 0
       andBool #notPrecompileAddress(ACCT_ID)
       andBool #rangeAddress(CALLER_ID)
       andBool #rangeAddress(ORIGIN_ID)
       andBool #rangeUInt(256, TIME)
       andBool #rangeUInt(256, ACCT_ID_balance)
       andBool #rangeUInt(256, ECREC_BAL)
       andBool #rangeUInt(256, SHA256_BAL)
       andBool #rangeUInt(256, RIP160_BAL)
       andBool #rangeUInt(256, ID_BAL)
       andBool #rangeUInt(256, MODEXP_BAL)
       andBool #rangeUInt(256, ECADD_BAL)
       andBool #rangeUInt(256, ECMUL_BAL)
       andBool #rangeUInt(256, ECPAIRING_BAL)
       andBool #rangeUInt(256, BLAKE2_BAL)
       andBool VCallDepth <=Int 1024
       andBool #rangeUInt(256, VCallValue)
       andBool #rangeUInt(256, VChainId)

       andBool (#rangeUInt(256, ABI_x)
       andBool (#rangeUInt(256, ABI_y)
       andBool ((#sizeWordStack(WS) <=Int 1000)
       andBool (#rangeUInt(256, VMemoryUsed)
       andBool ((#rangeUInt(256, ABI_x *Int ABI_y)))))))


    [trusted, matching(infGas)]


endmodule
