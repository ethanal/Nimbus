from rest_framework import serializers
from subdomains.utils import reverse
from nimbus.apps.media.models import Media


def _get_target_file_url(obj):
    if obj.target_file:
        return obj.raw_url
    return ""


def _get_share_url(obj):
    return reverse("share",
                   subdomain=None,
                   kwargs={"url_hash": obj.url_hash})


class MediaSerializer(serializers.ModelSerializer):
    target_file_url = serializers.SerializerMethodField("get_target_file_url")
    share_url = serializers.SerializerMethodField("get_share_url")

    def get_target_file_url(self, obj):
        return _get_target_file_url(obj)

    def get_share_url(self, obj):
        return _get_share_url(obj)

    class Meta:
        model = Media
        fields = ("url_hash",
                  "share_url",
                  "name",
                  "target_url",
                  "target_file",
                  "target_file_url",
                  "view_count",
                  "upload_date",
                  "media_type")


class ViewCreatedFileSerializer(serializers.ModelSerializer):
    target_file_url = serializers.SerializerMethodField("get_target_file_url")
    share_url = serializers.SerializerMethodField("get_share_url")

    def get_target_file_url(self, obj):
        return _get_target_file_url(obj)

    def get_share_url(self, obj):
        return _get_share_url(obj)

    class Meta:
        model = Media
        fields = ("url_hash",
                  "share_url",
                  "name",
                  "target_file",
                  "target_file_url",
                  "upload_date",
                  "media_type")


class CreateLinkSerializer(serializers.ModelSerializer):
    target_url = serializers.URLField(max_length=2048)

    class Meta:
        model = Media
        fields = ("target_url",)


class ViewCreatedLinkSerializer(serializers.ModelSerializer):
    share_url = serializers.SerializerMethodField("get_share_url")

    def get_share_url(self, obj):
        return _get_share_url(obj)

    class Meta:
        model = Media
        fields = ("url_hash",
                  "share_url",
                  "target_url",
                  "upload_date")
