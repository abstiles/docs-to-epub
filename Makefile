TEMPLATE := ebook.epub
STYLESHEET := stylesheet.css

from := $(wildcard src/*.zip)
sources := $(basename $(from))
targets := $(sources:src/%=build/%.epub)
deps := $(from:src/%=%.d)

all: $(targets)

build/%/: src/%.zip
	mkdir -p "$@"
	unzip -d "$@" "$<"

clean:
	rm -f $(targets) $(sources:.md=.d)

$(targets): %.epub: %.md $(TEMPLATE) $(STYLESHEET)
	pandoc --template=$(TEMPLATE) --css=$(STYLESHEET) -o $@ $<

%.md.d: %.md
	echo $*.epub: `sed -n 's/.*!\[\](\(.*\)).*/\1/p' < $<` > $@

%.zip.d: src/%.zip
	zipinfo -1 "$<" | xargs printf "build/$*/%s: $< | build/$*/\n" > "$@"
	printf 'build/$*.rtf: %s\n\tcp $$< $$@\n' `grep rtf: $@ | cut -d: -f1` >> "$@"
	printf 'build/$*_cover.png: %s\n\tcp $$< $$@\n' `grep png: $@ | cut -d: -f1` >> "$@"

$(targets): build/%.epub: build/%_cover.png

%.md: %.rtf %_meta.yaml
	pandoc -s "$<" -o "$@" --metadata cover-image=$*_cover.png --metadata-file $*_meta.yaml

build/%_meta.yaml: src/%_meta.yaml
	cp "$<" "$@"

include $(deps)
