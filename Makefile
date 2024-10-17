BF_SRC_DIR=~/Projects/bpfilter
BASE_COMMIT=670b8bb

.ONESHELL:
genlast: | results
	BF_BUILD_DIR=$$(mktemp -d)
	sudo cpupower frequency-set --governor performance
	cmake -S $(BF_SRC_DIR) -B $${BF_BUILD_DIR} -DCMAKE_BUILD_TYPE=debug -DENABLE_BENCHMARK:BOOK=on
	$(MAKE) -C $${BF_BUILD_DIR} -j $$(nproc) benchmark
	cp $${BF_BUILD_DIR}/output/*.json results/
	./genhtml

genall: | results
	BF_BUILD_DIR=$$(mktemp -d)
	sudo cpupower frequency-set --governor performance
	cmake -S $(BF_SRC_DIR) -B $${BF_BUILD_DIR} -DCMAKE_BUILD_TYPE=debug -DENABLE_BENCHMARK:BOOK=on
	git -C $(BF_SRC_DIR) -c sequence.editor=: rebase -i --exec "$(MAKE) -C $${BF_BUILD_DIR} -j $$(nproc) benchmark" $(BASE_COMMIT)~
	cp $${BF_BUILD_DIR}/output/*.json results/
	./genhtml

results:
	@mkdir -p results

serve:
	@printf '\e]8;;http://bf-bench-1:8000\e\\Click to open the results\e]8;;\e\\\n'
	python -m http.server
