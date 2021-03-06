from cms.admin import PageBaseAdmin
from django.contrib import admin

from ...utils.admin import HasImageAdminMixin
from .models import Event, Events


@admin.register(Event)
class EventAdmin(HasImageAdminMixin, PageBaseAdmin):
    list_display = ['get_image', '__str__', 'start_date', 'end_date', 'is_online']
    list_display_links = ['get_image', '__str__']
    list_editable = ['is_online']

    fieldsets = [
        (None, {
            'fields': ['page', 'title', 'slug'],
        }),
        ('Date', {
            'fields': [('start_date', 'end_date')]
        }),
        ('Content', {
            'fields': ['image', 'description'],
        }),
        PageBaseAdmin.PUBLICATION_FIELDS,
        PageBaseAdmin.NAVIGATION_FIELDS,
        PageBaseAdmin.SEO_FIELDS,
        PageBaseAdmin.OPENGRAPH_FIELDS,
        PageBaseAdmin.OPENGRAPH_TWITTER_FIELDS
    ]

    def get_form(self, request, obj=None, **kwargs):
        form = super(EventAdmin, self).get_form(request, obj, **kwargs)

        try:
            form.base_fields['page'].initial = Events.objects.first()
        except IndexError:
            pass

        return form
