from django.db import models

class KnowYourMiner(models.Model):
    minerAddress = models.CharField(max_length=80)
    geography = models.CharField(max_length=80)
    reputation = models.CharField(max_length=80)
    dataCenterTier = models.IntegerField()

class HITRUST(models.Model):
    miner = models.CharField(max_length=80)
    auditor = models.CharField(max_length=80)
    expiration = models.CharField(max_length=80)
    link = models.CharField(max_length=80)
