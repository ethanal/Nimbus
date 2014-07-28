import mimetypes
import uuid
from pygments import highlight
from pygments.lexers import guess_lexer_for_filename
from pygments.formatters import HtmlFormatter
from django.db import models
from django.db.models.signals import post_save, pre_delete
from django.dispatch import receiver
from django.contrib.auth import get_user_model
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.core.validators import URLValidator
from rest_framework.authtoken.models import Token
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

    MEDIA_TYPES_PLURAL = (
        ("IMG", "Images"),
        ("URL", "Links"),
        ("TXT", "Text"),
        ("ARC", "Archives"),
        ("AUD", "Audio"),
        ("VID", "Video"),
        ("ETC", "Other")
    )

    _random_filename = lambda i, f: str(uuid.uuid4()).replace("-", "") + "/" + f

    url_hash = models.CharField(max_length=100, blank=True)
    name = models.CharField(max_length=500)
    target_url = models.URLField(max_length=2048, blank=True)
    target_file = models.FileField(upload_to=_random_filename, blank=True)
    view_count = models.IntegerField(default=0)
    upload_date = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey(User)
    media_type = models.CharField(max_length=3, choices=MEDIA_TYPES, blank=True)
    syntax_highlighted = models.TextField(blank=True)

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

    @property
    def raw_url(self):
        return self.target_file.storage.url(self.target_file.name)

    @staticmethod
    def guess_media_type(resource_name):
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

    def fill_syntax_highlighted(self, text):
        lexer = guess_lexer_for_filename(self.name, text)
        html = highlight(text, lexer, HtmlFormatter())
        self.syntax_highlighted = html
        self.save()

    def __unicode__(self):
        return self.name

    class Meta:
        verbose_name_plural = "Media"


@receiver(post_save, sender=Media)
def fill_auto_fields(sender, **kwargs):
    instance = kwargs.get("instance")

    fields = {}
    if not instance.media_type:
        fields["media_type"] = Media.guess_media_type(instance.name)
    if not instance.url_hash:
        fields["url_hash"] = url_hash_from_pk(instance.pk)

    if fields:
        for field, value in fields.items():
            setattr(instance, field, value)
        instance.save()


@receiver(pre_delete, sender=Media)
def delete_file_from_storage(sender, **kwargs):
    instance = kwargs.get("instance")

    if instance.target_file:
        instance.target_file.delete()


# No real better place to put this...
@receiver(post_save, sender=get_user_model())
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)
