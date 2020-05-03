build:
	# Build the project.
	hugo
	cd public \
	  && git add . \
	  && git commit -m "rebuilding site $(date)" \
	  && git push -u origin HEAD
	git add . \
	  && git commit -m "rebuilding site $(date)" \
	  && git push -u origin HEAD
