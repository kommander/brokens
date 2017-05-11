VERSION = $(shell node -pe 'require("./package.json").version')

usage:
	@echo ''

	@echo ''

	@echo 'Core tasks                       : Description'
	@echo '--------------------             : -----------'
	@echo 'make dev                         : Setup repository for development (install, hooks)'
	@echo 'make lint                        : Run linter'
	@echo 'make test                        : Run tests'
	@echo 'make coverage                    : Create test coverage report to ./coverage'

	@echo ''

	@echo 'Additional tasks                 : Description'
	@echo '--------------------             : -----------'
	@echo 'make hooks                       : Creates git hooks to run tests before a push (done by make dev)'
	@echo 'make setup                       : Install all necessary dependencies'
	@echo 'make report                      : Opening default browser with coverage report.'

	@echo ''

	@echo 'Release tasks                 		: Description'
	@echo '--------------------             : -----------'
	@echo 'make specs                       : Run tests and put the results into the specs file'
	@echo 'make release                     : Publish version-tag matching package.json'
	@echo 'make release-patch               : Increment package version 0.0.1 -> 0.0.2 then release'
	@echo 'make release-minor               : Increment package version 0.1.0 -> 0.2.0 then release'
	@echo 'make release-major               : Increment package version 1.0.0 -> 2.0.0 then release'
	@echo 'make prerelease-alpha            : Increment version 0.5.0 -> 0.5.1-alpha.0 -> 0.5.1-alpha.1 ...'
	@echo 'make prerelease-beta             : Increment version 0.5.0 -> 0.5.1-beta.0 -> 0.5.1-beta.1 ...'
	@echo 'make prerelease-rc               : Increment version 0.5.0 -> 0.5.1-rc.0 -> 0.5.1-rc.1 ...'
	@echo '                                   (should use ´make npm-config´ before)'

	@echo ''
# -
help: usage

test:
	@echo 'Checking behaviour for version '$(VERSION)'.'
	@./node_modules/.bin/mocha $(TEST_FOLDERS) \
		--require should \
		--require "./dev/test.inject.js" \
		--check-leaks \
		--recursive \
		--reporter spec
.PHONY: test

travis:


report: coverage
	@echo 'Opening default browser with coverage report.'
	@open ./coverage/lcov-report/index.html

coverage:
	@echo 'Behaviour for Broken '$(VERSION)'.'
	@node ./node_modules/istanbul/lib/cli.js cover \
	./node_modules/.bin/_mocha -- $(TEST_FOLDERS) --require should --require "./dev/test.inject.js" --recursive --reporter spec
.PHONY: coverage

mincov: coverage
	@node ./node_modules/istanbul/lib/cli.js check-coverage --statements 90 --functions 90 --lines 90 --branches 90
.PHONY: mincov

specs:
	@echo 'Creating specs file from tests.'
	make  mincov > specs
	@echo 'Done.'
.PHONY: specs

coveralls:
	@node ./node_modules/istanbul/lib/cli.js cover ./node_modules/mocha/bin/_mocha --report lcovonly -- --recursive -R spec && cat ./coverage/lcov.info | ./node_modules/coveralls/bin/coveralls.js && rm -rf ./coverage
.PHONY: coveralls

# development should happen under production env, but we need some tools
setup:
	@echo "Installing Development dependencies."
	@NODE_ENV=development npm install --only=dev --no-shrinkwrap
.PHONY: setup

lint:
	@node ./node_modules/eslint/bin/eslint.js ./**/*.js ./**/**/*.js ./**/*.spec.js --quiet
	@echo "ESLint done."
.PHONY: lint

hooks:
	@echo "Setting up git hooks."
	cp ./dev/module.pre-push.sh ./.git/hooks/pre-push
	chmod +x ./.git/hooks/pre-push
.PHONY: hooks

clean:
	@echo "Housekeeping..."
	rm -rf ./node_modules
	rm -rf ./coverage
	@echo "Clean."
.PHONY: clean

dev: clean setup hooks lint mincov

release-patch: NEXT_VERSION = $(shell node -pe 'require("semver").inc("$(VERSION)", "patch")')
release-minor: NEXT_VERSION = $(shell node -pe 'require("semver").inc("$(VERSION)", "minor")')
release-major: NEXT_VERSION = $(shell node -pe 'require("semver").inc("$(VERSION)", "major")')
prerelease-alpha: NEXT_VERSION = $(shell node -pe 'require("semver").inc("$(VERSION)", "prerelease", "alpha")')
prerelease-beta: NEXT_VERSION = $(shell node -pe 'require("semver").inc("$(VERSION)", "prerelease", "beta")')
prerelease-rc: NEXT_VERSION = $(shell node -pe 'require("semver").inc("$(VERSION)", "prerelease", "rc")')
release-patch: release
release-minor: release
release-major: release
prerelease-alpha: release
prerelease-beta: release
prerelease-rc: release

release: specs
	@printf "Current version is $(VERSION). This will publish version $(NEXT_VERSION). Press [enter] to continue." >&2
	@read
	@node -e '\
		var j = require("./package.json");\
		j.version = "$(NEXT_VERSION)";\
		var s = JSON.stringify(j, null, 2);\
		require("fs").writeFileSync("./package.json", s);'
		@git commit package.json specs -m 'Version $(NEXT_VERSION)'
		@git tag -a "v$(NEXT_VERSION)" -m "Version $(NEXT_VERSION)"
	@git push --tags origin HEAD:master
	npm publish
.PHONY: release release-patch release-minor release-major
