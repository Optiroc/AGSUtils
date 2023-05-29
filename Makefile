#ECFLAGS = QUIET ERRLINE DEBUG LINEDEBUG
ECFLAGS = QUIET ERRLINE OPTI
EC = EVO

%.m : %.e
	$(EC) $< $(ECFLAGS)

% : %.e
	$(EC) $< $(ECFLAGS)

all: ags-uname ags-vadjust
ags-uname: ags-uname.e defs.m uname.m
ags-vadjust: ags-vadjust.e defs.m uname.m

.PHONY: clean
clean:
	@delete >NIL: ags-uname ags-vadjust #?.m
