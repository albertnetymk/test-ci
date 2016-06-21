class PrController < ApplicationController
  skip_before_action :verify_authenticity_token

  def event_handler
    head :no_content

    return unless request.headers["X-GitHub-Event"] == 'pull_request'

    return if params['zen']

    ## params[:action] is reserved by rails
    case request.POST['action']
    when 'opened', 'synchronize'
      handle_pr(params)
    when 'closed'
      handle_merge(params)
    else
      nil
    end
  end

  def handle_pr(params)
    dict = {
      pr_id: params['number'],
      owner_repo_name: params['pull_request']['base']['repo']['full_name'],
      repo_name:  params['pull_request']['base']['repo']['name'],
      base_ssh_url: params['pull_request']['base']['repo']['ssh_url'],
      base_branch: params['pull_request']['base']['ref'],
      sha: params['pull_request']['head']['sha'],
      ssh_url: params['pull_request']['head']['repo']['ssh_url'],
      branch: params['pull_request']['head']['ref']
    }
    pr = Pr.find_or_create(dict)
    pr.pending
    BuildPrJob.perform_later(pr)
  end

  def handle_merge(params)
    merged = params['pull_request']['merged']
    pr = Pr.find_by(pr_id: params['number'])
    pr.destroy if pr
    return unless merged
    owner_repo_name = params['pull_request']['base']['repo']['full_name']
    jsons = GHClient.prs_open(owner_repo_name)
    jsons.each do |json|
      pr = extract_pr_from_pr_json json
      pr.pending
      BuildPrJob.perform_later(pr)
    end
  end

  def build
    owner = params[:owner]
    repo = params[:repo]
    owner_repo_name = [owner, repo].join('/')
    number = params[:number]
    if number
      pr = extract_pr_from_pr_json GHClient.pr(owner_repo_name, number)
      pr.pending
      BuildPrJob.perform_later(pr)
    else
      jsons = GHClient.prs_open(owner_repo_name)
      jsons.each do |json|
        pr = extract_pr_from_pr_json json
        pr.pending
        BuildPrJob.perform_later(pr)
      end
    end

    head :no_content
  end

  def show
    pr_id = params[:number]
    redirect_to root_path unless pr_id
    @pr = Pr.find_by(pr_id: pr_id)
    redirect_to root_path unless @pr
  end

  def home
    # head :no_content
    # return
  end

  private
  def extract_pr_from_pr_json(json)
    state = json['state']
    return Pr.null_pr if state != 'open'
    dict = {
      pr_id: json['number'],
      owner_repo_name: json["base"]["repo"]["full_name"],
      repo_name:  json["base"]["repo"]["name"],
      base_ssh_url: json['base']['repo']['ssh_url'],
      base_branch: json['base']['ref'],
      sha: json["head"]["sha"],
      ssh_url: json["head"]["repo"]["ssh_url"],
      branch: json["head"]["ref"]
    }
    Pr.find_or_create(dict)
  end

end
