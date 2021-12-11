echo "programs to look into deleting"
echo "all output will be entered into investigate.txt file in home dir."
touch investigate.txt
dpkg -l | grep ftp >> investigate.txt
dpkg -l | grep map >> investigate.txt
dpkg -l | grep samba >> investigate.txt
dpkg -l | grep snmp >> investigate.txt
dpkg -l | grep telnet >> investigate.txt
dpkg -l | grep tracer >> investigate.txt
dpkg -l | grep trace >> investigate.txt
dpkg -l | grep  >> investigate.txt
dpkg -l | grep ripper >> investigate.txt
dpkg -l | grep john >> investigate.txt
dpkg -l | grep hydra >> investigate.txt
dpkg -l | grep meta >> investigate.txt
dpkg -l | grep sploit >> investigate.txt
dpkg -l | grep nginx >> investigate.txt
dpkg -l | grep dns >> investigate.txt
dpkg -l | grep tftpd >> investigate.txt
dpkg -l | grep nfs >> investigate.txt
dpkg -l | grep vnc >> investigate.txt