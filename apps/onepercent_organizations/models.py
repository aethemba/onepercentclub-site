from django.db import models
from bluebottle.organizations.models import BaseOrganization


class OnepercentOrganization(BaseOrganization):
    """
    Organization model for Onepercent websites
    """

    class Meta:
        swappable = 'ORGANIZATIONS_ORGANIZATION_MODEL'
        db_table = 'organizations_organization'
        default_serializer = 'apps.onepercent_organizations.serializers.OnepercentOrganizationSerializer'