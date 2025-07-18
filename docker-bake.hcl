variable "HUGO_ENV" {
  default = null
}

variable "DOCS_URL" {
  default = null
}

variable "DOCS_SITE_DIR" {
  default = "public"
}

variable "DRY_RUN" {
  default = null
}

variable "GITHUB_ACTIONS" {
  default = null
}

group "default" {
  targets = ["release"]
}

target "index" {
  # generate a new local search index
  target = "index"
  output = ["type=local,dest=static/pagefind"]
  provenance = false
}

target "release" {
  args = {
    HUGO_ENV = HUGO_ENV
    DOCS_URL = DOCS_URL
  }
  target = "release"
  output = [DOCS_SITE_DIR]
  provenance = false
}

group "validate" {
  targets = ["lint", "vale", "test", "unused-media", "test-go-redirects", "dockerfile-lint", "path-warnings", "validate-vendor"]
}

target "test" {
  target = "test"
  output = ["type=cacheonly"]
  provenance = false
}

target "lint" {
  target = "lint"
  output = ["type=cacheonly"]
  provenance = false
}

target "vale" {
  target = "vale"
  args = {
    GITHUB_ACTIONS = GITHUB_ACTIONS
  }
  output = ["./tmp"]
  provenance = false
}

target "unused-media" {
  target = "unused-media"
  output = ["type=cacheonly"]
  provenance = false
}

target "test-go-redirects" {
  target = "test-go-redirects"
  output = ["type=cacheonly"]
  provenance = false
}

target "dockerfile-lint" {
  call = "check"
}

target "path-warnings" {
  target = "path-warnings"
  output = ["type=cacheonly"]
}

#
# releaser targets are defined in hack/releaser/Dockerfile
# and are used for AWS S3 deployment
#

target "releaser-build" {
  context = "hack/releaser"
  target = "releaser"
  output = ["type=cacheonly"]
  provenance = false
}

variable "AWS_REGION" {
  default = ""
}
variable "AWS_S3_BUCKET" {
  default = ""
}
variable "AWS_S3_CONFIG" {
  default = ""
}
variable "AWS_CLOUDFRONT_ID" {
  default = ""
}
variable "AWS_LAMBDA_FUNCTION" {
  default = ""
}

target "_common-aws" {
  args = {
    DRY_RUN = DRY_RUN
    AWS_REGION = AWS_REGION
    AWS_S3_BUCKET = AWS_S3_BUCKET
    AWS_S3_CONFIG = AWS_S3_CONFIG
    AWS_CLOUDFRONT_ID = AWS_CLOUDFRONT_ID
    AWS_LAMBDA_FUNCTION = AWS_LAMBDA_FUNCTION
  }
  secret = [
    "id=AWS_ACCESS_KEY_ID,env=AWS_ACCESS_KEY_ID",
    "id=AWS_SECRET_ACCESS_KEY,env=AWS_SECRET_ACCESS_KEY",
    "id=AWS_SESSION_TOKEN,env=AWS_SESSION_TOKEN"
  ]
  provenance = false
}

target "aws-s3-update-config" {
  inherits = ["_common-aws"]
  context = "hack/releaser"
  target = "aws-s3-update-config"
  no-cache-filter = ["aws-update-config"]
  output = ["type=cacheonly"]
}

target "aws-lambda-invoke" {
  inherits = ["_common-aws"]
  context = "hack/releaser"
  target = "aws-lambda-invoke"
  no-cache-filter = ["aws-lambda-invoke"]
  output = ["type=cacheonly"]
}

target "aws-cloudfront-update" {
  inherits = ["_common-aws"]
  context = "hack/releaser"
  target = "aws-cloudfront-update"
  contexts = {
    sitedir = DOCS_SITE_DIR
  }
  no-cache-filter = ["aws-cloudfront-update"]
  output = ["type=cacheonly"]
}

variable "VENDOR_MODULE" {
  default = null
}

target "vendor" {
  target = "vendor"
  args = {
    MODULE = VENDOR_MODULE
  }
  output = ["."]
  provenance = false
}

target "validate-vendor" {
  target = "validate-vendor"
  output = ["type=cacheonly"]
}

variable "UPSTREAM_MODULE_NAME" {
  default = null
}
variable "UPSTREAM_REPO" {
  default = null
}
variable "UPSTREAM_COMMIT" {
  default = null
}

target "validate-upstream" {
  args {
    UPSTREAM_MODULE_NAME = UPSTREAM_MODULE_NAME
    UPSTREAM_REPO = UPSTREAM_REPO
    UPSTREAM_COMMIT = UPSTREAM_COMMIT
  }
  target = "validate-upstream"
  output = ["type=cacheonly"]
  provenance = false
}
