# Debug AWS Workload Federation

1. Create an IAM role in AWS
2. Setup Workload Identity Federation in GCP
3. download a configuration file from GCP console
4. open CloudShell in AWS console
   1. `aws sts get-caller-identity` to get your Arn
   2. upload the configuration file
   3. `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/configuration/file` in CloudShell
5. modify IAM Role assume policy to allow the CloudShell current user(you) can assume the IAM Role
6. Debug connection between GCP and AWS in CloudShell
   1. `aws sts assume-role --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/$ROLE_NAME_TO_ASSUME --role-session-name $SESSION_NAME`
   2. export `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_SESSION_TOKEN`
   3. `pip install google-auth`
   4. Open Python REPL
      1. `import google.auth`
      2. `from google.auth.transport.requests import Request`
      3. Run `credentials = google.auth.default(scopes=["https://www.googleapis.com/auth/cloud-platform"])[0]` to initialize credentials instance
      4. Run `credentials.token` to get token value

## Reference
- https://google.aip.dev/auth/4110
- https://github.com/googleapis/google-api-python-client/blob/main/docs/logging.md
- https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#aws_1