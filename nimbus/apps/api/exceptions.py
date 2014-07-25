from rest_framework.exceptions import APIException


class InvalidFilter(APIException):
    status_code = 400
    default_detail = "Invalid filter"
