import logging
import os
import git
 
TMP_DIR = "/tmp"
CLONE_PATH = os.path.join(TMP_DIR, REPO_DIR)
 
LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.INFO)

def handler(event, context):
   LOGGER.info('Event: %s', event)
   return "Hello World"