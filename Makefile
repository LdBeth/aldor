###########################################################
# :: Architectures and distribution to build for
###########################################################

ARCHITECTURES	:= i386 amd64
DISTRIBUTION	:= precise


###########################################################
# :: Variables
###########################################################

CACHEDIR	:= /var/cache/pbuilder
RESULTDIR	:= $(CACHEDIR)/result
PACKAGE_NAME	:= $(shell head -n1 debian/changelog | awk '{print $$1}')
PACKAGE_VERSION	:= $(shell head -n1 debian/changelog | sed -e 's/.*(\(.*\)).*/\1/')
PACKAGE		:= $(PACKAGE_NAME)_$(PACKAGE_VERSION)

TARGETS		:= $(foreach A,$(ARCHITECTURES),$(RESULTDIR)/$(PACKAGE)_$A.deb)


###########################################################
# :: Rules
###########################################################

default: $(TARGETS)

clean:
	sudo rm -f $(TARGETS)
	rm -f ../$(PACKAGE)*

$(RESULTDIR)/$(PACKAGE)_%.deb: $(CACHEDIR)/$(DISTRIBUTION)-%.cow ../$(PACKAGE).dsc
	sudo cowbuilder		\
	  --build		\
	  --basepath $+

$(CACHEDIR)/$(DISTRIBUTION)-%.cow:
	sudo cowbuilder			\
	  --create			\
	  --architecture $*		\
	  --distribution $(DISTRIBUTION)\
	  --basepath $@			\
	  --debootstrapopts "--variant=buildd"
	@test -f $@

../$(PACKAGE).dsc:
	debuild -S -us -uc
	@test -f $@
