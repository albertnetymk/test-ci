## Test CI

### Configuration

```
# .env
SECRET_KEY_BASE=... # rails stuff
octo_token=... # for octokit
domain_url=... # your domain or just IP
```

### Routes

```
POST /pr # webhooks for pull request
POST /build/:owner/:repo # build all open PRs
POST /build/:owner/:repo/:id # build a specific PR
```

So, `curl -d '' domain_url/build/:owner/:repo` would build all open PRs for that repo.

### Deployment

Since this app is almost stateless, one could rebuild all state from scratch on launching:

```
RAILS_ENV=production rake db:migrate:reset
(sleep 5 && curl -d '' localhost:3000/build/:owner/:repo) &
RAILS_ENV=production foreman start
```
