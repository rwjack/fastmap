# fastmap
Nmap wrapper script for your .bashrc to speed up enumeration

## To install:
Just paste the code at the end of your `~/.bashrc` 
and after that, do `source ~/.bashrc`

OR:

Save and use as a bash script

Don't forget to `chmod u+x`

### Usage:
fastmap IP BoxName [-a] [-t,u,tu]

`-a` : adds a new line in /etc/hosts in the following format:
  `IP    BoxName.htb BoxName`
  
`-t,u,tu` : Performs the scan on (t)TCP, (u)UDP or (tu)Both

`-n` : Only performs a quick port scan, without further analysis
