from rest_framework.exceptions import APIException
from nimbus.apps.media.models import Media


class InvalidFilter(APIException):
    status_code = 400
    default_detail = "Invalid filter"
