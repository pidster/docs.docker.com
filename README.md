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
    <td>The look-and-feel of the documentation as it displays in a website.  Typically, this is the assets used to produce the site.  It also includes ancillary tools and utilities such as source control, search APIs,</td>
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

Like all Docker open-source projects, this project aims to be visible and accessible. Given the hard constraints, we expect it will be necessary to make decisions without the typical community review.

This is software though, not stone; we can always revisit and revise later.

## Project requirements

Given the constraints, we have defined requirements for each component. *Must have* requirements are needed for the project to be a success. **Nice to have** are required to be stellar. And **Wishlist** requirements are not likely.

### Authoring tooling requirements

The software used to write the documentation.  This includes ancillary tools such as spell checkers, grammar checkers, and screenshot tools. 

#### Must have requirements

- The tooling should be free, easy to learn, easy to use, and widely supported.
- Documentation source should be kept with the project/product code.
- Authoring should not require special tools or complex configurations.

- Authors should be able to view a contribution in context of the larger documentation set.
- Authors should be able to create links between documents in different GitHub projects or products.

#### Nice to have requirements

- Code needed to generate from Markdown should not appear in repository display 


#### Wishlist items

## Site design requirements


#### Must have requirements

- Documentation should 

#### Nice to have requirements

- Display previous versions of the documentation 

#### Wishlist requirements
 
 
### Build tooling

The software and scripts required to compile the documentation source files and make it ready for presentation. Typically, this is a package for generating output from documentation source files. This also includes ancillary tools and utilities such as presentation platforms, and so forth.

#### Must have requirements

- Authors should be able to both preview what they write in the same format as the final website. 

### Nice to have requirements

- Documentation should display well in repository and on a static site.


### Release tooling



Run to build

		docker build --rm --force-rm -t docker:docs .


		docker run --rm -it -P -v ${PWD}:/usr/src/docs/ docker:docs
		
To run the Hugo server in its simplest form:
		
		hugo server -w