target = a-position-allocation-approach-to-the-scheduling-of-beb-charging.pdf	# Name of file
src   := $(shell find . -type f -name "*.tex")					# Source files

all: $(target)

clean:
	@rm -f $(target)
	@latexmk -c $(src)

$(target) : $(src)
	@latexmk -bibtex -pdf main.tex
	@[ -f main.pdf ] && mv main.pdf $(target)
