.SILENT:

install: export_path reload_source

export_path:
	DIR=$(shell pwd)
	export PATH=${PATH}:$DIR

reload_source:
	$(source) ~/.bashrc
