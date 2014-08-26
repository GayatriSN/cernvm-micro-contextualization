cernvm-micro-contextualization
==============================

'Streamline CernVM Contextualization Plug-ins' Project Repository

Syntax for Contextualization
==============================

Use the MIME multipart archive for providing user data. It could be base64 encoded and compressed to fit the user data within the cloud-provider limits.

The user-data sections are declared as shown in the table:

| User Data Section	| MIME Multipart Type |
| --- | --- |
| Shell Script |	text/x-shellscript |
| µcernvm-bootloader |	text/ucernvm |
| Amiconfig |	text/amiconfig |
| Cloud Config |	text/cloud-config |

Other formats supported by CloudInit could also be used along with the ones mentioned above.

For generating a MIME Multipart script we can use the following amiconfig mime-helper script:

```
#!/usr/bin/python
import sys
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

if len(sys.argv) == 1:
    print("%s input-file:type ..." % (sys.argv[0]))
    sys.exit(1)

combined_message = MIMEMultipart()
    for i in sys.argv[1:]:
        (filename, format_type) = i.split(":", 1)
    with open(filename) as fh:
        contents = fh.read()
    sub_message = MIMEText(contents, format_type, sys.getdefaultencoding())
    sub_message.add_header('Content-Disposition', 'attachment; filename="%s"' % (filename))
    combined_message.attach(sub_message)

print(combined_message)
```

This script is available in CernVM under /usr/bin/amiconfig-mime. We can invoke it using:
```
amiconfig-mime ucernvm-data:ucernvm amiconfig-data:amiconfig ucernvm-data:ucernvm startup-script:x-shellscript > user-data
```


