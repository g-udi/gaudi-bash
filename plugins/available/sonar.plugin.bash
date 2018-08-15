cite about-plugin
about-plugin 'Initialize any variable or conf required by Sonar and Sonar Scanner'

alias startSonar_debug="sh /etc/sonar/bin/macosx-universal-64/sonar.sh console"
alias startSonar="sh /etc/sonar/bin/macosx-universal-64/sonar.sh start"
alias stopSonar="sh /etc/sonar/bin/macosx-universal-64/sonar.sh stop"
export PATH="$PATH:/etc/sonar-scanner/bin"
