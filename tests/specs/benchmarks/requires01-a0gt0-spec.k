requires "verification.k"

module REQUIRES01-A0GT0-SPEC
  imports VERIFICATION

  // fn-execute-a0gt0
  claim
    <k> (#execute => #halt) ~> _ </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> ISTANBUL </schedule>
    <ethereum>
      <evm>
        <output> _ => #encodeArgs(#uint256(5)) </output>
        <statusCode> _ => EVMC_SUCCESS </statusCode>
        <endPC> _ => ?_ </endPC>
        <callStack> _ </callStack>
        <interimStates> _ </interimStates>
        <touchedAccounts> _ => ?_ </touchedAccounts>
        <callState>
          <program> #parseByteStack("0x608060405260043610603f576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063fe0d94c1146044575b600080fd5b348015604f57600080fd5b50606c6004803603810190808035906020019092919050505060ae565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b6000808211151560bd57600080fd5b600590509190505600a165627a7a72305820885b6ddc678a06d1bd68f28d6a516e4fb72fb2d325ac780ffc7605ac95a408390029") </program>
          <jumpDests> #computeValidJumpDests(#parseByteStack("0x608060405260043610603f576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063fe0d94c1146044575b600080fd5b348015604f57600080fd5b50606c6004803603810190808035906020019092919050505060ae565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b6000808211151560bd57600080fd5b600590509190505600a165627a7a72305820885b6ddc678a06d1bd68f28d6a516e4fb72fb2d325ac780ffc7605ac95a408390029")) </jumpDests>
          <id> CONTRACT_ID </id> // this
          <caller> MSG_SENDER </caller> // msg.sender
          <callData> #abiCallData("execute", #uint256(A0)) </callData> // msg.data
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
            <code> #parseByteStack("0x608060405260043610603f576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063fe0d94c1146044575b600080fd5b348015604f57600080fd5b50606c6004803603810190808035906020019092919050505060ae565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b6000808211151560bd57600080fd5b600590509190505600a165627a7a72305820885b6ddc678a06d1bd68f28d6a516e4fb72fb2d325ac780ffc7605ac95a408390029") </code>
            <storage> _S </storage>
            <origStorage> _OS </origStorage>
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
     andBool A0 >Int 0

endmodule

