requires "verification.k"

module ECRECOVER00-SIGVALID-SPEC
  imports VERIFICATION

  // fn-execute-sigvalid
  claim
    <k> (#execute => #halt) ~> _ </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> ISTANBUL </schedule>
    <ethereum>
      <evm>
        <output> _ => #encodeArgs(#address(RECOVERED)) </output>
        <statusCode> _ => EVMC_SUCCESS </statusCode>
        <endPC> _ => ?_ </endPC>
        <callStack> _ </callStack>
        <interimStates> _ </interimStates>
        <touchedAccounts> _ => ?_ </touchedAccounts>
        <callState>
          <program> #parseByteStack("0x608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680634480949514610046575b600080fd5b34801561005257600080fd5b506100a06004803603608081101561006957600080fd5b8101908080359060200190929190803560ff16906020019092919080359060200190929190803590602001909291905050506100e2565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b60008060018686868660405160008152602001604052604051808581526020018460ff1660ff1681526020018381526020018281526020019450505050506020604051602081039080840390855afa158015610142573d6000803e3d6000fd5b505050602060405103519050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1611151561018957600080fd5b8091505094935050505056fea165627a7a72305820ec9368f63b82a680b2493003123eec414f661d1259fdf9d0082a8815d68a9a7e0029") </program>
          <jumpDests> #computeValidJumpDests(#parseByteStack("0x608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680634480949514610046575b600080fd5b34801561005257600080fd5b506100a06004803603608081101561006957600080fd5b8101908080359060200190929190803560ff16906020019092919080359060200190929190803590602001909291905050506100e2565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b60008060018686868660405160008152602001604052604051808581526020018460ff1660ff1681526020018381526020018281526020019450505050506020604051602081039080840390855afa158015610142573d6000803e3d6000fd5b505050602060405103519050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1611151561018957600080fd5b8091505094935050505056fea165627a7a72305820ec9368f63b82a680b2493003123eec414f661d1259fdf9d0082a8815d68a9a7e0029")) </jumpDests>
          <id> CONTRACT_ID </id> // this
          <caller> MSG_SENDER </caller> // msg.sender
          <callData> #abiCallData("execute", #bytes32(HASH), #uint8(SIGV), #bytes32(SIGR), #bytes32(SIGS)) </callData> // msg.data
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
            <code> #parseByteStack("0x608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680634480949514610046575b600080fd5b34801561005257600080fd5b506100a06004803603608081101561006957600080fd5b8101908080359060200190929190803560ff16906020019092919080359060200190929190803590602001909291905050506100e2565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b60008060018686868660405160008152602001604052604051808581526020018460ff1660ff1681526020018381526020018281526020019450505050506020604051602081039080840390855afa158015610142573d6000803e3d6000fd5b505050602060405103519050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1611151561018957600080fd5b8091505094935050505056fea165627a7a72305820ec9368f63b82a680b2493003123eec414f661d1259fdf9d0082a8815d68a9a7e0029") </code>
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
     andBool #rangeUInt(256, HASH)
     andBool #rangeUInt(8, SIGV)
     andBool #rangeBytes(32, SIGR)
     andBool #rangeBytes(32, SIGS)
     andBool ECREC_DATA ==K #encodeArgs( #bytes32(HASH), #uint8(SIGV), #bytes32(SIGR), #bytes32(SIGS) )
     andBool RECOVERED ==Int #symEcrec( ECREC_DATA )
     andBool notBool #ecrecEmpty( ECREC_DATA )

endmodule

