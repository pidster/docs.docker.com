# docs


Run to build

		docker build --rm --force-rm -t docker:docs .


		docker run --rm -it -P -v ${PWD}:/usr/src/docs/ docker:docs
		
To run the Hugo server in its simplest form:
		
		hugo server -w