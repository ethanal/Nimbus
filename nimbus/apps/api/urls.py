from django.conf.urls import url, include
from nimbus.apps import debug_urls
from . import views


urlpatterns = debug_urls()

urlpatterns += [
    url(r"^$", views.api_root, name="api_root"),
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework')),
    url(r'^api-token-auth$', 'rest_framework.authtoken.views.obtain_auth_token'),
    url(r"^media/list$", views.MediaList.as_view(), name="media_list"),
    url(r"^media/show$", views.MediaDetail.as_view(), name="media_detail"),
    url(r"^media/add_file$", views.AddFile.as_view(), name="add_file"),
    url(r"^media/add_link$", views.AddLink.as_view(), name="add_link"),
    url(r"^media/delete$", views.delete_media, name="delete_media"),
]
