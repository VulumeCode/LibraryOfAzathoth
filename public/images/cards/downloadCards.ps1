gc .\urls.txt |  % {iwr $_ -outf $(split-path $_ -leaf)}