test: .compile ## Test component with a provider set by "provider=..."
	cd tests/ && go test ./$(instance)/... -count=1
