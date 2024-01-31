TEMPLATE := ebook.epub
STYLESHEET := stylesheet.css

sources := book.md
targets := $(sources:.md=.epub)
deps := $(sources:.md=.d)

all: $(targets)

clean:
	rm -f $(targets) $(sources:.md=.d)

$(targets): %.epub: %.md $(TEMPLATE) $(STYLESHEET)
	pandoc --template=$(TEMPLATE) --css=$(STYLESHEET) -o $@ $<

%.d: %.md
	echo $*.epub: `sed -n 's/.*!\[\](\(.*\)).*/\1/p' < $<` > $@

include $(deps)
