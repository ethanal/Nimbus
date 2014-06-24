from django.conf.urls import patterns, url
from django.views.generic.base import RedirectView
from subdomains.utils import reverse
from nimbus import settings
from nimbus.apps import debug_urls
from nimbus.apps.media import views

urlpatterns = debug_urls()

urlpatterns += patterns('',
    url(r"^$", RedirectView.as_view(url=reverse("index", subdomain="account"))),
    url(r"^(?P<url_hash>[a-zA-Z0-9]+)$", views.share_view, name="share"),
    url(r"^m/(?P<path>.*)$", "django.views.static.serve", {"document_root": settings.MEDIA_ROOT, "show_indexes": False}, name="raw_media"),
)
