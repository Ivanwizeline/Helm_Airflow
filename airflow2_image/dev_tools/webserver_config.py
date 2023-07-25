# -*- coding: utf-8 -*-
import os
from logging import getLogger

from airflow.configuration import conf

logger = getLogger(__name__)

basedir = os.path.abspath(os.path.dirname(__file__))

# The SQLAlchemy connection string.
SQLALCHEMY_DATABASE_URI = conf.get("core", "SQL_ALCHEMY_CONN")

# Flask-WTF flag for CSRF
CSRF_ENABLED = True

# ----------------------------------------------------
# AUTHENTICATION CONFIG
# ----------------------------------------------------

AUTH_ROLE_PUBLIC = 'Admin'
