cite about-plugin
about-plugin 'Maven jgitflow build helpers'

hotfix-start () {
  about 'helper function for starting a new hotfix'
  group 'jgitflow'

  mvn jgitflow:hotfix-start ${JGITFLOW_MVN_ARGUMENTS}
}

hotfix-finish () {
  about 'helper function for finishing a hotfix'
  group 'jgitflow'

  mvn jgitflow:hotfix-finish -Darguments="${JGITFLOW_MVN_ARGUMENTS}" && git push && git push origin master && git push --tags
}

feature-start () {
  about 'helper function for starting a new feature'
  group 'jgitflow'

  mvn jgitflow:feature-start ${JGITFLOW_MVN_ARGUMENTS}
}

feature-finish () {
  about 'helper function for finishing a feature'
  group 'jgitflow'

  mvn jgitflow:feature-finish ${JGITFLOW_MVN_ARGUMENTS}

  echo -e 'REMEMBER TO CREATE A NEW RELEASE TO DEPLOY THIS FEATURE'
}

release-start () {
  about 'helper function for starting a new release'
  group 'jgitflow'

  mvn jgitflow:release-start ${JGITFLOW_MVN_ARGUMENTS}
}

release-finish () {
  about 'helper function for finishing a release'
  group 'jgitflow'

  mvn jgitflow:release-finish -Darguments="${JGITFLOW_MVN_ARGUMENTS}" && git push && git push origin master && git push --tags
}
