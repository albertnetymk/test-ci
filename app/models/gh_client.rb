class GHClient
  def self.client
    # @@client ||= Octokit::Client.new(access_token: ENV['octo_token'])
    Octokit::Client.new(access_token: ENV['octo_token'])
  end

  def self.create_status(pr, status)
    GHClient.client.create_status(
      pr.owner_repo_name,
      pr.sha,
      status,
      {
        context: 'albert-laptop',
        description: 'Click Details to see output on CI',
        target_url: ENV['domain_url'] +
          Rails.application.routes.url_helpers.pr_show_path(pr.pr_id)
      }
    )
  end

  def self.pr(repo, number)
    self.client.pull_request(repo, number)
  end

  def self.prs_open(repo)
    self.client.pull_requests(repo, state: 'open')
  end
end
