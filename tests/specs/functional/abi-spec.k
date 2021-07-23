requires "../lemmas.k"

module VERIFICATION
    imports LEMMAS

    syntax StepSort ::= Int | Bool | String
 // ---------------------------------------

    syntax KItem ::= runLemma ( StepSort )
                   | doneLemma( StepSort )
 // --------------------------------------
    rule runLemma( T ) => doneLemma( T )

endmodule

module ABI-SPEC
    imports VERIFICATION

    claim <k> runLemma ( #getValue(#constructTypedArg("bool", "01")) ) => doneLemma ( 1 ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("bool", "01")) ) => doneLemma ( "bool" ) ... </k>

    claim <k> runLemma ( #getValue(#constructTypedArg("uint160", "1461501637330902918203684832716283019655932542976")) ) => doneLemma ( 0 ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("uint160", "1461501637330902918203684832716283019655932542976")) ) => doneLemma ( "uint160" ) ... </k>

    claim <k> runLemma ( #getValue(#constructTypedArg("address", "1234567890")) ) => doneLemma ( 1234567890 ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("address", "1234567890")) ) => doneLemma ( "address" ) ... </k>

    claim <k> runLemma ( #getValue(#constructTypedArg("uint256", "115792089237316195423570985008687907853269984665640564039457584007913129639936")) ) => doneLemma ( 0 ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("uint256", "115792089237316195423570985008687907853269984665640564039457584007913129639936")) ) => doneLemma ( "uint256" ) ... </k>

    claim <k> runLemma ( #getValue(#constructTypedArg("uint48", "281474976710656")) ) => doneLemma ( 0 ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("uint48", "281474976710656")) ) => doneLemma ( "uint48" ) ... </k>

    claim <k> runLemma ( #getValue(#constructTypedArg("uint16", "65536")) ) => doneLemma ( 0 ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("uint16", "65536")) ) => doneLemma ( "uint16" ) ... </k>

    claim <k> runLemma ( #getValue(#constructTypedArg("uint8", "256")) ) => doneLemma ( 0 ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("uint8", "256")) ) => doneLemma ( "uint8" ) ... </k>

    claim <k> runLemma ( #getValue(#constructTypedArg("int256", "57896044618658097711785492504343953926634992332820282019728792003956564819967")) ) => doneLemma ( -57896044618658097711785492504343953926634992332820282019728792003956564819967 ) ... </k>
    claim <k> runLemma ( #getValue(#constructTypedArg("int256", "100")) ) => doneLemma ( 100 ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("int256", "100")) ) => doneLemma ( "int256" ) ... </k>

    claim <k> runLemma ( #getValue(#constructTypedArg("int128", "170141183460469231731687303715884105727")) ) => doneLemma ( -170141183460469231731687303715884105727 ) ... </k>
    claim <k> runLemma ( #getValue(#constructTypedArg("int128", "100")) ) => doneLemma ( 100 ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("int128", "100")) ) => doneLemma ( "int128" ) ... </k>

    claim <k> runLemma ( #getValue(#constructTypedArg("bytes", "1234567890")) ) => doneLemma ( "1234567890" ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("bytes", "1234567890")) ) => doneLemma ( "bytes" ) ... </k>

    claim <k> runLemma ( #getValue(#constructTypedArg("bytes32", "1234567890")) ) => doneLemma ( "1234567890" ) ... </k>
    claim <k> runLemma ( #typeName(#constructTypedArg("bytes32", "1234567890")) ) => doneLemma ( "bytes32" ) ... </k>
endmodule

