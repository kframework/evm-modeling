requires "verification.k"

module ENCODE-KECCAK00-SPEC
  imports VERIFICATION

  // fn-execute
  claim
    <k> (#execute => #halt) ~> _ </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> ISTANBUL </schedule>
    <ethereum>
      <evm>
        <output> _ => #encodeArgs(#bytes32(keccak(#encodeArgs(#bytes32(A0), #bytes32(A1))))) </output>
        <statusCode> _ => EVMC_SUCCESS </statusCode>
        <endPC> _ => ?_ </endPC>
        <callStack> _ </callStack>
        <interimStates> _ </interimStates>
        <touchedAccounts> _ => ?_ </touchedAccounts>
        <callState>
          <program> #parseByteStack("0x608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063b94ccd6c14610046575b600080fd5b34801561005257600080fd5b50610083600480360381019080803560001916906020019092919080356000191690602001909291905050506100a1565b60405180826000191660001916815260200191505060405180910390f35b600082826040516020018083600019166000191681526020018260001916600019168152602001925050506040516020818303038152906040526040518082805190602001908083835b60208310151561011057805182526020820191506020810190506020830392506100eb565b6001836020036101000a03801982511681845116808217855250505050505090500191505060405180910390209050929150505600a165627a7a723058204b66bf85bf879ad4b61d351300c14b3cdc5242a222464edc4d16b1d1cec329f60029") </program>
          <jumpDests> #computeValidJumpDests(#parseByteStack("0x608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063b94ccd6c14610046575b600080fd5b34801561005257600080fd5b50610083600480360381019080803560001916906020019092919080356000191690602001909291905050506100a1565b60405180826000191660001916815260200191505060405180910390f35b600082826040516020018083600019166000191681526020018260001916600019168152602001925050506040516020818303038152906040526040518082805190602001908083835b60208310151561011057805182526020820191506020810190506020830392506100eb565b6001836020036101000a03801982511681845116808217855250505050505090500191505060405180910390209050929150505600a165627a7a723058204b66bf85bf879ad4b61d351300c14b3cdc5242a222464edc4d16b1d1cec329f60029")) </jumpDests>
          <id> CONTRACT_ID </id> // this
          <caller> MSG_SENDER </caller> // msg.sender
          <callData> #abiCallData("execute", #bytes32(A0), #bytes32(A1)) </callData> // msg.data
          <callValue> 0 </callValue> // msg.value
          <wordStack> .WordStack => ?_ </wordStack>
          <localMem> .Memory => ?_ </localMem>
          <pc> 0 => ?_ </pc>
          <gas> #gas(_INITGAS, 0, 0) => ?_ </gas>
          <memoryUsed> 0 => ?_ </memoryUsed>
          <callGas> _ => ?_ </callGas>
          <static> false </static> // NOTE: non-static call
          <callDepth> CD </callDepth>
        </callState>
        <substate>
          <selfDestruct> _ </selfDestruct>
          <log> _ </log>
          <refund> _ </refund>
          <accessedAccounts> _ => ?_ </accessedAccounts>
          <accessedStorage> _ => ?_ </accessedStorage>
        </substate>
        <gasPrice> _ </gasPrice>
        <origin> _ </origin> // tx.origin
        <blockhashes> _BLOCK_HASHES </blockhashes> // block.blockhash
        <block>
          <previousHash> _ </previousHash>
          <ommersHash> _ </ommersHash>
          <coinbase> _ </coinbase> // block.coinbase
          <stateRoot> _ </stateRoot>
          <transactionsRoot> _ </transactionsRoot>
          <receiptsRoot> _ </receiptsRoot>
          <logsBloom> _ </logsBloom>
          <difficulty> _ </difficulty>
          <number> BLOCK_NUM </number> // block.number
          <gasLimit> _ </gasLimit>
          <gasUsed> _ </gasUsed>
          <timestamp> NOW </timestamp> // now = block.timestamp
          <extraData> _ </extraData>
          <mixHash> _ </mixHash>
          <blockNonce> _ </blockNonce>
          <ommerBlockHeaders> _ </ommerBlockHeaders>
        </block>
      </evm>
      <network>
        <chainID> _ </chainID>

        <activeAccounts> SetItem(CONTRACT_ID) SetItem(CALLEE_ID) SetItem(1) _:Set </activeAccounts>
        <accounts>
          <account>
            <acctID> CONTRACT_ID </acctID>
            <balance> CONTRACT_BAL </balance>
            <code> #parseByteStack("0x608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063b94ccd6c14610046575b600080fd5b34801561005257600080fd5b50610083600480360381019080803560001916906020019092919080356000191690602001909291905050506100a1565b60405180826000191660001916815260200191505060405180910390f35b600082826040516020018083600019166000191681526020018260001916600019168152602001925050506040516020818303038152906040526040518082805190602001908083835b60208310151561011057805182526020820191506020810190506020830392506100eb565b6001836020036101000a03801982511681845116808217855250505050505090500191505060405180910390209050929150505600a165627a7a723058204b66bf85bf879ad4b61d351300c14b3cdc5242a222464edc4d16b1d1cec329f60029") </code>
            <storage>
_
            </storage>
            <origStorage>
_
            </origStorage>
            <nonce> _ </nonce>
          </account>

          <account>
            <acctID> CALLEE_ID </acctID>
            <balance> CALLEE_BAL </balance>
            <code> _ </code>
            <storage>
                _
            </storage>
            <origStorage>
                _
            </origStorage>
            <nonce> _ </nonce>
          </account>

          <account>
            // precompiled account for ECCREC
            <acctID> 1 </acctID>
            <balance> 0 </balance>
            <code> .ByteArray </code>
            <storage> .Map </storage>
            <origStorage> .Map </origStorage>
            <nonce> 0 </nonce>
          </account>


          ...
        </accounts>
        <txOrder> _ </txOrder>
        <txPending> _ </txPending>
        <messages> _ </messages>
      </network>
    </ethereum>
    requires #rangeAddress(CONTRACT_ID)
     andBool #rangeAddress(CALLEE_ID)
     andBool #rangeUInt(256, NOW)
     andBool #rangeUInt(128, BLOCK_NUM) // Solidity

     // Account address normality
     andBool CONTRACT_ID >Int 0 andBool (notBool #isPrecompiledAccount(CONTRACT_ID, BYZANTIUM))
     andBool CALLEE_ID   >Int 0 andBool (notBool #isPrecompiledAccount(CALLEE_ID  , BYZANTIUM))

     andBool #rangeUInt(256, CONTRACT_BAL)
     andBool #rangeUInt(256, CALLEE_BAL)
     andBool #range(0 <= CD < 1024)
     andBool #rangeAddress(MSG_SENDER)
     andBool #rangeUInt(256, A0)
     andBool #rangeUInt(256, A1)

endmodule

