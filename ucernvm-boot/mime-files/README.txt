These files are used by the parse-user-data.sh script to generate a MIME-Multipart 
like file from the user-data file in old syntax. The script DOES NOT generate actual 
MIME-Multipart file like the amiconfig-helper-script does, but it rather creates a file
that looks like a MIME-Multipart file so that it can be processed by Cloud-Init. 