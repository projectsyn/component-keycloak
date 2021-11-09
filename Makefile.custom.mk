# Configure instance alias for commodore component compile
commodore_args += --alias $(instance)

test: .compile ## Test component with a provider set by "instance=..."
	cd tests/ && go test ./$(instance)/... -count=1
