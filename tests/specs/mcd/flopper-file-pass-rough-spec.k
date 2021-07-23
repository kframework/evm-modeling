requires "verification.k"

module FLOPPER-FILE-PASS-ROUGH-SPEC
    imports VERIFICATION

    // Flopper_file
    claim [Flopper.file.pass.rough]:
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
            <program> Flopper_bin_runtime </program>
            <jumpDests> #computeValidJumpDests(Flopper_bin_runtime) </jumpDests>
            <id> ACCT_ID </id>
            <caller> CALLER_ID </caller>
            <callData> #abiCallData("file", #bytes32(ABI_what), #uint256(ABI_data)) ++ CD => ?_ </callData>
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
              <code> Flopper_bin_runtime </code>
              <storage> ACCT_ID_STORAGE => ACCT_ID_STORAGE [ #Flopper.beg <- (#if ABI_what ==Int #string2Word("beg") #then ABI_data #else Beg #fi) ] [ #Flopper.pad <- (#if ABI_what ==Int #string2Word("pad") #then ABI_data #else Pad #fi) ] [ #Flopper.ttl_tau <- (#if ABI_what ==Int #string2Word("ttl") #then #WordPackUInt48UInt48(ABI_data, Tau) #else (#if ABI_what ==Int #string2Word("tau") #then #WordPackUInt48UInt48(Ttl, ABI_data) #else #WordPackUInt48UInt48(Ttl, Tau) #fi) #fi) ] </storage>
              <origStorage> ACCT_ID_ORIG_STORAGE </origStorage>
              <nonce> _Nonce_Flopper => ?_ </nonce>
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

       andBool (#rangeBytes(32, ABI_what)
       andBool (#rangeUInt(256, ABI_data)
       andBool (#rangeUInt(256, May)
       andBool (#rangeUInt(256, Beg)
       andBool (#rangeUInt(256, Pad)
       andBool (#rangeUInt(48, Ttl)
       andBool (#rangeUInt(48, Tau)
       andBool ((#sizeByteArray(CD) <=Int 1250000000)
       andBool (((ABI_what =/=Int #string2Word("ttl") andBool ABI_what =/=Int #string2Word("tau")) orBool #rangeUInt(48, ABI_data))
       andBool (#rangeUInt(256, Junk_0)
       andBool (#rangeUInt(256, Junk_1)
       andBool (#rangeUInt(256, Junk_2)
       andBool (#rangeUInt(256, Junk_3)
       andBool ((May ==Int 1)
       andBool ((VCallValue ==Int 0)
       andBool (((ABI_what ==Int #string2Word("beg")) orBool (ABI_what ==Int #string2Word("pad")) orBool (ABI_what ==Int #string2Word("ttl")) orBool (ABI_what ==Int #string2Word("tau")))))))))))))))))))

       andBool #lookup(ACCT_ID_STORAGE, #Flopper.wards[CALLER_ID]) ==Int May
       andBool #lookup(ACCT_ID_STORAGE, #Flopper.beg) ==Int Beg
       andBool #lookup(ACCT_ID_STORAGE, #Flopper.pad) ==Int Pad
       andBool #lookup(ACCT_ID_STORAGE, #Flopper.ttl_tau) ==Int #WordPackUInt48UInt48(Ttl, Tau)
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Flopper.wards[CALLER_ID]) ==Int Junk_0
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Flopper.beg) ==Int Junk_1
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Flopper.pad) ==Int Junk_2
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Flopper.ttl_tau) ==Int Junk_3
       andBool #Flopper.wards[CALLER_ID] =/=Int #Flopper.beg
       andBool #Flopper.wards[CALLER_ID] =/=Int #Flopper.pad
       andBool #Flopper.wards[CALLER_ID] =/=Int #Flopper.ttl_tau
       andBool #Flopper.beg =/=Int #Flopper.pad
       andBool #Flopper.beg =/=Int #Flopper.ttl_tau
       andBool #Flopper.pad =/=Int #Flopper.ttl_tau

endmodule
