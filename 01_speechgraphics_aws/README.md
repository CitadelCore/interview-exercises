## Filestore Example Application

This is an example application written as part of an AWS tech test.
The API was written nearly exactly to specification. Were this a real production application, I would opt to move the API endpoints out of the same namespace as the views, possibly into Django REST Framework.

Things that I have implemented:
- All the base requirements
- Public S3 download link generation
- Private DynamoDB items (capable of also being public)
- Infrastructure defined via Terraform
- Continuous integration via GitLab pipelines
- Deployment on the real AWS cloud

Things that I would have done with more time:
- Unit tests
- Continuous deployment
- OpenAPI API definition
- Postman integration tests

### API endpoints
- `GET /`: displays a list of DynamoDB items in a web frontend, or a login page if not authenticated
- `POST /`: logs a user in with provided credentials if not authenticated
- `POST login/`: logs a user in with provided credentials and returns a JSON response
- `POST logout/`: logs a user out and initiates a redirect to /
- `GET upload/`: (if authenticated) returns a web form where a user can select a file to upload
- `POST upload/`: (if authenticated) uploads the specified file
- `GET file/<id>`: (if authenticated) return information about the specified file, including the UUID, S3 key, filename, and presigned download URL
- `DELETE file/<id>`: (if authenticated) deletes the specified file
