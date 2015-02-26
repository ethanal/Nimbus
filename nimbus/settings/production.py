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

SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False
DEFAULT_URL_SCHEME = "https"
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
