import jenkins.model.*
import hudson.plugins.git.*

def instance = Jenkins.get()

def gitDesc = instance.getDescriptorByType(GitTool.DescriptorImpl)

if (gitDesc.getInstallations().size() == 0) {
    println "--> Configuring Git tool"

    def git = new GitTool(
        "system-git",
        "/usr/bin/git",
        []
    )

    gitDesc.setInstallations(git)
    gitDesc.save()
} else {
    println "--> Git tool already configured"
}
