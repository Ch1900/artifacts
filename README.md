artifacts
=========

Travis CI Artifact thingy


### NAME
artifacts - manage your artifacts!

### USAGE
`artifacts [global options] command [command options] [arguments...]`

### COMMANDS
* `upload, u`  upload some artifacts!
* `help, h`  Shows a list of commands or help for one command

### GLOBAL OPTIONS
* `--log-format, -f`     log output format (text or json)
* `--debug, -D`        set log level to debug
* `--version, -v`    print the version
* `--help, -h`        show help

## upload

The upload commmand may be used to upload arbitrary files to an artifact
repository.  The only such artifact repository currently supported is
S3.  All of the required arguments may be provided as command line
arguments or environment variables.


### NAME
upload - upload some artifacts!

### USAGE
`command upload [command options] [arguments...]`

### DESCRIPTION
Upload a set of local paths to an artifact repository.  The paths may be
provided as either positional command-line arguments or as the `ARTIFACTS_PATHS`
environmental variable, which should be ';'-delimited.
Paths may be either files or directories.  Any path provided will be walked for
all child entries.  Each entry will have its mime type detected based first on
the file extension, then by sniffing up to the first 512 bytes via the net/http
function "DetectContentType".

### OPTIONS
* `--key, -k`         upload credentials key [`ARTIFACTS_KEY`] **REQUIRED**
* `--secret, -s`     upload credentials secret [`ARTIFACTS_SECRET`] **REQUIRED**
* `--bucket, -b`     destination bucket [`ARTIFACTS_BUCKET`] **REQUIRED**
* `--cache-control`     artifact cache-control header value [`ARTIFACTS_CACHE_CONTROL`]
* `--concurrency`     upload worker concurrency [`ARTIFACTS_CONCURRENCY`]
* `--permissions`     artifact access permissions [`ARTIFACTS_PERMISSIONS`]
* `--retries`         number of upload retries per artifact [`ARTIFACT_RETRIES`]
* `--target-paths, -t`     artifact target paths (';'-delimited) [`ARTIFACTS_TARGET_PATHS`]
* `--working-dir`     working directory [`PWD`, `TRAVIS_BUILD_DIR`]

### EXAMPLES

#### Example: logs and coverage

In this case, the key and secret are passed as command line flags and
the `log/` and `coverage/` directories are passed as positional path
arguments:

``` bash
artifacts upload \
  -k AKIT339AFIY655O3Q9DZ \
  -s 48TmqyraUyJ7Efpegi6Lfd10yUskAMB0G2TtRCX1 \
  log/ coverage/
```

The same operation using environmental variables would look like this:

``` bash
export ARTIFACTS_KEY="AKIT339AFIY655O3Q9DZ"
export ARTIFACTS_SECRET="48TmqyraUyJ7Efpegi6Lfd10yUskAMB0G2TtRCX1"
export ARTIFACTS_PATHS="log/;coverage/"

artifacts upload
```

#### Example: untracked files

In order to upload all of the untracked files (according to git), one
might do this:

``` bash
artifacts upload \
  -k AKIT339AFIY655O3Q9DZ \
  -s 48TmqyraUyJ7Efpegi6Lfd10yUskAMB0G2TtRCX1 \
  $(git ls-files -o)
```

The same operation using environmental variables would look like this:

``` bash
export ARTIFACTS_KEY="AKIT339AFIY655O3Q9DZ"
export ARTIFACTS_SECRET="48TmqyraUyJ7Efpegi6Lfd10yUskAMB0G2TtRCX1"
export ARTIFACTS_PATHS="$(git ls-files -o | tr "\n" ";")"

artifacts upload
```
