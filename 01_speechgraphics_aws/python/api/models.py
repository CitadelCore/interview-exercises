from pynamodb.models import Model
from pynamodb.attributes import BooleanAttribute, UnicodeAttribute
from django.contrib.auth.models import AbstractUser
from django.db.models.fields import UUIDField


class CognitoUser(AbstractUser):
    # sub claim returned by Cognito to uniquely identify the user
    sub = UUIDField(null=False)


class UploadedFile(Model):
    """
    A file uploaded by an end user.
    """

    class Meta:
        table_name = "filestore-dev-uploads"
        region = "eu-west-2"

    id = UnicodeAttribute(hash_key=True)
    public = BooleanAttribute()
    user_id = UnicodeAttribute()
    filename = UnicodeAttribute()

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "public": self.public,
            "user_id": self.user_id,
            "filename": self.filename,
        }

    def s3_key(self) -> str:
        return f"{self.id}/{self.filename}"
