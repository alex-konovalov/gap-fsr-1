#############################################################################
##
#W  misc.gi                   GAP Package                   nusa zidaric
##
##


#############################################################################
##
#F  ChooseField( <F> )
##
##  choose the underlying finite field for the NLFSR
##  needed to create the indeterminates !!!!
##  :(
## ugly, take a second look at it !!!!
##



InstallGlobalFunction( ChooseField, function( F )
    local x, i , str, MaxNLFSRLen, MaxNrOfPresentMonomials, xlist ;

	if(IsField(F)) then
		x := X(F, "x");
		MaxNLFSRLen := 100;
		MaxNrOfPresentMonomials := 100;
		if not IsBoundGlobal("MaxNLFSRLen") then
			BindGlobal("MaxNLFSRLen" , 100);
			BindGlobal("MaxNrOfPresentMonomials" , 100);
			MakeReadWriteGlobal("MaxNLFSRLen");
			MakeReadWriteGlobal("MaxNrOfPresentMonomials");
		fi;

		xlist := [];
		for i in [1..MaxNLFSRLen] do
			str :=  Concatenation("x_",String(i-1));
			if IsBoundGlobal(str) then
	#			Print("changing: ",str," \n");
				str := Indeterminate(F,1000+(i-1));
			else

	#			Print("binding: ",str," \n");
				SetIndeterminateName(FamilyObj(x), 800+(i-1), str);
				BindGlobal(str,Indeterminate(F,800+(i-1)));
				MakeReadWriteGlobal(str);
			fi;
			Add(xlist, str );
		od;
		if not IsBoundGlobal("xlist") then
			BindGlobal("xlist" , xlist);
		fi;
		Print("You can now create an NLFSR with up to ", MaxNLFSRLen ," stages\n");
		Print("with up to  ", MaxNrOfPresentMonomials ," nonzero terms\n");
	else
	    Error("F is not a field !!!! \n");
	  fi;
return;
end );




#############################################################################
##
#M  TrimLeadCoeff(<coefs>) 			Trim the leading coefficient
##
##

InstallMethod( TrimLeadCoeff, "Trim the leading coefficient off the list",
[IsFFECollection and IsRowVector], function(coefs)

local trimmed, i;

trimmed := [];
for i in [1..Length(coefs)-1] do
	trimmed[i] := coefs[i];
od;

return trimmed;
end);


#InstallMethod( IdxNonzeroCoeffs, "Indeces of nonzero coefficients off the list",  [IsFFECollection and IsRowVector], function(coefs)
## doesnt work coz coefs not mutable !!!!
#local t, tlist,len , c;

#len := Length(coefs)+1;
#tlist := [];
#t := PositionNonZero(coefs);
#if (t < len) then
#	Add(tlist,t);
#	coefs[t] := 0*Z(2); # doesnt work coz coefs not mutable !!!!
#fi;

#while (t < len) do
#	t := PositionNonZero(coefs);
#	if (t < len) then
#		Add(tlist,t);
#		coefs[t] := 0*Z(2);
#	fi;
#od;



#return tlist;
#end);



InstallMethod( IdxNonzeroCoeffs2, "Indeces of nonzero coefficients of the list",
  [IsFFECollection and IsRowVector], function(coefs)

local t, tlist, len, i;
len := Length(coefs);
tlist := [];

for i in [1.. len] do
	if not (coefs[i] = 0*Z(2)) then
		Add(tlist,i);
	fi;
od;

return tlist;
end);

InstallMethod( NrNonzeroCoeffs, "Number of nonzero indeces",
[IsFFECollection and IsRowVector], function(coefs)
local tlist;

	tlist := IdxNonzeroCoeffs2(coefs);

return Length(tlist);
end);




InstallMethod( MonomialsOverField, "reduce expomnents of monomials",
[IsField, IsPolynomial], function(K, mon)
local lmlist, term , m, i;
	lmlist := LeadingMonomial(mon);
	term := LeadingCoefficient(mon);
#	Print(lmlist,"\n");	Print(term,"\n");
	if (IsPrimeField(K) and Characteristic(K)=2) then
		for i in [1..Length(lmlist)] do
			if IsOddInt(i) then
				term := term * Indeterminate(K, lmlist[i]);
#				Print(term,"\t");
				 # in F_2: a^n = a for all n>0
			fi;
		od;
#		Print("\n");
	else
		m := Size(K)-1;
		for i in [1..Length(lmlist)-1] do
			if IsOddInt(i) then
				term := term * Indeterminate(K, lmlist[i])^(lmlist[i+1] mod m);
			fi;
		od;
	fi;


return term;
end);


InstallMethod( MonomialsOverField, "reduce expomnents of monomials",
 [IsField, IsList],  function(K, mon)
local newlist, i;
		newlist := [];
		for i in [1..Length(mon)] do

			if IsPolynomial(mon[i]) then
				newlist[i] := MonomialsOverField(K, mon[i]);
			else
				newlist[i] := mon[i];   # to account for case when we have constants
			fi;
		od;
return newlist;
end);


InstallMethod( DegreeOfPolynomial, "degree of polynomial",  [IsPolynomial],
 function(mon)
local lmlist, d, i;

	lmlist := LeadingMonomial(mon);
	d := 0;
	for i in [1..Length(lmlist)] do
		if IsEvenInt(i) then
			d := d + lmlist[i];
		fi;
	od;

return d;
end);




# in order to make sure that monomial returned by LeadingMonomial is still leading monomial
# even after mod reduction of exponents , easiest thing is to reduce exponent first ->
# new function PolynomialOverField
# but now i dont really need two versions of DegreeOfPolynomial coz the one without field as parameter is enough !!!
#InstallMethod( DegreeOfPolynomial, "degree of polynomial",  [IsField, IsPolynomial], function(K, mon)
#local lmlist, d, dmax, i, m;
#		lmlist := LeadingMonomial(mon);
#		d := 0; dmax := 0;
#	if (IsPrimeField(K) and Characteristic(K)=2) then
#		for i in [1..Length(lmlist)] do
#			if IsEvenInt(i) then
#				d := d + 1; # in F_2: a^n = a for all n>0
#			fi;
#		od;
#	else
#		m := Size(K)-1;
#		for i in [1..Length(lmlist)] do
#			if IsEvenInt(i) then
#				d := d + ( lmlist[i] mod m );
#			fi;
#		od;
#	fi;
#
#return d;
#end);



InstallMethod( ReciprocalPolynomial, "reciprocal polynomial",
 [IsField, IsPolynomial], function(K, poly)
local  rcoefs ;

	rcoefs := Reversed(CoefficientsOfUnivariatePolynomial(poly));  # reversed !!!!

	return UnivariatePolynomial(K, rcoefs);

end);






#############################################################################
##
#M  GeneratorOfField( <F> )    . . . .. get generator of zechs log
##

InstallMethod(  GeneratorOfField, "generator of underlying field",
[IsField and IsFinite], function(F)
local w;
	w := RootOfDefiningPolynomial(F);

	if Order(w)=Size(F)-1 then return w;
	else return First(Elements(F),x->not IsZero(x) and Order(x)=Size(F)-1);
	fi;
end);



#############################################################################
##
#M  GeneratorWRTDefiningPolynomial( <F> )    . . . .. get generator of zechs log
##

InstallMethod( GeneratorWRTDefiningPolynomial, "generator of underlying field",
  [IsField and IsFinite], function(F)
	return Coefficients(Basis(F), GeneratorOfField(F));
end);



Print("misc.gi OK,\t");
