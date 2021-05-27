KEVM Optimizations
==================

These optimizations work on the LLVM and Haskell backend and are generated by the script `./optimizer/optimizations.sh`.

```k
requires "evm.md"

module EVM-OPTIMIZATIONS-LEMMAS [kore]
    imports EVM
endmodule

module EVM-OPTIMIZATIONS [kore]
    imports EVM-OPTIMIZATIONS-LEMMAS

    // Nonsense rule to trigger initial slowdown
    rule <k> #halt ~> #halt ~> #halt => . </k> [priority(40)]

rule <kevm>
       <k>
         ( #next[ PUSH(N) ] => . ) ...
       </k>
       <schedule>
         SCHED
       </schedule>
       <ethereum>
         <evm>
           <callState>
             <program>
               PGM
             </program>
             <wordStack>
               ( WS => #asWord( PGM [ ( PCOUNT +Int 1 ) .. N ] ) : WS )
             </wordStack>
             <pc>
               ( PCOUNT => ( ( PCOUNT +Int N ) +Int 1 ) )
             </pc>
             <gas>
               ( GAVAIL => ( GAVAIL -Int Gverylow < SCHED > ) )
             </gas>
             ...
           </callState>
           ...
         </evm>
         ...
       </ethereum>
       ...
     </kevm>
  requires ( Gverylow < SCHED > <=Int GAVAIL )
   andBool ( #sizeWordStack( #asWord( PGM [ ( PCOUNT +Int 1 ) .. N ] ) : WS ) <=Int 1024 )
    [priority(40)]


// {OPTIMIZATIONS}


endmodule
```