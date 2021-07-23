requires "verification.k"

module ECRECOVERLOOP02-SIGS-VALID-SPEC
  imports VERIFICATION

  // fn-execute-sigs-valid
  claim
    <k> (#execute => #halt) ~> _ </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> ISTANBUL </schedule>
    <ethereum>
      <evm>
        <output> _ => .ByteArray </output>
        <statusCode> _ => EVMC_SUCCESS </statusCode>
        <endPC> _ => ?_ </endPC>
        <callStack> _ </callStack>
        <interimStates> _ </interimStates>
        <touchedAccounts> _ => ?_ </touchedAccounts>
        <callState>
          <program> #parseByteStack("0x608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680633543d4b214610046575b600080fd5b34801561005257600080fd5b506101da600480360361010081101561006a57600080fd5b81019080803590602001909291908035906020019064010000000081111561009157600080fd5b8201836020820111156100a357600080fd5b803590602001918460018302840111640100000000831117156100c557600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050919291929080604001906002806020026040519081016040528092919082600260200280828437600081840152601f19601f820116905080830192505050505050919291929080604001906002806020026040519081016040528092919082600260200280828437600081840152601f19601f820116905080830192505050505050919291929080604001906002806020026040519081016040528092919082600260200280828437600081840152601f19601f82011690508083019250505050505091929192905050506101dc565b005b60008090505b60028110156102d557600060018786846002811015156101fe57fe5b6020020151868560028110151561021157fe5b6020020151868660028110151561022457fe5b602002015160405160008152602001604052604051808581526020018460ff1660ff1681526020018381526020018281526020019450505050506020604051602081039080840390855afa158015610280573d6000803e3d6000fd5b505050602060405103519050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161115156102c757600080fd5b5080806001019150506101e2565b50505050505056fea165627a7a723058200e559ecf0b4ed3978069fd9e401adb4043ef711a33a5926f0e081d7bcdf08bb80029") </program>
          <jumpDests> #computeValidJumpDests(#parseByteStack("0x608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680633543d4b214610046575b600080fd5b34801561005257600080fd5b506101da600480360361010081101561006a57600080fd5b81019080803590602001909291908035906020019064010000000081111561009157600080fd5b8201836020820111156100a357600080fd5b803590602001918460018302840111640100000000831117156100c557600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050919291929080604001906002806020026040519081016040528092919082600260200280828437600081840152601f19601f820116905080830192505050505050919291929080604001906002806020026040519081016040528092919082600260200280828437600081840152601f19601f820116905080830192505050505050919291929080604001906002806020026040519081016040528092919082600260200280828437600081840152601f19601f82011690508083019250505050505091929192905050506101dc565b005b60008090505b60028110156102d557600060018786846002811015156101fe57fe5b6020020151868560028110151561021157fe5b6020020151868660028110151561022457fe5b602002015160405160008152602001604052604051808581526020018460ff1660ff1681526020018381526020018281526020019450505050506020604051602081039080840390855afa158015610280573d6000803e3d6000fd5b505050602060405103519050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161115156102c757600080fd5b5080806001019150506101e2565b50505050505056fea165627a7a723058200e559ecf0b4ed3978069fd9e401adb4043ef711a33a5926f0e081d7bcdf08bb80029")) </jumpDests>
          <id> CONTRACT_ID </id> // this
          <caller> MSG_SENDER </caller> // msg.sender
          <callData> #abiCallData2("execute(bytes32,bytes,uint8[2],bytes32[2],bytes32[2])",
#bytes32(HASH), #bytes(#bufStrict(DATA_LEN,DATA)),
#uint8(SIGV0), #uint8(SIGV1),
#bytes32(SIGR0), #bytes32(SIGR1),
#bytes32(SIGS0), #bytes32(SIGS1)) </callData> // msg.data
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
            <code> #parseByteStack("0x608060405260043610610041576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680633543d4b214610046575b600080fd5b34801561005257600080fd5b506101da600480360361010081101561006a57600080fd5b81019080803590602001909291908035906020019064010000000081111561009157600080fd5b8201836020820111156100a357600080fd5b803590602001918460018302840111640100000000831117156100c557600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050919291929080604001906002806020026040519081016040528092919082600260200280828437600081840152601f19601f820116905080830192505050505050919291929080604001906002806020026040519081016040528092919082600260200280828437600081840152601f19601f820116905080830192505050505050919291929080604001906002806020026040519081016040528092919082600260200280828437600081840152601f19601f82011690508083019250505050505091929192905050506101dc565b005b60008090505b60028110156102d557600060018786846002811015156101fe57fe5b6020020151868560028110151561021157fe5b6020020151868660028110151561022457fe5b602002015160405160008152602001604052604051808581526020018460ff1660ff1681526020018381526020018281526020019450505050506020604051602081039080840390855afa158015610280573d6000803e3d6000fd5b505050602060405103519050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161115156102c757600080fd5b5080806001019150506101e2565b50505050505056fea165627a7a723058200e559ecf0b4ed3978069fd9e401adb4043ef711a33a5926f0e081d7bcdf08bb80029") </code>
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
     andBool #rangeUInt(8, SIGV0)
     andBool #rangeUInt(8, SIGV1)
     andBool #rangeBytes(32, SIGR0)
     andBool #rangeBytes(32, SIGR1)
     andBool #rangeBytes(32, SIGS0)
     andBool #rangeBytes(32, SIGS1)
     andBool #range(0 <= DATA_LEN < pow16)
     andBool #range(0 <= DATA < (2 ^Int (DATA_LEN *Int 8)))
     andBool ECREC_DATA0 ==K #encodeArgs( #bytes32(HASH), #uint8(SIGV0), #bytes32(SIGR0), #bytes32(SIGS0) )
     andBool ECREC_DATA1 ==K #encodeArgs( #bytes32(HASH), #uint8(SIGV1), #bytes32(SIGR1), #bytes32(SIGS1) )
     andBool RECOVERED0 ==Int #symEcrec( ECREC_DATA0 )
     andBool RECOVERED1 ==Int #symEcrec( ECREC_DATA1 )
     andBool notBool #ecrecEmpty( ECREC_DATA0 )
     andBool notBool #ecrecEmpty( ECREC_DATA1 )

endmodule

