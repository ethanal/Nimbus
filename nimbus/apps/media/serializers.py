from rest_framework import serializers
from nimbus.apps.media.models import Media


class MediaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Media
        fields = ("url_hash",
                  "name",
                  "target_url",
                  "target_file",
                  "view_count",
                  "upload_date",
                  "media_type")
