{Program Samp1
	{Function facto VAL
		{if {> 0 VAL }
		 then {= retVal -1}
		 else {= retVal 1}
		 {while {> VAL 0} do
		 	{= retVal {* retVal VAL}}
		 	{= VAL {- VAL 1}}
		 }
		}
	 return retVal
	}
	{Main
		{read invar}
		{= result {facto invar }} 
		{print (The factorial result is \)}
		{print result}			
	}

}

