from django.contrib import admin
from .models import Media



class MediaAdmin(admin.ModelAdmin):
    fields = ("name",
              "target_url",
              "target_file",
              "user",
              "syntax_highlighted")
    list_display = ("id",
                    "url_hash",
                    "name",
                    "user",
                    "target_url",
                    "target_file",
                    "upload_date",
                    "view_count",
                    "media_type")
    list_filter = ("media_type",)
    search_fields = ("id",
                     "url_hash",
                     "name",
                     "user__username",
                     "target_url",
                     "target_file",
                     "upload_date",
                     "view_count",
                     "media_type")

admin.site.register(Media, MediaAdmin)
