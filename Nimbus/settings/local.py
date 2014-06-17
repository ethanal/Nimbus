from fnmatch import fnmatch
import os
import logging
from .base import *

logger = logging.getLogger(__name__)

DEBUG = True
TEMPLATE_DEBUG = DEBUG

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": os.path.join(os.path.dirname(PROJECT_ROOT),
                             "testing_database.db"),
    }
}

SECRET_KEY = "crjl#r4(@8xv*x5ogeygrt@w%$$z9o8jlf7=25^!9k16pqsi!h"

class glob_list(list):
    """A list of glob-style strings."""

    def __contains__(self, key):
        """Check if a string matches a glob in the list."""
        for elt in self:
            if fnmatch(key, elt):
                return True
        return False

INTERNAL_IPS = glob_list([
    "127.0.0.1",
])

SHOW_DEBUG_TOOLBAR = os.getenv("SHOW_DEBUG_TOOLBAR", "YES") == "YES"

if SHOW_DEBUG_TOOLBAR:
    DEBUG_TOOLBAR_PATCH_SETTINGS = False

    DEBUG_TOOLBAR_CONFIG = {
    }

    DEBUG_TOOLBAR_PANELS = [
        "debug_toolbar.panels.versions.VersionsPanel",
        "debug_toolbar.panels.timer.TimerPanel",
        # "debug_toolbar.panels.profiling.ProfilingPanel",
        "debug_toolbar.panels.settings.SettingsPanel",
        "debug_toolbar.panels.headers.HeadersPanel",
        "debug_toolbar.panels.request.RequestPanel",
        "debug_toolbar.panels.sql.SQLPanel",
        "debug_toolbar.panels.staticfiles.StaticFilesPanel",
        "debug_toolbar.panels.templates.TemplatesPanel",
        "debug_toolbar.panels.signals.SignalsPanel",
        "debug_toolbar.panels.logging.LoggingPanel",
        "debug_toolbar.panels.redirects.RedirectsPanel",
    ]

    MIDDLEWARE_CLASSES = (
        "debug_toolbar.middleware.DebugToolbarMiddleware",
    ) + MIDDLEWARE_CLASSES

    INSTALLED_APPS += (
        "debug_toolbar",
    )

MEDIA_ROOT = "media/"
MEDIA_URL = "/m/"
