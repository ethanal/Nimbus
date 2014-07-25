import urlparse
from .base import *


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
