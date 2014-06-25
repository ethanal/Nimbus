import logging
from .forms import AuthenticateForm
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.shortcuts import render, redirect
from django.contrib.auth import login, logout
from django.views.generic.base import View
from nimbus.apps.media.models import Media


logger = logging.getLogger(__name__)


def index(request, auth_form=None):
    if request.user.is_authenticated():
        return dashboard_view(request)
    else:
        auth_form = auth_form or AuthenticateForm()
        request.session.set_test_cookie()
        return render(request, "nimbus/accounts/login.html", {
            "auth_form": auth_form
        })


class login_view(View):
    def post(self, request):
        form = AuthenticateForm(data=request.POST)

        if request.session.test_cookie_worked():
            request.session.delete_test_cookie()
        else:
            logger.error("No cookie support detected! This could cause problems.")

        if form.is_valid():
            login(request, form.get_user())
            logger.info("Login succeeded as {}".format(request.POST.get("username", "unknown")))
            next = request.GET.get("next", "/")
            return redirect(next)
        else:
            logger.info("Login failed as {}".format(request.POST.get("username", "unknown")))
            return index(request, auth_form=form)  # Modified to show errors

    def get(self, request):
        return index(request)


def logout_view(request):
    logout(request)
    return redirect("/")


@login_required
def dashboard_view(request, media_type="files"):
    media_type_codes = {j.lower(): i for i, j in Media.MEDIA_TYPES_PLURAL}
    if media_type == "files":
        media_list = Media.objects.filter(user=request.user).order_by("-upload_date", "name")
    else:
        media_list = Media.objects.filter(media_type=media_type_codes[media_type])

    paginator = Paginator(media_list, 50)
    page = request.GET.get("p")
    try:
        media = paginator.page(page)
    except PageNotAnInteger:
        media = paginator.page(1)
    except EmptyPage:
        media = paginator.page(paginator.num_pages)

    return render(request, "nimbus/accounts/dashboard.html", {
        "media_type": media_type,
        "media": media
    })
