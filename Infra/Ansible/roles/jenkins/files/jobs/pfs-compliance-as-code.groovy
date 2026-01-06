pipelineJob('pfs-compliance-as-code') {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url('https://YOUR_GIT_REPO_URL.git')
            credentials('git-cred-id')   // Jenkins credentials ID
          }
          branches('*/main')
        }
      }
      scriptPath('Jenkinsfile') // or 'ci/Jenkinsfile' if inside folder
    }
  }

  triggers {
    scm('H/5 * * * *') // optional: poll every 5 minutes
  }
}
