import logging
from django.http.response import HttpResponse, JsonResponse
from django.views.decorators.http import require_GET, require_POST
from django.shortcuts import render, redirect
from django.conf import settings
from botocore.exceptions import ClientError
from .models import UploadedFile
from .forms import LoginForm, FileUploadForm
from .utils import db_get_file

import uuid
import boto3
import django.contrib.auth as auth


def _succeed() -> dict:
    return {"result": "success"}


def _fail(error: str) -> dict:
    return {"result": "failure", "error": error}


def _handle_login_form(request) -> dict:
    """
    Parses the login form and authenticates the user with our backend
    """
    form = LoginForm(request.POST)
    if not form.is_valid():
        return _fail("Invalid input")

    user = auth.authenticate(
        request,
        username=form.cleaned_data["username"],
        password=form.cleaned_data["password"],
    )
    if user is None:
        return _fail("Authentication failed")

    auth.login(request, user)
    return _succeed()


def _handle_file_upload(request) -> dict:
    """
    Uploads the file from the request into S3, and stores a record of the file in DynamoDB
    """

    form = FileUploadForm(request.POST, request.FILES)
    if not form.is_valid():
        return _fail("Invalid input")

    file = form.cleaned_data["file"]
    file_id = str(uuid.uuid4())
    client = boto3.client("s3")

    try:
        client.upload_fileobj(file, settings.API_S3_BUCKET, f"{file_id}/{file.name}")
    except ClientError:
        return _fail("S3 returned an exception")

    model = UploadedFile()
    model.id = file_id
    model.public = False
    model.user_id = str(request.user.sub)
    model.filename = file.name
    model.save()

    return _succeed()


def index(request):
    """
    Displays a list of files if the user is authenticated, or if not, a login page.
    """
    if request.user.is_authenticated:
        if request.method == "GET":
            results = UploadedFile.scan(
                (UploadedFile.public == True)  # noqa: E712
                | (UploadedFile.user_id == str(request.user.sub))  # noqa: W503
            )
            view_results = map(lambda f: f.to_dict(), results)

            return render(request, "index.html", {"results": view_results})
        else:
            return HttpResponse(status=400)
    else:
        if request.method == "GET":
            # show login form
            return render(request, "login.html")
        else:
            result = _handle_login_form(request)
            if "error" in result:
                return render(request, "login.html", result)
            else:
                return redirect("index")


@require_POST
def login(request):
    """
    Logs a user in.
    """
    return JsonResponse(_handle_login_form(request))


@require_GET
def logout(request):
    """
    Logs a user out.
    """
    auth.logout(request)
    return redirect("index")


def upload(request):
    """
    Uploads a file.
    """
    if request.method == "GET":
        if not request.user.is_authenticated:
            return redirect("index")
        return render(request, "upload.html")
    elif request.method == "POST":
        if not request.user.is_authenticated:
            return HttpResponse(status=403)
        return JsonResponse(_handle_file_upload(request))
    else:
        return HttpResponse(status=400)


def file(request, id):
    """
    Performs operations on the file with the specified ID.
    """
    if not request.user.is_authenticated:
        return redirect("index")

    if request.method == "GET":
        file = db_get_file(id, str(request.user.sub))
        if not file:
            return HttpResponse(status=404)
        result = file.to_dict()

        # generate presigned download url
        client = boto3.client("s3")
        try:
            response = client.generate_presigned_url(
                "get_object",
                Params={"Bucket": settings.API_S3_BUCKET, "Key": file.s3_key()},
                ExpiresIn=600,
            )

            result["url"] = response
        except ClientError:
            logging.exception()
            return JsonResponse(_fail("Failed to generate the presigned S3 URL"))

        return JsonResponse(result)
    elif request.method == "DELETE":
        file = db_get_file(id, str(request.user.sub))
        if not file:
            return HttpResponse(status=404)

        # delete file from s3
        client = boto3.client("s3")
        try:
            response = client.delete_object(
                Bucket=settings.API_S3_BUCKET, Key=file.s3_key()
            )
        except ClientError:
            logging.exception()
            return JsonResponse(_fail("Failed to delete the file from S3"))

        # delete dyanmodb entry
        file.delete()

        return JsonResponse(_succeed())
    else:
        return HttpResponse(status=400)
