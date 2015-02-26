from corsheaders import defaults as settings
from corsheaders.middleware import (
    CorsPostCsrfMiddleware, CorsMiddleware)
from rest_framework.authentication import (
    SessionAuthentication as RFSessionAuthentication)



class PatchDepatchRefererCsrf(CorsMiddleware, CorsPostCsrfMiddleware):
    """
    Helper class to provide access to _https_referer_replace
    and _https_referer_replace_reverse.
    """

    def patch(self, request):
        if self.is_enabled(request) and settings.CORS_REPLACE_HTTPS_REFERER:
            self._https_referer_replace(request)

    def depatch(self, request):
        self._https_referer_replace_reverse(request)


class SessionAuthentication(RFSessionAuthentication):
    """
    SessionAuthentication that patchess the HTTP_REFERER before checking
    CSRF and depatch it after checking it.

    corsheaders supplies middleware but DRF doesn't use the middleware
    when checking CSRF for itself. This creates a problem when using https.
    """
    def enforce_csrf(self, request):
        patch_depatch = PatchDepatchRefererCsrf()
        patch_depatch.patch(request)
        super(SessionAuthentication, self).enforce_csrf(request)
        patch_depatch.depatch(request)
