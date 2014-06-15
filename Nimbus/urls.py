from django.conf.urls import patterns, include, url
from django.contrib import admin
from django.contrib.auth.models import Group
from django.contrib.sites.models import Site
import settings
import nimbus_core.views

admin.autodiscover()
admin.site.unregister(Group)
admin.site.unregister(Site)

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'nimbus.views.home', name='home'),
    # url(r'^nimbus/', include('nimbus.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^admin/', include(admin.site.urls)),
)

if settings.SHOW_DEBUG_TOOLBAR:
    import debug_toolbar

    urlpatterns += patterns("",
        url(r"^__debug__/", include(debug_toolbar.urls)),
    )


urlpatterns += patterns('',
    url(r"^$", nimbus_core.views.index, name="index"),
    url(r"^login$", nimbus_core.views.login_view.as_view(), name="login"),
    url(r"^logout$", nimbus_core.views.logout_view, name="logout"),
    url(r"^(?P<media_type>(images)|(links)|(text)|(archives)|(audio)|(video)|(other))$", nimbus_core.views.dashboard_view)
)
