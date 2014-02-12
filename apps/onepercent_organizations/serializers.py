from bluebottle.organizations.serializers import OrganizationSerializer


class OnepercentOrganizationSerializer(OrganizationSerializer):

    class Meta:
        model = OrganizationSerializer.Meta.model
        fields = OrganizationSerializer.Meta.fields + ()