from django.conf.urls import patterns, url, include
from nimbus.apps import debug_urls
from . import views


urlpatterns = debug_urls()

urlpatterns += patterns('',
    url(r"^$", views.api_root, name="api_root"),
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework')),
    url(r"^media$", views.MediaList.as_view(), name="media_list"),
    url(r"^media/filter_media_type/(?P<media_type>[A-Z]+)", views.TypeFilteredMediaList.as_view(), name="filter_media_api"),
    url(r"^media/show", views.MediaDetail.as_view(), name="media_detail"),
    url(r"^media/add_file", views.AddFile.as_view(), name="add_file"),
    url(r"^media/add_link", views.AddLink.as_view(), name="add_link"),
    url(r"^media/delete", views.DeleteMedia.as_view(), name="delete_media"),
)
