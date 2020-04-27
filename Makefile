build:
	set -e
	printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

	# Build the project.
	hugo -t slim

	cd public
	git add .
	git commit -m "rebuilding site $(date)"

	# Push source and build repos.
	git push origin master
