a='a`one`,b,xfe,c`two`,d,xfe`three`,"hi" "again"`four` e,f,g'
print(a)
print(string(a))
for ( nt in a ) print(nt,nt.attrib)
for ( n=1; n<=sizeof(a); n++ ) print(a%n,a%n.attrib)
if ( a%1 .attrib == a%2 .attrib ) print("ok")
