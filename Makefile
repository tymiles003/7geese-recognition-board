dist:
	@mkdir dist
	@cp index.html dist/index.html
	mkdir dist/js
	@cake uglify
	@cp -r bin dist/bin

	@mkdir dist/jam
	@cp require.js dist/require.js

	@echo "Created a distributable version."

clean:
	@rm -f require.js
	@rm -rf bin
	@rm -rf dist
	@rm -rf app/bin
	
	@echo "All build files removed."