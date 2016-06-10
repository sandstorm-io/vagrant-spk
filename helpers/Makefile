all: enter_grain.sha1

.PHONY: enter_grain

enter_grain:
	cd enter-grain-source && cargo build --release && strip target/release/enter_grain && cp target/release/enter_grain ../

enter_grain.sha1: enter_grain
	sha1sum enter_grain > enter_grain.sha1

