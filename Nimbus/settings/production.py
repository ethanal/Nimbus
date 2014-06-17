import urlparse
from .base import *
from secret import *


"""In production, add a file called secret.py to the settings package that
defines SECRET_KEY and DATABASE_URL.

DATABASE_URL should be of the following form:
    postgres://<user>:<password>@<host>/<database>
"""

DEBUG = os.getenv("DEBUG", "FALSE") == "TRUE"
TEMPLATE_DEBUG = DEBUG

SHOW_DEBUG_TOOLBAR = False

urlparse.uses_netloc.append("mysql")
url = urlparse.urlparse(DATABASE_URL)

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': url.path[1:],
        'USER': url.username,
        'PASSWORD': url.password,
        'HOST': url.hostname
    }
}

MEDIA_ROOT = "/usr/local/nimbus_media/"
