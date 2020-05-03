build:
	# Build the project.
	hugo -t theme
	cd public
	git add .
	git commit -m "rebuilding site $(date)"
	git push -u origin master
	cd ..
