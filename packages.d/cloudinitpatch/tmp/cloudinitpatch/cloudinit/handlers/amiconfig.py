#part-handler
# vi: syntax=python ts=4

def list_types():
	return [("text/amiconfig")]

def handle_part(data,ctype,filename,payload):
	if ctype == "__begin__":
		print "Amiconfig Part Handler is beginning"
		return
	if ctype == "__end__":
		print "Amiconfig Part Handler is beginning"
		return

	print "Received Content Type=%s Filename=%s" % (ctype,filename)
	import os
	f = open('/var/lib/cloud/amiconfig-data','w')
	f.write(payload)
	f.close()
	os.chmod('var/lib/cloud/amiconfig-data','0777')
	os.environ["AMICONFIG_LOCAL_USER_DATA"] = '/var/lib/cloud/amiconfig-data'
	print "Running amiconfig contextualization"
	os.system('/usr/bin/amiconfig')
	print "Ending Amiconfig"
