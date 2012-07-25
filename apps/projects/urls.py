from django.conf.urls.defaults import patterns, url, include

from surlex.dj import surl

from .api import ProjectResource, IdeaPhaseResource
from .views import ProjectListView, ProjectDetailView

project_resource = ProjectResource()
ideaphase_resource = IdeaPhaseResource()


urlpatterns = patterns('apps.projects.views',
    surl(r'^$', ProjectListView.as_view(), name='project_list'),
    surl(r'^<slug:s>/$', ProjectDetailView.as_view(), name='project_detail'),
)

# API urls
urlpatterns += patterns('',
    url(r'^api/', include(project_resource.urls)),
    url(r'^api/', include(ideaphase_resource.urls)),
)
