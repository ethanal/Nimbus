from rest_framework import generics, views
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser
from nimbus.apps.media.models import Media
from nimbus.apps.media.serializers import MediaSerializer
from .exceptions import InvalidFilter
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt


@api_view(("GET",))
def api_root(request, format=None):
    """Welcome to the Nimbus API!
    Documentation can be found at [github.com/nimbus](http://github.com/ethanal/nimbus)
    """

    return Response("Documentation can be found at http://github.com/ethanal/nimbus")


class MediaList(generics.ListAPIView):
    serializer_class = MediaSerializer

    def get_queryset(self):
        user = self.request.user
        return Media.objects.filter(user=user)


class TypeFilteredMediaList(generics.ListAPIView):
    serializer_class = MediaSerializer

    def get(self, request, *args, **kwargs):
        valid_types = [m[0] for m in Media.MEDIA_TYPES]
        if self.kwargs["media_type"] not in valid_types:
            detail = "Invalid media type. Valid options are ({}).".format(", ".join(valid_types))
            raise InvalidFilter(detail=detail)
        return super(TypeFilteredMediaList, self).get(request, *args, **kwargs)

    def get_queryset(self):
        user = self.request.user
        return Media.objects.filter(user=user, media_type=self.kwargs["media_type"])


class MediaDetail(generics.RetrieveAPIView):
    serializer_class = MediaSerializer
    lookup_field = "url_hash"

    def get_queryset(self):
        user = self.request.user
        return Media.objects.filter(user=user)


class AddFile(views.APIView):
    parser_classes = (MultiPartParser,)

    def post(self, request, format=None):
        f = request.FILES["file"]
        m = Media(name=f.name, user=request.user, target_file=f)
        m.save()
        return Response(m.url_hash, status=204)
