from django.conf.urls import patterns, include, url
import settings
from .apps.core import views as core

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'Nimbus.views.home', name='home'),
    # url(r'^Nimbus/', include('Nimbus.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^admin/', include(admin.site.urls)),
    url(r"^$", core.index, name="index"),
    url(r"^login$", core.login_view.as_view(), name="login"),
    url(r"^logout$", core.logout_view, name="logout"),
)

if settings.SHOW_DEBUG_TOOLBAR:
    import debug_toolbar

    urlpatterns += patterns("",
        url(r"^__debug__/", include(debug_toolbar.urls)),
    )
