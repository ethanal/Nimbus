from django.shortcuts import get_object_or_404
from django.template.loader import render_to_string
from rest_framework import generics, views, status, APIException
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser
from nimbus.apps.media.models import Media
from nimbus.apps.media.serializers import MediaSerializer, CreateLinkSerializer, ViewCreatedFileSerializer, ViewCreatedLinkSerializer


class URLHashParameterRequiredException(APIException):
    status_code = 400
    default_detail = "'url_hash' parameter required"


@api_view(("GET",))
def api_root(request):
    """Welcome to the Nimbus API!
    Documentation can be found at [github.com/ethanal/nimbus](http://github.com/ethanal/nimbus)
    """

    return Response("Documentation can be found at http://github.com/ethanal/nimbus")


class MediaList(generics.ListAPIView):
    serializer_class = MediaSerializer

    def get_queryset(self):
        user = self.request.user
        if "media_type" in self.request.QUERY_PARAMS:
            return Media.objects.filter(user=user, media_type=self.requeset.QUERY_PARAMS["media_type"])
        return Media.objects.filter(user=user)


class MediaDetail(generics.RetrieveAPIView):
    serializer_class = MediaSerializer

    def get_object(self):
        if "url_hash" not in self.request.QUERY_PARAMS:
            raise URLHashParameterRequiredException()

        queryset = Media.objects.filter(user=self.request.user)
        return get_object_or_404(queryset, {
            "url_hash": self.request.QUERY_PARAMS["url_hash"]
        })


class AddFile(views.APIView):
    parser_classes = (MultiPartParser,)

    def post(self, request):
        f = request.FILES.get("file", None)

        if not f:
            return Response(status=400)

        media_item = Media(name=f.name, user=request.user, target_file=f)
        media_item.save()
        if media_item.media_type == "TXT":
            text = f.file.getvalue()
            media_item.fill_syntax_highlighted(text)

        data = ViewCreatedFileSerializer(media_item).data

        if "include-html" in request.QUERY_PARAMS:
            context = {
                "media_item": media_item
            }
            html = render_to_string("nimbus/accounts/media_table_row.html", context)
            data["html"] = html

        return Response(data, status=201)


class AddLink(generics.CreateAPIView):
    serializer_class = CreateLinkSerializer

    def pre_save(self, obj):
        obj.user = self.request.user
        obj.name = obj.target_url

    def create(self, request, *args, **kwargs):
        response = super(AddLink, self).create(request, *args, **kwargs)
        if response.status_code == status.HTTP_201_CREATED:
            response.data = ViewCreatedLinkSerializer(self.object).data
        return response


@api_view(("POST",))
def delete_media(request):
    user = request.user
    ids = request.QUERY_PARAMS.getlist("id")
    Media.objects.filter(user=user, id__in=ids).delete()
    return Response(status=204)
