from django.db import models
from django_countries import CountryField


class Address(models.Model):
    """
    A postal address.
    """
    address_line1 = models.CharField(max_length=100, blank=True)
    address_line2 = models.CharField(max_length=100, blank=True)
    city = models.CharField(max_length=100, blank=True)
    state = models.CharField(max_length=100, blank=True)
    country = CountryField()
    zip_code = models.CharField(max_length=20, blank=True)

    class Meta:
        abstract = True