from .models import UploadedFile
import pynamodb.exceptions


def db_get_file(id, user) -> UploadedFile:
    try:
        file = UploadedFile.get(id)
    except pynamodb.exceptions.DoesNotExist:
        return None
    if not file:
        return None
    # allow other users fetching the file if the file is marked "public"
    if not file.public and file.user_id != user:
        return None
    return file
