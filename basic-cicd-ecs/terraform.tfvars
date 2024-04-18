region = "ap-southeast-1"

s3_file_storage           = "api-file-storage"
s3_codepipeline_artifacts = "api-codepipeline-artifacts"
codebuild_name            = "api-build"
codebuild_role_name       = "api-build-role"
codepipeline_name         = "api-pipeline"
codepipeline_role_name    = "api-pipeline-role"

vpc_name           = "aws-simple-api"
ecs_cluster_name   = "aws-simple-api"
ecs_service_name   = "aws-simple-api"
ecs_execution_role = "aws-simple-api-execution-role"
ecs_task_role      = "aws-simple-api-task-role"
ecr_name           = "aws-simple-api"

repository = {
  connection_arn = "arn:aws:codestar-connections:ap-southeast-1:637423502298:connection/1c504d8e-3a53-40b5-b685-3e934f24cf75"
  id             = "dungxtd/aws-simple-app"
  branch         = "master"
}


