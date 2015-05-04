![Docker](images/underconstruction.jpg)

# Docker Docs on Hugo

This is an opensource, iterative project for redesigning the Docker documentation environment. This environment is used to author both Docker's free, open source platform and Docker's commercial products. The documentationenvironment is composed of:

<table>
  <tr>
    <th>Component</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>Authoring tools</td>
    <td>The software used to write the documentation.  This includes ancillary tools such as spell checkers, grammar checkers, and screenshot tools. </td>
  </tr>
  <tr>
    <td>Site design</td>
    <td>The look-and-feel of the documentation as it displays in a website.  Typically, this is the assets used to produce the site.  It also includes ancillary tools and utilities such as source control, CMS, and search APIs.</td>
  </tr>
  <tr>
    <td>Build tooling</td>
    <td>The software and scripts required to compile the documentation source files and make it ready for presentation. Typically, this is a package for generating output from documentation source files. This also includes ancillary tools and utilities such as presentation platforms, and so forth. </td>
  </tr>
  <tr>
    <td>Release tooling</td>
    <td>This is the software and scripts used to release the software for public consumption.  </td>
  </tr>
</table>

## Project hard constraints

This project has the following top-level constraints:

- Implement a new Markdown generator before Dockercon
- Update the look-n-feel by Dockercon
- Improve the build system by Dockercon

This is a fast-moving project which has implications for both Docker's open source and commercial endeavors. 

Like all Docker open-source projects, this project aims to be transparent and accessible. Given the hard constraints and the cross-over with a company event, we expect it will be necessary to make decisions and take actions in ways that are non-standard with typical Docker OS projects.

This is *software* though, not **stone**; we can always revisit, refine, and revise later.

## Project Requirements

See the detailed requirements in [project/REQUIREMENTS.md](project/REQUIREMENTS.md).

## Run the Project

Currently, the build is prototyping a simple container with Hugo. We are running various configurations for the larger repo; symlinks, copying, and so forth to see how best to incorporate documentation from sub project documentation.  Hugo is run by hand manually, inside the container for simple troubleshooting.

To build the Dockerfile:

		docker build --rm --force-rm -t docker:docs .

To run the container and mount the `content` from this project:

		docker run --rm -it -P -v ${PWD}:/usr/src/docs/ docker:docs
		
To run the Hugo server in its simplest form:
		
		hugo server -w