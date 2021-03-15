.SUFFIXES : .src .xml .html

default :
	@echo "There is no default"

all : maketools makelibdoc html

clean :
	@echo Nothing to clean

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
	perl.exe -I ../doc ../doc/xml2html.pl .
	unix2dos *.html
	cd ..
	cd doc

.xml.html :
	perl.exe -I . xml2html.pl $*.xml
	unix2dos $*.html

