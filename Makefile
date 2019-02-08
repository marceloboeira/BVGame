NPM ?= `which npm`
WS ?= `which ws`
LOCAL_PORT ?= 1928
ELM ?= `which elm`
ELM_TEST ?= `which elm-test`
APPLICATION_ENTRYPOINT ?= src/Application.elm
DIST_FOLDER = `pwd`/dist

.PHONY: setup
setup:
	@$(NPM) install -g local-web-server elm

.PHONY: build
build:
	@$(ELM) make $(APPLICATION_ENTRYPOINT) --output $(DIST_FOLDER)/assets/application.js --optimize

.PHONY: test
test:
	@$(ELM_TEST)

.PHONY: test_watch
test_watch:
	@$(ELM_TEST) --watch

.PHONY: run
run:
	@$(WS) -d $(DIST_FOLDER) -p $(LOCAL_PORT) -o
