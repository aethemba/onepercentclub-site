from django.conf.urls import patterns, url
from rest_framework.urlpatterns import format_suffix_patterns
from surlex.dj import surl
from apps.projects.views import ProjectInstance
from .views import ProjectRoot

urlpatterns = patterns('',
    url(r'^$', ProjectRoot.as_view(), name='project-root'),
    surl(r'^<slug:s>$', ProjectInstance.as_view(), name='project-instance'),
)

urlpatterns = format_suffix_patterns(urlpatterns)