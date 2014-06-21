from django.conf.urls import patterns, url, include
from django.views.generic.base import RedirectView
from subdomains.utils import reverse
from nimbus import settings
from nimbus.apps import debug_urls
from . import views


urlpatterns = debug_urls()

urlpatterns += patterns('',
    url(r"^$", views.api_root, name="api_root"),
    url(r"^media$", views.MediaList.as_view(), name="media_list"),
    url(r"^media/filter_media_type/(?P<media_type>[A-Z]+)", views.MediaTypeFilteredMediaList.as_view(), name="media_filter"),
    url(r"^media/show/(?P<url_hash>[0-9a-zA-Z]+)", views.MediaDetail.as_view(), name="media_detail"),
    # url(r"^media/add_file", views.AddFile.as_view(), name="add_file"),
    # url(r"^media/add_link", view.AddLink.as_view(), name="add_link"),
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework')),
)
