.SUFFIXES : .src .xml .html

default :
	@echo "There is no default"

all : maketools makelibdoc html

makelibdoc :
	cd ..
	cd lib
	ls *.k > ..\doc\liblist
	dos2unix ..\doc\libdoc.sh
	sh ..\doc\libdoc.sh < ..\doc\liblist > ..\doc\libdoc.xml
	cd ..
	cd doc
	rm -f liblist

html : faq.html tutorial.html language.html hacking.html keyvar.html libdoc.html

# The use of xml2html.pl with a directory will generate an index.html
# file in that directory.

maketools :
	cd ..
	cd lib
	c:\cygwin64\bin\perl.exe ..\bin\xml2html.pl .
	cd ..
	cd doc

.xml.html :
	c:\cygwin64\bin\perl.exe ..\bin\xml2html.pl $*.xml

