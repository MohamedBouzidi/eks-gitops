terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.61.0"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_kms_key" "s3_sse_kms" {
  key_id = "alias/aws/s3"
}

data "aws_kms_key" "ecr_kms" {
  key_id = "alias/aws/ecr"
}

resource "aws_s3_bucket" "artifact_store" {
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_key.s3_sse_kms.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "artifact_store" {
  bucket = aws_s3_bucket.artifact_store.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ecr_repository" "main" {
  name                 = lower("${var.name}-app")
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = data.aws_kms_key.ecr_kms.arn
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "codebuild" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "codebuild.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild" {
  description = "Allow CodeBuild to build Docker image"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid      = "AccessCloudWatchLogs"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.artifact_store.arn}/*"
        Sid      = "AccessArtifactStore"
      },
      {
        Action   = "ecr:*"
        Effect   = "Allow"
        Resource = "${aws_ecr_repository.main.arn}"
        Sid      = "AccessContainerRepository"
      },
      {
        Action   = "ecr:GetAuthorizationToken"
        Effect   = "Allow"
        Resource = "*"
        Sid      = "AuthenticateContainerRepository"
      },
      {
        Action   = "codestar-connections:UseConnection"
        Effect   = "Allow"
        Resource = var.codestar_connection_arn
        Sid      = "UseCodeStarConnection"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild.arn
}

resource "aws_codebuild_project" "main" {
  name         = "${var.name}-main"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.main.name
    }

    environment_variable {
      name  = "MANIFEST_PATH"
      value = var.manifest_path
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yml")
  }
}

resource "aws_iam_role" "codepipeline" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "codepipeline.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy" "codepipeline" {
  description = "Allow CodePipeline to execute"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [aws_s3_bucket.artifact_store.arn, "${aws_s3_bucket.artifact_store.arn}/*"]
        Sid      = "AccessArtifactStore"
      },
      {
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Effect   = "Allow"
        Resource = aws_codebuild_project.main.arn
        Sid      = "StartCodeBuild"
      },
      {
        Action   = "codestar-connections:UseConnection"
        Effect   = "Allow"
        Resource = var.codestar_connection_arn
        Sid      = "UseCodeStarConnection"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline.arn
}

resource "aws_codepipeline" "main" {
  name     = "${var.name}-main"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifact_store.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["code"]
      configuration = {
        ConnectionArn        = var.codestar_connection_arn
        BranchName           = var.repository.branch
        FullRepositoryId     = join("/", [var.repository.owner, var.repository.name])
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      version         = "1"
      provider        = "CodeBuild"
      input_artifacts = ["code"]
      configuration = {
        ProjectName = aws_codebuild_project.main.id
      }
    }
  }
}
