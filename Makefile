NPM ?= `which npm`
WS ?= `which ws`
LOCAL_PORT ?= 1928
ELM ?= `which elm`
ELM_TEST ?= `which elm-test`
ELM_FORMAT ?= `which elm-format`
HERE ?= `pwd`
DIST_FOLDER ?= $(HERE)/dist
SOURCE_FOLDER ?= $(HERE)/src
APPLICATION_ENTRYPOINT ?= $(SOURCE_FOLDER)/Application.elm
APPLICATION_OUTPUT ?= $(DIST_FOLDER)/assets/application.js

PIPELINE_FOLDER ?= $(HERE)/pipeline

.PHONY: setup_pipeline
setup_pipeline:
	@cd $(PIPELINE_FOLDER) && $(NPM) install

.PHONY: build_pipeline
build_pipeline:
	@cd $(PIPELINE_FOLDER) && $(NPM) run pipeline
	@cp $(PIPELINE_FOLDER)/output/*.json $(DIST_FOLDER)/data/

.PHONY: setup
setup: setup_pipeline build_pipeline
	@$(NPM) install -g local-web-server elm elm-test elm-format

.PHONY: format
format:
	@$(ELM_FORMAT) $(HERE) --upgrade --yes

.PHONY: format_check
format_check:
	@$(ELM_FORMAT) $(HERE) --validate

.PHONY: build
build:
	@$(ELM) make $(APPLICATION_ENTRYPOINT) --output $(APPLICATION_OUTPUT) --optimize

.PHONY: test
test: format_check
	@$(ELM_TEST)

.PHONY: test_watch
test_watch:
	@$(ELM_TEST) --watch

.PHONY: run
run:
	@$(WS) -d $(DIST_FOLDER) -p $(LOCAL_PORT) -o
