import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition

import hudson.plugins.git.GitSCM
import hudson.plugins.git.UserRemoteConfig
import hudson.plugins.git.BranchSpec
import hudson.plugins.git.SubmoduleConfig
import hudson.plugins.git.extensions.impl.CleanBeforeCheckout

def jenkins = Jenkins.get()
def jobName = "pfs-compliance-as-code"

if (jenkins.getItem(jobName) != null) {
  println "--> Job '${jobName}' already exists"
  return
}

println "--> Creating pipeline job: ${jobName}"

// -------- EDIT THESE ----------
def repoUrl = "https://github.com/Yahia13/Projet-PFS-Compliance-as-Code-DevSecOps-Pipeline-on-AWS.git"     // <-- change
def branch  = "*/yahia"                               // <-- change if needed
def credId  = ""                                     // <-- put Jenkins credentials ID if private repo
def jenkinsfilePath = "ci/jenkinsfile"                  // <-- your Jenkinsfile path
// -----------------------------

def remote = new UserRemoteConfig(repoUrl, null, null, credId)

def scm = new GitSCM(
  [remote],
  [new BranchSpec(branch)],
  false,
  Collections.<SubmoduleConfig>emptyList(),
  null,
  null,
  [new CleanBeforeCheckout()]
)

def job = jenkins.createProject(WorkflowJob, jobName)
def defn = new CpsScmFlowDefinition(scm, jenkinsfilePath)
defn.setLightweight(true)

job.setDefinition(defn)
job.save()

println "--> Pipeline job '${jobName}' created successfully"
