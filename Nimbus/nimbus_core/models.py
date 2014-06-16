import mimetypes
import uuid
from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.core.validators import URLValidator
from .utils import url_hash_from_pk


class Media(models.Model):
    MEDIA_TYPES = (
        ("IMG", "Image"),
        ("URL", "Link"),
        ("TXT", "Text"),
        ("ARC", "Archive"),
        ("AUD", "Audio"),
        ("VID", "Video"),
        ("ETC", "Other")
    )
    _random_filename = lambda i, f: str(i.user.id) + "/" + str(uuid.uuid4())

    url_hash = models.CharField(max_length=100, blank=True)
    name = models.CharField(max_length=500)
    target_url = models.URLField(max_length=2048, blank=True)
    target_file = models.FileField(upload_to=_random_filename, blank=True)
    view_count = models.IntegerField(default=0)
    upload_date = models.DateField(auto_now_add=True)
    user = models.ForeignKey(User)
    media_category = models.CharField(max_length=3, choices=MEDIA_TYPES, blank=True)

    # all prefixed by "application/"
    ARCHIVE_MIME_TYPES = ["x-cpio",
                          "x-shar",
                          "x-tar",
                          "x-bzip2",
                          "x-gzip",
                          "x-lzip",
                          "x-lzma",
                          "x-lzop",
                          "x-xz",
                          "x-compress",
                          "x-compress",
                          "x-7z-compressed",
                          "x-ace-compressed",
                          "x-astrotite-afa",
                          "x-alz-compressed",
                          "vnd.android.package-archive",
                          "x-arj",
                          "x-b1",
                          "vnd.ms-cab-compressed",
                          "x-cfs-compressed",
                          "x-dar",
                          "x-dgc-compressed",
                          "x-apple-diskimage",
                          "x-gca-compressed",
                          "x-lzh",
                          "x-lzx",
                          "x-rar-compressed",
                          "x-stuffit",
                          "x-stuffitx",
                          "x-gtar",
                          "zip",
                          "x-zoo",
                          "x-par2"]

    @staticmethod
    def guess_media_category(resource_name):
        validator = URLValidator()
        try:
            validator(resource_name)
        except ValidationError:
            pass
        else:
            return "URL"

        top, sub = (mimetypes.guess_type(resource_name, strict=False)[0] or "/").split("/")
        if top == "image":
            return "IMG"
        if top == "text":
            return "TXT"
        if top == "audio":
            return "AUD"
        if top == "video":
            return "VID"
        if (top == "application") and (sub in Media.ARCHIVE_MIME_TYPES):
            return "ARC"
        return "ETC"

    def __unicode__(self):
        return "<{}, {}>".format(self.url_hash, self.name)

    class Meta:
        verbose_name_plural = "Media"


@receiver(post_save, sender=Media)
def fill_auto_fields(sender, **kwargs):
    post_save.disconnect(fill_auto_fields, sender=Media)
    instance = kwargs.get("instance")
    if not instance.media_category:
        instance.media_category = Media.guess_media_category(instance.name)
    if not instance.url_hash:
        instance.url_hash = url_hash_from_pk(instance.pk)
    instance.save()
    post_save.connect(fill_auto_fields, sender=Media)
