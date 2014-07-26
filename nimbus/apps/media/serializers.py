from rest_framework import serializers
from subdomains.utils import reverse
from nimbus.apps.media.models import Media


class MediaSerializer(serializers.ModelSerializer):
    target_file_url = serializers.SerializerMethodField("get_target_file_url")
    share_url = serializers.SerializerMethodField("get_share_url")

    def get_target_file_url(self, obj):
        if obj.target_file:
            return obj.raw_url
        return ""

    def get_share_url(self, obj):
        return reverse("share",
                       subdomain=None,
                       kwargs={"url_hash": obj.url_hash})

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


class CreateLinkSerializer(serializers.ModelSerializer):
    target_url = serializers.URLField(max_length=2048)

    class Meta:
        model = Media
        fields = ("target_url",)


class ViewLinkSerializer(serializers.ModelSerializer):
    share_url = serializers.SerializerMethodField("get_share_url")

    def get_share_url(self, obj):
        return reverse("share",
                       subdomain=None,
                       kwargs={"url_hash": obj.url_hash})

    class Meta:
        model = Media
        fields = ("url_hash",
                  "share_url",
                  "target_url",
                  "upload_date",)
