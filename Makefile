# sudo apt-get install pandoc
PANDOC = pandoc

# sudo apt-get install node-less
LESSC = lessc

SOURCE_PAGES = $(shell find . -type f -name '*.md')
TARGET_PAGES = $(patsubst ./%.md,%.html,$(SOURCE_PAGES))
TARGET_GZ = $(patsubst ./%.md,%.html.gz,$(SOURCE_PAGES))

HOSTING = kastaneda@rico:/var/www/kastaneda.kiev.ua

NOOP =
SPACE = $(NOOP) $(NOOP)

all: $(TARGET_PAGES) sitemap.xml style/main.css

%.html: %.md Makefile style/template.html
	$(PANDOC) \
	--from markdown \
	--to html5 \
	--standalone \
	--template style/template.html \
	--variable "$(if $(filter index.md,$<),is-index,is-not-index)" \
	--variable "root-path:$(subst $(SPACE),,$(patsubst %,../,$(subst /, ,$(patsubst ./,,$(dir $<)))))" \
	--variable "page-path:$@" \
	$< \
	--output $@

sitemap.xml: $(TARGET_PAGES) Makefile sitemap.sh
	./sitemap.sh $(TARGET_PAGES) > sitemap.xml

style/main.css: style/*.less Makefile
	$(LESSC) --compress style/main.less > $@

gzip: $(TARGET_GZ) style/main.js.gz style/main.css.gz

%.gz: %
	gzip -9 $< -c > $@

clean:
	rm -f $(TARGET_PAGES) $(TARGET_GZ) style/main.css style/main.js.gz style/main.css.gz sitemap.xml

upload: all gzip
	rsync -av --delete --exclude-from=rsync_exclude . $(HOSTING)

.PHONY: all clean gzip upload
