from django.shortcuts import render, get_object_or_404, redirect
from subdomains.utils import reverse
from .models import Media


def share_view(request, url_hash):
    media_item = get_object_or_404(Media, url_hash=url_hash)
    media_item.view_count += 1
    media_item.save()

    if media_item.media_type == "URL":
        return redirect(media_item.target_url)

    templates = {
        "IMG": "nimbus/media/share_img_preview.html",
        "TXT": "nimbus/media/share_txt_preview.html",
        "AUD": "nimbus/media/share_aud_preview.html",
        "VID": "nimbus/media/share_vid_preview.html"
    }

    template = templates.setdefault(media_item.media_type, "nimbus/media/share_download.html")
    return render(request, template, {
        "media_item": media_item,
        "raw_media_url": reverse("raw_media", subdomain=None, kwargs={"path": media_item.target_file})
    })
