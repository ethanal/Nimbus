from django.conf.urls import patterns, include, url
from django.contrib import admin
import nimbus.nimbus_core.views
from . import debug_urls


urlpatterns = debug_urls()

admin.autodiscover()

urlpatterns += patterns('',
    url(r'^admin/', include(admin.site.urls)),
)

urlpatterns += patterns('',
    url(r"^$", nimbus.nimbus_core.views.index, name="index"),
    url(r"^login$", nimbus.nimbus_core.views.login_view.as_view(), name="login"),
    url(r"^logout$", nimbus.nimbus_core.views.logout_view, name="logout"),
    url(r"^(?P<media_type>(images)|(links)|(text)|(archives)|(audio)|(video)|(other))$", nimbus.nimbus_core.views.dashboard_view, name="filter_media"),
    # url(r"^media/(?P<url_hash>[a-zA-Z0-9]+)$", nimbus_core.views.media_view, name="media_share_view"),
    url(r"^upload", nimbus.nimbus_core.views.upload_file, name="upload")
)
