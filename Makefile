.PHONY: check build test fmt examples line-example bar-example

check:
	moon check --target all --deny-warn

build:
	moon build --target all --deny-warn

test:
	moon test --target all --deny-warn

fmt:
	moon fmt --check

examples: line-example bar-example

line-example:
	moon run examples/basic_line > line_chart.svg

bar-example:
	moon run examples/basic_bar > bar_chart.svg
