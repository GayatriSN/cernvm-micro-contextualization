#part-handler
# vi: syntax=python ts=4

# Define the MIME type the part-handler shall handle
def list_types():
	return [("text/amiconfig")]

# Process the MIME relevant MIME part
def handle_part(data,ctype,filename,payload):

	# If content type belongs to the beginning or end delimiter
	# display the beginning/end message and return

	if ctype == "__begin__":
		print "Amiconfig Part Handler is beginning"
		return
	if ctype == "__end__":
		print "Amiconfig Part Handler is ending"
		return

	# Display the file received and the filetype

	print "Received Content Type=%s Filename=%s" % (ctype,filename)
	import os

	# Save the payload (MIME-part) to the relevant directory
	with open('/var/lib/cloud/amiconfig-data','w') as fnew:
		fnew.write(payload)
		fnew.close()

	# Modify permissions so that the user-data file is accessible by amiconfig	
	os.chmod('var/lib/cloud/amiconfig-data',0777)

	# Set Amiconfig Local User Data enviroment variable to use seeded data
	os.environ["AMICONFIG_LOCAL_USER_DATA"] = '/var/lib/cloud/amiconfig-data'

	# Call Amiconfig
	print "Running amiconfig contextualization..."
	os.system('/usr/sbin/amiconfig')
	print "Completed Amiconfig Contextualization..."
