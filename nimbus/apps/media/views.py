from django.shortcuts import render, get_object_or_404
from subdomains.utils import reverse
from .models import Media


def share_view(request, url_hash):
    media_item = get_object_or_404(Media, url_hash=url_hash)

    return render(request, "nimbus/media/share_preview.html", {
        "media_item": media_item,
        "raw_media_url": reverse("raw_media", subdomain=None, kwargs={"path": media_item.target_file})
    })
