This helper generates `packages/sltt_core/lib/src/server/server_urls.dart` with a single constant `kCloudDevUrl`.

Usage

- After deploying with Serverless (or otherwise obtaining the REST API id), run:

  npm --prefix packages/aws_backend run generate-server-urls

- The script checks for `.serverless/deploy-info.json` under `packages/aws_backend/.serverless` and an environment variable `SLTT_REST_API_ID`.

Notes

- If the script cannot find the REST API id, it will write a placeholder URL with `REPLACE_ME` in the hostname. In that case, set the env var and re-run:

  set SLTT_REST_API_ID=abcd1234
  npm --prefix packages/aws_backend run generate-server-urls

- The script is intentionally simple and doesn't try to call AWS APIs. It uses heuristics and optional deploy-info output to construct a canonical API Gateway URL shape:
  https://{restApiId}.execute-api.{region}.amazonaws.com/{stage}

- If your deployment uses a custom domain, update `packages/sltt_core/lib/src/server/server_urls.dart` manually or extend the script to support your DNS mapping.
