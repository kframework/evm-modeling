requires "verification.k"

module VOW-CAGE-DEFICIT-PASS-ROUGH-SPEC
    imports VERIFICATION

    // Vow_cage-deficit
    claim [Vow.cage-deficit.pass.rough]:
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
            <program> Vow_bin_runtime </program>
            <jumpDests> #computeValidJumpDests(Vow_bin_runtime) </jumpDests>
            <id> ACCT_ID </id>
            <caller> CALLER_ID </caller>
            <callData> #abiCallData("cage", .TypedArgs) ++ CD => ?_ </callData>
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
          SetItem(Vat)
          SetItem(Flapper)
          SetItem(Flopper)
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
              <code> Vow_bin_runtime </code>
              <storage> ACCT_ID_STORAGE => ACCT_ID_STORAGE [ #Vow.live <- 0 ] [ #Vow.Sin <- 0 ] [ #Vow.Ash <- 0 ] </storage>
              <origStorage> ACCT_ID_ORIG_STORAGE </origStorage>
              <nonce> _Nonce_Vow => ?_ </nonce>
            </account>
            <account>
              <acctID> Vat </acctID>
              <balance> Vat_balance </balance>
              <code> Vat_bin_runtime </code>
              <storage> Vat_STORAGE => Vat_STORAGE [ #Vat.dai[Flapper] <- 0 ] [ #Vat.dai[ACCT_ID] <- 0 ] [ #Vat.sin[ACCT_ID] <- Sin_v -Int (Dai_v +Int Dai_f) ] [ #Vat.vice <- Vice -Int (Dai_v +Int Dai_f) ] [ #Vat.debt <- Debt -Int (Dai_v +Int Dai_f) ] </storage>
              <origStorage> Vat_ORIG_STORAGE </origStorage>
              <nonce> _Nonce_Vat => ?_ </nonce>
            </account>
            <account>
              <acctID> Flapper </acctID>
              <balance> Flapper_balance </balance>
              <code> Flapper_bin_runtime </code>
              <storage> Flapper_STORAGE => Flapper_STORAGE [ #Flapper.live <- 0 ] </storage>
              <origStorage> Flapper_ORIG_STORAGE </origStorage>
              <nonce> _Nonce_Flapper => ?_ </nonce>
            </account>
            <account>
              <acctID> Flopper </acctID>
              <balance> Flopper_balance </balance>
              <code> Flopper_bin_runtime </code>
              <storage> Flopper_STORAGE => Flopper_STORAGE [ #Flopper.live <- 0 ] [ #Flopper.vow <- ACCT_ID ] </storage>
              <origStorage> Flopper_ORIG_STORAGE </origStorage>
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

       andBool (#rangeAddress(Vat)
       andBool (#rangeAddress(Flapper)
       andBool (#rangeAddress(Flopper)
       andBool (#rangeAddress(FlapVat)
       andBool (#rangeUInt(256, MayFlap)
       andBool (#rangeUInt(256, MayFlop)
       andBool (#rangeUInt(256, Dai_v)
       andBool (#rangeUInt(256, Sin_v)
       andBool (#rangeUInt(256, Dai_f)
       andBool (#rangeUInt(256, Debt)
       andBool (#rangeUInt(256, Vice)
       andBool (#rangeUInt(256, Live)
       andBool (#rangeUInt(256, Sin)
       andBool (#rangeUInt(256, Ash)
       andBool (#rangeUInt(256, FlapLive)
       andBool (#rangeUInt(256, FlopLive)
       andBool (#rangeAddress(FlopVow)
       andBool (#rangeUInt(256, Vat_balance)
       andBool (#rangeUInt(256, Flapper_balance)
       andBool (#rangeUInt(256, Flopper_balance)
       andBool ((#sizeByteArray(CD) <=Int 1250000000)
       andBool ((#notPrecompileAddress(Vat))
       andBool ((#notPrecompileAddress(Flapper))
       andBool ((#notPrecompileAddress(Flopper))
       andBool ((#notPrecompileAddress(FlapVat))
       andBool ((#notPrecompileAddress(FlopVow))
       andBool ((ACCT_ID =/=Int Vat)
       andBool ((ACCT_ID =/=Int Flapper)
       andBool ((ACCT_ID =/=Int Flopper)
       andBool ((Dai_v +Int Dai_f <Int Sin_v)
       andBool ((Flapper =/=Int ACCT_ID)
       andBool ((Flapper =/=Int Vat)
       andBool ((Flopper =/=Int ACCT_ID)
       andBool ((Flopper =/=Int Vat)
       andBool ((Flopper =/=Int Flapper)
       andBool ((FlapVat ==Int  Vat)
       andBool ((Vat =/=Int 0)
       andBool ((Flapper =/=Int 0)
       andBool ((Flopper =/=Int 0)
       andBool (#rangeUInt(256, Junk_0)
       andBool (#rangeUInt(256, Junk_1)
       andBool (#rangeUInt(256, Junk_2)
       andBool (#rangeUInt(256, Junk_3)
       andBool (#rangeUInt(256, Junk_4)
       andBool (#rangeUInt(256, Junk_5)
       andBool (#rangeUInt(256, Junk_6)
       andBool (#rangeUInt(256, Junk_7)
       andBool (#rangeUInt(256, Junk_8)
       andBool (#rangeUInt(256, Junk_9)
       andBool (#rangeUInt(256, Junk_10)
       andBool (#rangeUInt(256, Junk_11)
       andBool (#rangeUInt(256, Junk_12)
       andBool (#rangeUInt(256, Junk_13)
       andBool (#rangeUInt(256, Junk_14)
       andBool (#rangeUInt(256, Junk_15)
       andBool (#rangeUInt(256, Junk_16)
       andBool (#rangeUInt(256, Junk_17)
       andBool (#rangeUInt(256, Junk_18)
       andBool (#rangeUInt(256, Junk_19)
       andBool (((VCallValue ==Int 0))
       andBool (((VCallDepth <Int 1023))
       andBool (((Live ==Int 1))
       andBool (((Can ==Int 1))
       andBool (((MayFlap ==Int 1))
       andBool (((MayFlop ==Int 1))
       andBool ((#rangeUInt(256, Debt -Int (Dai_v +Int Dai_f)))
       andBool ((#rangeUInt(256, Vice -Int (Dai_v +Int Dai_f))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

       andBool #lookup(ACCT_ID_STORAGE, #Vow.wards[CALLER_ID]) ==Int Can
       andBool #lookup(ACCT_ID_STORAGE, #Vow.vat) ==Int Vat
       andBool #lookup(ACCT_ID_STORAGE, #Vow.flopper) ==Int Flopper
       andBool #lookup(ACCT_ID_STORAGE, #Vow.flapper) ==Int Flapper
       andBool #lookup(ACCT_ID_STORAGE, #Vow.live) ==Int Live
       andBool #lookup(ACCT_ID_STORAGE, #Vow.Sin) ==Int Sin
       andBool #lookup(ACCT_ID_STORAGE, #Vow.Ash) ==Int Ash
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vow.wards[CALLER_ID]) ==Int Junk_0
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vow.vat) ==Int Junk_1
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vow.flopper) ==Int Junk_2
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vow.flapper) ==Int Junk_3
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vow.live) ==Int Junk_4
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vow.Sin) ==Int Junk_5
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vow.Ash) ==Int Junk_6
       andBool #Vow.wards[CALLER_ID] =/=Int #Vow.vat
       andBool #Vow.wards[CALLER_ID] =/=Int #Vow.flopper
       andBool #Vow.wards[CALLER_ID] =/=Int #Vow.flapper
       andBool #Vow.wards[CALLER_ID] =/=Int #Vow.live
       andBool #Vow.wards[CALLER_ID] =/=Int #Vow.Sin
       andBool #Vow.wards[CALLER_ID] =/=Int #Vow.Ash
       andBool #Vow.vat =/=Int #Vow.flopper
       andBool #Vow.vat =/=Int #Vow.flapper
       andBool #Vow.vat =/=Int #Vow.live
       andBool #Vow.vat =/=Int #Vow.Sin
       andBool #Vow.vat =/=Int #Vow.Ash
       andBool #Vow.flopper =/=Int #Vow.flapper
       andBool #Vow.flopper =/=Int #Vow.live
       andBool #Vow.flopper =/=Int #Vow.Sin
       andBool #Vow.flopper =/=Int #Vow.Ash
       andBool #Vow.flapper =/=Int #Vow.live
       andBool #Vow.flapper =/=Int #Vow.Sin
       andBool #Vow.flapper =/=Int #Vow.Ash
       andBool #Vow.live =/=Int #Vow.Sin
       andBool #Vow.live =/=Int #Vow.Ash
       andBool #Vow.Sin =/=Int #Vow.Ash
       andBool #lookup(Vat_STORAGE, #Vat.can[Flapper][Flapper]) ==Int Junk_7
       andBool #lookup(Vat_STORAGE, #Vat.dai[Flapper]) ==Int Dai_f
       andBool #lookup(Vat_STORAGE, #Vat.dai[ACCT_ID]) ==Int Dai_v
       andBool #lookup(Vat_STORAGE, #Vat.sin[ACCT_ID]) ==Int Sin_v
       andBool #lookup(Vat_STORAGE, #Vat.vice) ==Int Vice
       andBool #lookup(Vat_STORAGE, #Vat.debt) ==Int Debt
       andBool #lookup(Vat_ORIG_STORAGE, #Vat.can[Flapper][Flapper]) ==Int Junk_8
       andBool #lookup(Vat_ORIG_STORAGE, #Vat.dai[Flapper]) ==Int Junk_9
       andBool #lookup(Vat_ORIG_STORAGE, #Vat.dai[ACCT_ID]) ==Int Junk_10
       andBool #lookup(Vat_ORIG_STORAGE, #Vat.sin[ACCT_ID]) ==Int Junk_11
       andBool #lookup(Vat_ORIG_STORAGE, #Vat.vice) ==Int Junk_12
       andBool #lookup(Vat_ORIG_STORAGE, #Vat.debt) ==Int Junk_13
       andBool #Vat.can[Flapper][Flapper] =/=Int #Vat.dai[Flapper]
       andBool #Vat.can[Flapper][Flapper] =/=Int #Vat.dai[ACCT_ID]
       andBool #Vat.can[Flapper][Flapper] =/=Int #Vat.sin[ACCT_ID]
       andBool #Vat.can[Flapper][Flapper] =/=Int #Vat.vice
       andBool #Vat.can[Flapper][Flapper] =/=Int #Vat.debt
       andBool #Vat.dai[Flapper] =/=Int #Vat.dai[ACCT_ID]
       andBool #Vat.dai[Flapper] =/=Int #Vat.sin[ACCT_ID]
       andBool #Vat.dai[Flapper] =/=Int #Vat.vice
       andBool #Vat.dai[Flapper] =/=Int #Vat.debt
       andBool #Vat.dai[ACCT_ID] =/=Int #Vat.sin[ACCT_ID]
       andBool #Vat.dai[ACCT_ID] =/=Int #Vat.vice
       andBool #Vat.dai[ACCT_ID] =/=Int #Vat.debt
       andBool #Vat.sin[ACCT_ID] =/=Int #Vat.vice
       andBool #Vat.sin[ACCT_ID] =/=Int #Vat.debt
       andBool #Vat.vice =/=Int #Vat.debt
       andBool #lookup(Flapper_STORAGE, #Flapper.wards[ACCT_ID]) ==Int MayFlap
       andBool #lookup(Flapper_STORAGE, #Flapper.vat) ==Int FlapVat
       andBool #lookup(Flapper_STORAGE, #Flapper.live) ==Int FlapLive
       andBool #lookup(Flapper_ORIG_STORAGE, #Flapper.wards[ACCT_ID]) ==Int Junk_14
       andBool #lookup(Flapper_ORIG_STORAGE, #Flapper.vat) ==Int Junk_15
       andBool #lookup(Flapper_ORIG_STORAGE, #Flapper.live) ==Int Junk_16
       andBool #Flapper.wards[ACCT_ID] =/=Int #Flapper.vat
       andBool #Flapper.wards[ACCT_ID] =/=Int #Flapper.live
       andBool #Flapper.vat =/=Int #Flapper.live
       andBool #lookup(Flopper_STORAGE, #Flopper.wards[ACCT_ID]) ==Int MayFlop
       andBool #lookup(Flopper_STORAGE, #Flopper.live) ==Int FlopLive
       andBool #lookup(Flopper_STORAGE, #Flopper.vow) ==Int FlopVow
       andBool #lookup(Flopper_ORIG_STORAGE, #Flopper.wards[ACCT_ID]) ==Int Junk_17
       andBool #lookup(Flopper_ORIG_STORAGE, #Flopper.live) ==Int Junk_18
       andBool #lookup(Flopper_ORIG_STORAGE, #Flopper.vow) ==Int Junk_19
       andBool #Flopper.wards[ACCT_ID] =/=Int #Flopper.live
       andBool #Flopper.wards[ACCT_ID] =/=Int #Flopper.vow
       andBool #Flopper.live =/=Int #Flopper.vow

    // Vow_minuu
    claim [Vow.minuu.pass]:
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
            <program> Vow_bin_runtime </program>
            <jumpDests> #computeValidJumpDests(Vow_bin_runtime) </jumpDests>
            <id> ACCT_ID </id>
            <caller> CALLER_ID </caller>
            <callData> _ => ?_ </callData>
            <callValue> VCallValue </callValue>
            <wordStack> ABI_y : ABI_x : JMPTO : WS  =>  JMPTO : #if ABI_x >Int ABI_y #then ABI_y #else ABI_x #fi : WS </wordStack>
            <localMem> _ </localMem>
            <pc> 9829 => 9854 </pc>
            <gas> #gas(VGas) => #if ABI_x <=Int ABI_y
              #then   #gas ( ( VGas +Int -49 ) )
              #else   #gas ( ( VGas +Int -59 ) )
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
              <code> Vow_bin_runtime </code>
              <storage> ACCT_ID_STORAGE => ACCT_ID_STORAGE  </storage>
              <origStorage> ACCT_ID_ORIG_STORAGE </origStorage>
              <nonce> _Nonce_Vow => ?_ </nonce>
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
       andBool (#rangeUInt(256, VMemoryUsed)))))


    [trusted, matching(infGas)]


    // Vat_dai
    claim [Vat.dai.pass]:
      <k> #execute ~> CONTINUATION => #halt ~> CONTINUATION </k>
      <exit-code> 1 </exit-code>
      <mode> NORMAL </mode>
      <schedule> ISTANBUL </schedule>
      <ethereum>
        <evm>
          <output> _ => #buf(32, Rad) </output>
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
            <callData> #abiCallData("dai", #address(ABI_usr)) ++ CD => ?_ </callData>
            <callValue> VCallValue </callValue>
            <wordStack> .WordStack => ?_ </wordStack>
            <localMem> .Memory => ?_ </localMem>
            <pc> 0 => ?_ </pc>
            <gas> #gas(VGas) => #gas ( ( VGas +Int -1236 ) ) </gas>
            <memoryUsed> 0 => ?_ </memoryUsed>
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

       andBool (#rangeAddress(ABI_usr)
       andBool (#rangeUInt(256, Rad)
       andBool (#sizeByteArray(CD) <=Int 1250000000
       andBool (#rangeUInt(256, Junk_0)
       andBool ((VCallValue ==Int 0))))))

       andBool #lookup(ACCT_ID_STORAGE, #Vat.dai[ABI_usr]) ==Int Rad
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.dai[ABI_usr]) ==Int Junk_0
    [trusted, matching(infGas)]


    // Vat_sin
    claim [Vat.sin.pass]:
      <k> #execute ~> CONTINUATION => #halt ~> CONTINUATION </k>
      <exit-code> 1 </exit-code>
      <mode> NORMAL </mode>
      <schedule> ISTANBUL </schedule>
      <ethereum>
        <evm>
          <output> _ => #buf(32, Rad) </output>
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
            <callData> #abiCallData("sin", #address(ABI_usr)) ++ CD => ?_ </callData>
            <callValue> VCallValue </callValue>
            <wordStack> .WordStack => ?_ </wordStack>
            <localMem> .Memory => ?_ </localMem>
            <pc> 0 => ?_ </pc>
            <gas> #gas(VGas) => #gas ( ( VGas +Int -1235 ) ) </gas>
            <memoryUsed> 0 => ?_ </memoryUsed>
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

       andBool (#rangeAddress(ABI_usr)
       andBool (#rangeUInt(256, Rad)
       andBool (#sizeByteArray(CD) <=Int 1250000000
       andBool (#rangeUInt(256, Junk_0)
       andBool ((VCallValue ==Int 0))))))

       andBool #lookup(ACCT_ID_STORAGE, #Vat.sin[ABI_usr]) ==Int Rad
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.sin[ABI_usr]) ==Int Junk_0
    [trusted, matching(infGas)]


    // Vat_heal
    claim [Vat.heal.pass]:
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
            <callData> #abiCallData("heal", #uint256(ABI_rad)) ++ CD => ?_ </callData>
            <callValue> VCallValue </callValue>
            <wordStack> .WordStack => ?_ </wordStack>
            <localMem> .Memory => ?_ </localMem>
            <pc> 0 => ?_ </pc>
            <gas> #gas(VGas) => #gas ( ( ( ( ( ( VGas -Int Csstore( ISTANBUL , ( Sin -Int ABI_rad ) , Sin , Junk_0 ) ) -Int Csstore( ISTANBUL , ( Dai -Int ABI_rad ) , Dai , Junk_1 ) ) -Int Csstore( ISTANBUL , ( Vice -Int ABI_rad ) , Vice , Junk_2 ) ) -Int Csstore( ISTANBUL , ( Debt -Int ABI_rad ) , Debt , Junk_3 ) ) +Int -8616 ) ) </gas>
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
              <storage> ACCT_ID_STORAGE => ACCT_ID_STORAGE [ #Vat.sin[CALLER_ID] <- Sin -Int ABI_rad ] [ #Vat.dai[CALLER_ID] <- Dai -Int ABI_rad ] [ #Vat.vice <- Vice  -Int ABI_rad ] [ #Vat.debt <- Debt  -Int ABI_rad ] </storage>
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

       andBool (#rangeUInt(256, ABI_rad)
       andBool (#rangeUInt(256, Dai)
       andBool (#rangeUInt(256, Sin)
       andBool (#rangeUInt(256, Debt)
       andBool (#rangeUInt(256, Vice)
       andBool (#sizeByteArray(CD) <=Int 1250000000
       andBool (#rangeUInt(256, Junk_0)
       andBool (#rangeUInt(256, Junk_1)
       andBool (#rangeUInt(256, Junk_2)
       andBool (#rangeUInt(256, Junk_3)
       andBool (((VCallValue ==Int 0))
       andBool ((#rangeUInt(256, Dai -Int ABI_rad))
       andBool ((#rangeUInt(256, Sin -Int ABI_rad))
       andBool ((#rangeUInt(256, Debt  -Int ABI_rad))
       andBool ((#rangeUInt(256, Vice  -Int ABI_rad)))))))))))))))))

       andBool #lookup(ACCT_ID_STORAGE, #Vat.sin[CALLER_ID]) ==Int Sin
       andBool #lookup(ACCT_ID_STORAGE, #Vat.dai[CALLER_ID]) ==Int Dai
       andBool #lookup(ACCT_ID_STORAGE, #Vat.vice) ==Int Vice
       andBool #lookup(ACCT_ID_STORAGE, #Vat.debt) ==Int Debt
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.sin[CALLER_ID]) ==Int Junk_0
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.dai[CALLER_ID]) ==Int Junk_1
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.vice) ==Int Junk_2
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Vat.debt) ==Int Junk_3
       andBool #Vat.sin[CALLER_ID] =/=Int #Vat.dai[CALLER_ID]
       andBool #Vat.sin[CALLER_ID] =/=Int #Vat.vice
       andBool #Vat.sin[CALLER_ID] =/=Int #Vat.debt
       andBool #Vat.dai[CALLER_ID] =/=Int #Vat.vice
       andBool #Vat.dai[CALLER_ID] =/=Int #Vat.debt
       andBool #Vat.vice =/=Int #Vat.debt
    [trusted, matching(infGas)]


    // Flapper_cage
    claim [Flapper.cage.pass]:
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
            <program> Flapper_bin_runtime </program>
            <jumpDests> #computeValidJumpDests(Flapper_bin_runtime) </jumpDests>
            <id> ACCT_ID </id>
            <caller> CALLER_ID </caller>
            <callData> #abiCallData("cage", #uint256(ABI_rad)) ++ CD => ?_ </callData>
            <callValue> VCallValue </callValue>
            <wordStack> .WordStack => ?_ </wordStack>
            <localMem> .Memory => ?_ </localMem>
            <pc> 0 => ?_ </pc>
            <gas> #gas(VGas) => #gas ( ( ( ( ( VGas -Int Csstore( ISTANBUL , 0 , Live , Junk_2 ) ) -Int Csstore( ISTANBUL , ( Dai_a -Int ABI_rad ) , Dai_a , Junk_5 ) ) -Int Csstore( ISTANBUL , ( Dai_u +Int ABI_rad ) , Dai_u , Junk_6 ) ) +Int -15964 ) ) </gas>
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
          SetItem(Vat)
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
              <code> Flapper_bin_runtime </code>
              <storage> ACCT_ID_STORAGE => ACCT_ID_STORAGE [ #Flapper.live <- 0 ] </storage>
              <origStorage> ACCT_ID_ORIG_STORAGE </origStorage>
              <nonce> _Nonce_Flapper => ?_ </nonce>
            </account>
            <account>
              <acctID> Vat </acctID>
              <balance> Vat_balance </balance>
              <code> Vat_bin_runtime </code>
              <storage> Vat_STORAGE => Vat_STORAGE [ #Vat.dai[ACCT_ID] <- Dai_a -Int ABI_rad ] [ #Vat.dai[CALLER_ID] <- Dai_u +Int ABI_rad ] </storage>
              <origStorage> Vat_ORIG_STORAGE </origStorage>
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

       andBool (#rangeUInt(256, ABI_rad)
       andBool (#rangeAddress(Vat)
       andBool (#rangeUInt(256, Ward)
       andBool (#rangeUInt(256, Live)
       andBool (#rangeUInt(256, Dai_a)
       andBool (#rangeUInt(256, Dai_u)
       andBool (#rangeUInt(256, Vat_balance)
       andBool ((#sizeByteArray(CD) <=Int 1250000000)
       andBool ((#notPrecompileAddress(Vat))
       andBool ((CALLER_ID =/=Int ACCT_ID)
       andBool (ACCT_ID =/=Int Vat
       andBool ((Vat =/=Int 0)
       andBool (#rangeUInt(256, Junk_0)
       andBool (#rangeUInt(256, Junk_1)
       andBool (#rangeUInt(256, Junk_2)
       andBool (#rangeUInt(256, Junk_3)
       andBool (#rangeUInt(256, Junk_4)
       andBool (#rangeUInt(256, Junk_5)
       andBool (#rangeUInt(256, Junk_6)
       andBool (((Ward ==Int 1))
       andBool (((VCallDepth <Int 1024))
       andBool (((VCallValue ==Int 0))
       andBool ((#rangeUInt(256, Dai_a -Int ABI_rad))
       andBool ((#rangeUInt(256, Dai_u +Int ABI_rad))))))))))))))))))))))))))

       andBool #lookup(ACCT_ID_STORAGE, #Flapper.wards[CALLER_ID]) ==Int Ward
       andBool #lookup(ACCT_ID_STORAGE, #Flapper.vat) ==Int Vat
       andBool #lookup(ACCT_ID_STORAGE, #Flapper.live) ==Int Live
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Flapper.wards[CALLER_ID]) ==Int Junk_0
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Flapper.vat) ==Int Junk_1
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Flapper.live) ==Int Junk_2
       andBool #Flapper.wards[CALLER_ID] =/=Int #Flapper.vat
       andBool #Flapper.wards[CALLER_ID] =/=Int #Flapper.live
       andBool #Flapper.vat =/=Int #Flapper.live
       andBool #lookup(Vat_STORAGE, #Vat.can[ACCT_ID][ACCT_ID]) ==Int Junk_3
       andBool #lookup(Vat_STORAGE, #Vat.dai[ACCT_ID]) ==Int Dai_a
       andBool #lookup(Vat_STORAGE, #Vat.dai[CALLER_ID]) ==Int Dai_u
       andBool #lookup(Vat_ORIG_STORAGE, #Vat.can[ACCT_ID][ACCT_ID]) ==Int Junk_4
       andBool #lookup(Vat_ORIG_STORAGE, #Vat.dai[ACCT_ID]) ==Int Junk_5
       andBool #lookup(Vat_ORIG_STORAGE, #Vat.dai[CALLER_ID]) ==Int Junk_6
       andBool #Vat.can[ACCT_ID][ACCT_ID] =/=Int #Vat.dai[ACCT_ID]
       andBool #Vat.can[ACCT_ID][ACCT_ID] =/=Int #Vat.dai[CALLER_ID]
       andBool #Vat.dai[ACCT_ID] =/=Int #Vat.dai[CALLER_ID]
    [trusted, matching(infGas)]


    // Flopper_cage
    claim [Flopper.cage.pass]:
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
            <callData> #abiCallData("cage", .TypedArgs) ++ CD => ?_ </callData>
            <callValue> VCallValue </callValue>
            <wordStack> .WordStack => ?_ </wordStack>
            <localMem> .Memory => ?_ </localMem>
            <pc> 0 => ?_ </pc>
            <gas> #gas(VGas) => #gas ( ( ( ( VGas -Int Csstore( ISTANBUL , 0 , Live , Junk_1 ) ) -Int Csstore( ISTANBUL , CALLER_ID , Vow , Junk_2 ) ) +Int -6351 ) ) </gas>
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
              <storage> ACCT_ID_STORAGE => ACCT_ID_STORAGE [ #Flopper.live <- 0 ] [ #Flopper.vow <- CALLER_ID ] </storage>
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

       andBool (#rangeUInt(256, Ward)
       andBool (#rangeUInt(256, Live)
       andBool (#rangeAddress(Vow)
       andBool (#sizeByteArray(CD) <=Int 1250000000
       andBool (#notPrecompileAddress(Vow)
       andBool (#rangeUInt(256, Junk_0)
       andBool (#rangeUInt(256, Junk_1)
       andBool (#rangeUInt(256, Junk_2)
       andBool ((Ward ==Int 1)
       andBool ((VCallValue ==Int 0)))))))))))

       andBool #lookup(ACCT_ID_STORAGE, #Flopper.wards[CALLER_ID]) ==Int Ward
       andBool #lookup(ACCT_ID_STORAGE, #Flopper.live) ==Int Live
       andBool #lookup(ACCT_ID_STORAGE, #Flopper.vow) ==Int Vow
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Flopper.wards[CALLER_ID]) ==Int Junk_0
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Flopper.live) ==Int Junk_1
       andBool #lookup(ACCT_ID_ORIG_STORAGE, #Flopper.vow) ==Int Junk_2
       andBool #Flopper.wards[CALLER_ID] =/=Int #Flopper.live
       andBool #Flopper.wards[CALLER_ID] =/=Int #Flopper.vow
       andBool #Flopper.live =/=Int #Flopper.vow
    [trusted, matching(infGas)]


endmodule
