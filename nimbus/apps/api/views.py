from django.template.loader import render_to_string
from rest_framework import generics, views
from rest_framework.decorators import api_view
from rest_framework.renderers import JSONRenderer
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser
from nimbus.apps.media.models import Media
from nimbus.apps.media.serializers import MediaSerializer, LinkSerializer
from .exceptions import InvalidFilter


@api_view(("GET",))
def api_root(request):
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

    def post(self, request):
        f = request.FILES.get("file", None)

        if not f:
            return Response(status=400)

        text = f.file.getvalue()
        media_item = Media(name=f.name, user=request.user, target_file=f)
        media_item.save()
        if media_item.media_type == "TXT":
            media_item.fill_syntax_highlighted(text)

        data = MediaSerializer(media_item).data

        if "include-html" in request.QUERY_PARAMS:
            context = {
                "media_item": media_item
            }
            html = render_to_string("nimbus/accounts/media_table_row.html", context)
            data["html"] = html

        json = JSONRenderer().render(data)
        return Response(json, status=201)


class AddLink(generics.CreateAPIView):
    serializer_class = LinkSerializer

    def pre_save(self, obj):
        obj.user = self.request.user
        obj.name = obj.target_url
