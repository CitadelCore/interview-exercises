from django.contrib.auth.backends import BaseBackend
from django.conf import settings
from warrant import Cognito
from .models import CognitoUser
from typing import Any

import jwt
import logging


class CognitoBackend(BaseBackend):
    """
    Backend that authenticates users via Cognito
    """

    def _get_cognito(self, **kwargs) -> Cognito:
        """
        Returns an instance of the Cognito user pool client
        """
        return Cognito(
            settings.COGNITO_USER_POOL_ID, settings.COGNITO_CLIENT_ID, **kwargs
        )

    def get_user(self, user_id: str) -> CognitoUser:
        try:
            return CognitoUser.objects.get(pk=user_id)
        except CognitoUser.DoesNotExist:
            return None

    def authenticate(
        self, request: Any, username: str = None, password: str = None
    ) -> CognitoUser:
        instance = self._get_cognito(username=username)

        try:
            instance.admin_authenticate(password=password)
        except Exception:
            logging.exception("cognito admin_authenticate returned exception")
            return None

        # if we succeeded, we should have all of these attributes
        if not instance.id_token or not instance.access_token:
            return None

        # see if the user exists locally, if not, create it
        try:
            user = CognitoUser.objects.get(username=username)
        except CognitoUser.DoesNotExist:
            # decode the jwt token and extract the sub claim
            result = jwt.decode(
                instance.id_token,
                options={"verify_signature": False},
            )

            user = CognitoUser(username=username)
            user.sub = result["sub"]
            user.save()

        return user
