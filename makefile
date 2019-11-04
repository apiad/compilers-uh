# Input
CONTENT_DIR = content
SLIDES_DIR = slides
GRAPHICS_DIR = graphics
NOTEBOOKS_DIR = notebooks
ASSETS_DIR = assets

# Output
BUILD_DIR = build

CONTENT_MD_DIR = $(BUILD_DIR)/markdown
CONTENT_PDF_DIR = $(BUILD_DIR)/pdf
CONTENT_PDF = $(CONTENT_PDF_DIR)/compilers.pdf

HTML_DIR = $(BUILD_DIR)/html

SLIDES_MD_DIR = $(BUILD_DIR)/slides/markdown
SLIDES_PDF_DIR = $(BUILD_DIR)/slides/pdf
SLIDES_HTML_DIR = $(BUILD_DIR)/slides/html

NOTEBOOKS_FINAL_DIR = $(BUILD_DIR)/notebooks
NOTEBOOKS_SOLUTIONS_DIR = $(BUILD_DIR)/notebooks/solutions

GRAPHICS_BUILD_DIR = $(BUILD_DIR)/graphics

## Output files collections
CONTENT_SOURCE = $(wildcard $(CONTENT_DIR)/*.pmd)
CONTENT_MD = $(patsubst $(CONTENT_DIR)/%.pmd, $(CONTENT_MD_DIR)/%.md, $(CONTENT_SOURCE))
CONTENT_HTML = $(patsubst $(CONTENT_DIR)/%.pmd, $(HTML_DIR)/%.html, $(CONTENT_SOURCE))

GRAPHICS_SOURCE = $(wildcard $(GRAPHICS_DIR)/*.svg)
GRAPHICS_SVG = $(patsubst $(GRAPHICS_DIR)/%.svg, $(GRAPHICS_BUILD_DIR)/%.svg, $(GRAPHICS_SOURCE))
GRAPHICS_PNG = $(patsubst $(GRAPHICS_DIR)/%.svg, $(GRAPHICS_BUILD_DIR)/%.png, $(GRAPHICS_SOURCE))
GRAPHICS_PDF = $(patsubst $(GRAPHICS_DIR)/%.svg, $(GRAPHICS_BUILD_DIR)/%.pdf, $(GRAPHICS_SOURCE))

GRAPHICS_BUILD_SOURCE = $(wildcard $(GRAPHICS_BUILD_DIR)/*.svg)
GRAPHICS_BUILD_PNG = $(patsubst $(GRAPHICS_BUILD_DIR)/%.svg, $(GRAPHICS_BUILD_DIR)/%.png, $(GRAPHICS_BUILD_SOURCE))
GRAPHICS_BUILD_PDF = $(patsubst $(GRAPHICS_BUILD_DIR)/%.svg, $(GRAPHICS_BUILD_DIR)/%.pdf, $(GRAPHICS_BUILD_SOURCE))

SLIDES_SOURCE = $(wildcard $(SLIDES_DIR)/*.pmd)
SLIDES_MD = $(patsubst $(SLIDES_DIR)/%.pmd, $(SLIDES_MD_DIR)/%.md, $(SLIDES_SOURCE))
SLIDES_PDF = $(patsubst $(SLIDES_DIR)/%.pmd, $(SLIDES_PDF_DIR)/%.pdf, $(SLIDES_SOURCE))
SLIDES_HTML = $(patsubst $(SLIDES_DIR)/%.pmd, $(SLIDES_HTML_DIR)/%.html, $(SLIDES_SOURCE))

NOTEBOOKS_SOURCE = $(wildcard $(NOTEBOOKS_DIR)/*.ipynb)
NOTEBOOKS_FINAL = $(patsubst $(NOTEBOOKS_DIR)/%.ipynb, $(NOTEBOOKS_FINAL_DIR)/%.ipynb, $(NOTEBOOKS_SOURCE))
NOTEBOOKS_SOLUTIONS = $(patsubst $(NOTEBOOKS_DIR)/%.ipynb, $(NOTEBOOKS_SOLUTIONS_DIR)/%.ipynb, $(NOTEBOOKS_SOURCE))

# Main build rules
all: main html slides notebooks

## Main content
main: $(CONTENT_PDF)

$(CONTENT_PDF): markdown meta/header.tex meta/metadata.yaml
	pandoc --toc --filter filters/fix_image_path.py -H meta/header.tex -V lang=es -o $(CONTENT_PDF) meta/metadata.yaml `ls $(CONTENT_MD_DIR)/*.md`

markdown: folders $(CONTENT_MD)
	make images
	cp meta/_config.yml $(BUILD_DIR)/_config.yml
	cp meta/index.md $(BUILD_DIR)/index.md

$(CONTENT_MD_DIR)/%.md: $(CONTENT_DIR)/%.pmd
	FILENAME="$<" pweave -f markdown -i markdown -o $@ $<

## Images
images: folders $(GRAPHICS_SVG) $(GRAPHICS_PDF) $(GRAPHICS_BUILD_PDF)

$(GRAPHICS_BUILD_DIR)/%.svg: $(GRAPHICS_DIR)/%.svg
	cp $< $@

$(GRAPHICS_BUILD_DIR)/%.pdf: $(GRAPHICS_BUILD_DIR)/%.svg
	inkscape -A $@ -f $<

### HTML version
html: folders $(CONTENT_HTML) images meta/style-html.css
	cp meta/style-html.css $(HTML_DIR)/style.css

$(HTML_DIR)/%.html: $(CONTENT_MD_DIR)/%.md
	pandoc -c style.css --template meta/template-book.html -o $@ $<

## Slides
slides: folders $(SLIDES_PDF) $(SLIDES_HTML)
	make images

$(SLIDES_PDF_DIR)/%.pdf: $(SLIDES_MD_DIR)/%.md
	pandoc -t beamer --filter filters/fix_image_path.py -o $@ $<

$(SLIDES_HTML_DIR)/%.html: $(SLIDES_MD_DIR)/%.md
	pandoc -s -t revealjs -o $@ $<
	cp $(ASSETS_DIR)/reveal.js $(SLIDES_HTML_DIR)/reveal.js

slides-md: folders $(SLIDES_MD)

$(SLIDES_MD_DIR)/%.md: $(SLIDES_DIR)/%.pmd
	FILENAME="$<" pweave -f markdown -i markdown -o $@ $<

## Notebooks
notebooks: folders $(NOTEBOOKS_FINAL) $(NOTEBOOKS_SOLUTIONS)

$(NOTEBOOKS_FINAL_DIR)/%.ipynb: $(NOTEBOOKS_DIR)/%.ipynb
	python notebooks/make.py $< $@ $(patsubst $(NOTEBOOKS_DIR)/%.ipynb, $(NOTEBOOKS_SOLUTIONS_DIR)/%.ipynb, $<)

# Utility rules
folders:
	mkdir -p $(CONTENT_MD_DIR)
	mkdir -p $(CONTENT_PDF_DIR)
	mkdir -p $(SLIDES_MD_DIR)
	mkdir -p $(SLIDES_PDF_DIR)
	mkdir -p $(SLIDES_HTML_DIR)
	mkdir -p $(HTML_DIR)
	mkdir -p $(NOTEBOOKS_FINAL_DIR)
	mkdir -p $(NOTEBOOKS_SOLUTIONS_DIR)
	mkdir -p $(GRAPHICS_BUILD_DIR)

publish:
	(cd build && rm -rf .git)
	(cd build && git init && ( git checkout -b gh-pages || git checkout gh-pages ))
	(cd build && \
	 git add markdown/* && \
	 git add graphics/* && \
	 git add _config.yml index.md && \
	 git commit -m "Publishing" && \
	 git push -f git@github.com:matcom/compilers.git gh-pages)

clean:
	rm -rf $(BUILD_DIR)

dependencies:
	pip install pweave
	pip install panflute
	apt install pandoc
	apt install inkscape
