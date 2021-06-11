#!/usr/bin/env bash
DEPLOYMENT="dev"
AWS_REGION="eu-west-2"
AWS_ACCOUNT_ID="774700391246"
ECR_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

APP_IMAGE_NAME="$ECR_URL/filestore-$DEPLOYMENT-app:latest"
NGINX_IMAGE_NAME="$ECR_URL/filestore-$DEPLOYMENT-nginx:latest"

pushd python || exit
rm -r staticfiles
python manage.py collectstatic --no-input
popd || exit

rm -r nginx/staticfiles
mv python/staticfiles nginx/

aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_URL"

docker build -t "$APP_IMAGE_NAME" python
docker build -t "$NGINX_IMAGE_NAME" nginx
docker push "$APP_IMAGE_NAME"
docker push "$NGINX_IMAGE_NAME"
