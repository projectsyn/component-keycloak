# Configure instance alias for commodore component compile
commodore_args += --alias $(instance)

# Note: if redefine target `test` here it doesn't have the desired effect, as
# the target `test` defined in `Makefile` is defined "later" than the target
# `test` here, since we include the additional Makefile quite early in the
# main `Makefile`.
.PHONY: gotest
gotest: commodore_args += -f tests/$(instance).yml
gotest: .compile ## Test component with a provider set by "instance=..."
	cd tests/ && go test -count=1 ./$(instance)
