.PHONY: clean spellcheck docbook_fix_links

OS := $(shell uname)
ifeq ($(OS),Darwin)
	SHELL := "/bin/bash"
	ASPELLPATH := "/usr/local/bin/aspell"
	FONT := Palatino
else
	ASPELLPATH := "/usr/bin/aspell"
	FONT := Nimbus Sans L

endif
ASPELL := $(shell { type $(ASPELLPATH); } 2>/dev/null)
STYLE := $(shell { type /usr/bin/style; } 2>/dev/null)
BUILD_DIR := "build"
BOOK_CH1 := 01_intro_01_preface.md 
BOOK_CH2 := 02_faq_01_faq.md 
BOOK_CH3 := 03_installation_01_installation.md 
BOOK_CH4 := 04_everyday-usage_01_torbrowser.md 04_everyday-usage_02_pdfs.md 04_everyday-usage_03_coyim.md
BOOK_CH5 := 05_features_and_advanced_usage_01_oz.md 05_features_and_advanced_usage_02_tor.md 05_features_and_advanced_usage_03_metaproxy.md 05_features_and_advanced_usage_04_grsecurity.md 05_features_and_advanced_usage_05_macouflage.md
BOOK_CH_ALL := $(BOOK_CH1) $(BOOK_CH2) $(BOOK_CH3) $(BOOK_CH4) $(BOOK_CH5)

all: clean spellcheck readability contents sgos_handbook
docbook_dev: docbook docbook_fix_links_dev

# requires aspell, aspell-en
spellcheck:
ifdef ASPELL
	find . -maxdepth 1 -name "*.md" -exec $(ASPELLPATH) check {} \;
else
	echo "$(ASPELLPATH) is missing -- no spellcheck possible"
endif

# requires diction
readability: $(BUILD_DIR)/readability.txt
$(BUILD_DIR)/readability.txt: *.md
ifdef STYLE
	style -p $^ > $@
else 
	echo "/usr/bin/style is missing -- no readability check possible"
endif

# requires texlive, texlive-xetex, lmodern, pdftk
contents: $(BUILD_DIR)/contents.pdf
$(BUILD_DIR)/contents.pdf:  $(BOOK_CH_ALL)
	pandoc -r markdown  -o $@ -H templates/style.tex --template=templates/sgos_handbook.latex --toc --latex-engine=xelatex -V mainfont="$(FONT)" $^

sgos_handbook: $(BUILD_DIR)/sgos_handbook.pdf
$(BUILD_DIR)/sgos_handbook.pdf: static/sgos_handbook_cover.pdf build/contents.pdf 
	pdftk $^ cat output $@

epub: $(BUILD_DIR)/sgos_handbook.epub
$(BUILD_DIR)/sgos_handbook.epub: $(BOOK_CH_ALL)
	pandoc -r markdown -o $@ $^


docbook: $(BUILD_DIR)/sgos_handbook.xml
$(BUILD_DIR)/sgos_handbook.xml: $(BOOK_CH_4)
	pandoc -s -r markdown -t docbook -o $@ $^

docbook_fix_links_dev:
	sed -i 's/<imagedata fileref="static/<imagedata fileref="..\/static/g' $(BUILD_DIR)/sgos_handbook.xml

clean:
	rm -f $(BUILD_DIR)/*.pdf $(BUILD_DIR)/*.txt
