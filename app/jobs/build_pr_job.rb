class BuildPrJob < ActiveJob::Base
  queue_as :default

  def perform(pr)
    return if pr.nil?
    exitstatus = build_pr(pr)
    pr.set_status(exitstatus);
  end

  private
  def build_pr(pr)
    repo_name    = pr.repo_name
    base_ssh_url = pr.base_ssh_url
    base_branch  = pr.base_branch
    ssh_url      = pr.ssh_url
    branch      = pr.branch
    cmd = <<-EOF
      (
      set -e
      ls #{repo_name} || git clone #{base_ssh_url} #{repo_name}
      cd #{repo_name}
      git rebase --abort || true
      git reset --hard ; git clean -d -f
      git checkout origin/HEAD
      git branch -D #{base_branch} || true
      git checkout -b #{base_branch} origin/HEAD
      git pull
      git checkout origin/HEAD
      git branch -D #{branch} || true
      git fetch #{ssh_url} #{branch}
      git checkout -b #{branch} FETCH_HEAD
      git rebase #{base_branch}
      make clean; make test CONFIG=debug
      ) 2>&1
    EOF
    Dir.chdir(File.join(Rails.root, 'tmp')) do
      pid, stdin, stdout, stderr = Open4::popen4 "sh"
      stdin.puts cmd
      stdin.close
      ignored, status = Process::waitpid2 pid
      puts "============= #{ssh_url} #{branch} exitstatus: #{status.exitstatus}"
      pr.details = stdout.read
      return status.exitstatus
    end
  end

end
