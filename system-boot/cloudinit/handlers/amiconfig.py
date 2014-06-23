#custom part handler for amiconfig

import os

from cloudinit import handlers
from cloudinit import log as logging
from cloudinit import util

from cloudinit.settings import (PER_ONCE)

LOG = logging.getLogger(__name__)
AMICONFIG_PREFIX = "#amiconfig"


class AmiconfigPartHandler(handlers.Handler):
    def __init__(self, paths, **_kwargs):
        handlers.Handler.__init__(self, PER_ONCE)
        self.amiconfig_file = "/var/lib/cloud/amiconfig-data"

    def list_types(self):
        return [
            handlers.type_from_starts_with(AMICONFIG_PREFIX),
        ]

    def handle_part(self, _data, ctype, filename,  # pylint: disable=W0221
                    payload, frequency):  # pylint: disable=W0613

    #This part-handler functions as a wrapper script that will set the
    #environment variables and copy files for amiconfig and then call it    

        if ctype in handlers.CONTENT_SIGNALS:
            #Do Nothing at beginning or end of our handler [to be added if needed]
            return

    #Copying amiconfig relevant part to a new file /var/lib/cloud/amiconfig-data
    util.write_file(amiconfig_file, payload, 0777)

    #Setting the environment for amiconfig to user the local user-data  
    os.environ["AMICONFIG_LOCAL_USER_DATA"] = "/var/lib/cloud/amiconfig-data"

    #Executing amiconfig
    print "Running amiconfig contextualization"
    os.system("/usr/bin/amiconfig")

