#
#  Copyright 2012-2015 Diomidis Spinellis
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

INSTPREFIX?=/usr/local

EXECUTABLES=pmonitor

# Manual pages
MANSRC=$(wildcard *.1)
MANPDF=$(patsubst %.1,%.pdf,$(MANSRC))
MANHTML=$(patsubst %.1,%.html,$(MANSRC))

%.pdf: %.1
	groff -man -Tps $< | ps2pdf - $@

%.html: %.1
	groff -man -Thtml $< >$@

all: $(EXECUTABLES)

pmonitor: pmonitor.sh
	install pmonitor.sh pmonitor

clean:
	rm -f *.o *.exe $(EXECUTABLES) $(MANPDF) $(MANHTML)

install: $(EXECUTABLES)
	install $(EXECUTABLES) $(INSTPREFIX)/bin
	install -m 644 $(MANSRC) $(INSTPREFIX)/share/man/man1

test:
	./test-pmonitor.sh
