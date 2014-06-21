from django.conf.urls import patterns, include, url
from nimbus import settings


def debug_urls():
    if settings.SHOW_DEBUG_TOOLBAR:
        import debug_toolbar

        return patterns("",
            url(r"^__debug__/", include(debug_toolbar.urls)),
        )
    return []
