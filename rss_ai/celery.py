# -*- coding: utf-8 -*-
"""Celery task config"""

import os

from celery import Celery
from celery.schedules import crontab

# Set the default Django settings module for the 'celery' program.
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "rss_ai.settings")

app = Celery("rss_ai")

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object("django.conf:settings", namespace="CELERY")

# Load task modules from all registered Django apps.
app.autodiscover_tasks()

app.conf.beat_schedule = {
    "daytime": {
        "task": "rss_ai.pages.pageHome.refresh_feeds",
        "schedule": crontab(minute="*/15", hour="5-18"),
        "args": (),
    },
    "nighttime": {
        "task": "rss_ai.pages.pageHome.refresh_feeds",
        "schedule": crontab(minute="*/30", hour="18-23"),
        "args": (),
    },
}
