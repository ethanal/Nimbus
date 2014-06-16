import logging
from django.contrib.auth.forms import AuthenticationForm
from django import forms
from django.utils.html import strip_tags
from .models import Media


logger = logging.getLogger(__name__)


class AuthenticateForm(AuthenticationForm):
    username = forms.CharField(required=True, widget=forms.widgets.TextInput(attrs={"placeholder": "Username"}), error_messages={"required": "Invalid username"})
    password = forms.CharField(required=True, widget=forms.widgets.PasswordInput(attrs={"placeholder": "Password"}), error_messages={"required": "Invalid password"})

    def is_valid(self):
        form = super(AuthenticateForm, self).is_valid()

        for f, error in self.errors.iteritems():
            if f == "__all__":
                self.fields["password"].widget.attrs.update({"class": "error", "placeholder": "Invalid password"})
            else:
                self.fields[f].widget.attrs.update({"class": "error", "placeholder": strip_tags(str(error))})
        logger.debug(self.errors)
        return form


class UploadFileForm(forms.ModelForm):
    class Meta:
        model = Media
