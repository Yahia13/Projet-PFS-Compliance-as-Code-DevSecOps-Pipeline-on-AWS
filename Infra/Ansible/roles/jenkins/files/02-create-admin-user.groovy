import jenkins.model.*
import hudson.security.*
import hudson.model.User

def instance = Jenkins.get()

def adminUser = "Pfs2026"
def adminPass = "Pfs2026@123"   // CHANGE / put from Ansible Vault later

// 1) If user already exists, do nothing
def existing = User.getById(adminUser, false)
if (existing != null) {
  println "--> Admin user '${adminUser}' already exists, skipping"
  return
}

println "--> Creating Jenkins admin user '${adminUser}'"

// 2) Ensure local security realm exists
def realm = instance.getSecurityRealm()
if (!(realm instanceof HudsonPrivateSecurityRealm)) {
  realm = new HudsonPrivateSecurityRealm(false)
  instance.setSecurityRealm(realm)
}

// 3) Create account
realm.createAccount(adminUser, adminPass)

// 4) Set authorization strategy
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
println "--> Done"
