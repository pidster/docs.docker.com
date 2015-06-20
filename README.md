# README 

This project is builds and releases the documentation for all of Docker &ndash; both open source and commercial. 

## Prerequisites
  
 The build system allows you to build any public or private repo. To build a
 private repo, the build system requires your GitHub username and an access
 token. If you don't have an access token, you can create one by following
 [Creating an access token for command-line
 use](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).
   
 Your system should have a recent installation of both Docker Engine and Docker
 Compose.  See the [installation procedures](http://docs.docker.com/) for
 details on how to install these.
 
 Finally, it is convenient to have the [AWS command line
 tools](http://aws.amazon.com/cli/) installed. This is not required though.

## Quickstart publish 

1. Clone the `docs.docker.com` repository.
    
2. Change to your local `docs.docker.com` repository.

3. If you are releasing a new version, edit the `VERSION` file and set the version.
  
    The build system uses the version to identify the subfolder on S3 representing the released material, for example, the `AWS_S3_BUCKET/v1.7` folder.
    
4. Edit the `all-projects.yml` file and configure one or more `projects` to build.

      | Value       | Description                                                                                                             |
      |-------------|-------------------------------------------------------------------------------------------------------------------------|
      | `org`       | GitHub username or team name.                                                                                           |
      | `ref`       | Branch or tag name.                                                                                                     |
      | `path`      | Location in repository to pull from.  To pull an entire repository from the root directory, specify `!!null` as a path. |
      | `repo_name` | The name of the repository to pull. If you don't specify this value, then you must specify `name`.                      |
      | `name`      | Name of the destination directory in the container. The build system copies into a folder by this name.                 |
      | `target`    | The subdirectory in the container the build creates so the build creates `target`/`name` in the container.              |
      | `ignores`   | Specifies files / folders to ignore.                                                                                    |

5. Set your environment variables

        $ export AWS_ACCESS_KEY_ID=AKIAIKGKXQ3QTG3QY1SY
        $ export AWS_SECRET_ACCESS_KEY=qFlobtw3yYXdtEppahJAZKoNcDUXleTKB23kFR6c
        $ export AWS_S3_BUCKET=docs-manthony
        $ export GITHUB_USERNAME=moxiegirl
        $ export GITHUB_TOKEN=1077107f8a57cec307f7355a1ac22ecc4d5223dc
    
  The above are example values of course. You'll need to use valid values to publish.  
    
6. Clean any old images `make clean` from your system.

7. Build the necessary images used by the system.

        $ make build-images

8. Release to the subfolder (created if it doesn't exist).

        $ make release     
        
9. Optionally, check for new or updated bucket.

        $ aws s3 ls s3://$AWS_S3_BUCKET/
                                   PRE article-img/
                                   PRE articles/
                                   PRE compose/
                                   PRE css/
                                   PRE dist/
                                   PRE docker-hub-enterprise/
                                   PRE docker-hub/
        ...snip...
                                   PRE userguide/
                                   PRE v1.7/
                                   PRE windows/

10. Upload the content to the bucket root.

        $ RELEASE_LATEST=1 make release 
