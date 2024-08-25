#!/bin/bash



# Script to calculate stats and weightings for past year
# based on repo activity
#
# The final weightings are used for decision making power
# in meetings / roadmapping



# Calculate date for past year
END_DATE=$(date -u +"%Y-%m-%d")
START_DATE=$(date -u -d "1 year ago" +"%Y-%m-%d")
mkdir -p calcs

# PRs (5x multiplier)
./gh search prs --repo hotosm/fmtm --merged-at $START_DATE..$END_DATE --limit 1000 \
--json author --jq '.[].author.login' | sort | uniq -c | sort -nr > calcs/pr_counts.txt
awk '{print $2, $1 * 5}' calcs/pr_counts.txt > calcs/pr_weighted.txt

# Issues (1x multiplier)
./gh search issues --repo hotosm/fmtm --created $START_DATE..$END_DATE --limit 1000 \
--json author --jq '.[].author.login' | sort | uniq -c | sort -nr > calcs/issue_counts.txt
awk '{print $2, $1 * 1}' calcs/issue_counts.txt > calcs/issue_weighted.txt

# Commits (0.5x multiplier)
./gh search commits --repo hotosm/fmtm --author-date $START_DATE..$END_DATE --limit 1000 \
--json author --jq '.[].author.login' | sort | uniq -c | sort -nr > calcs/commit_counts.txt
awk '{print $2, $1 * 0.5}' calcs/commit_counts.txt > calcs/commit_weighted.txt

# Comments (0.5x multiplier)
./gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" \
/repos/hotosm/fmtm/issues/comments --paginate \
--jq '.[] | select(.created_at >= "'"$START_DATE"'T00:00:00Z" and .created_at < "'"$END_DATE"'T00:00:00Z") | .user.login' | \
sort | uniq -c | sort -nr > calcs/comment_counts.txt
awk '{print $2, $1 * 0.5}' calcs/comment_counts.txt > calcs/comment_weighted.txt

# Discussions (0.5x multiplier)
./gh api graphql --paginate -f query='
query($cursor: String) {
  repository(owner: "hotosm", name: "fmtm") {
    discussions(first: 100, after: $cursor) {
      edges {
        node {
          id
          comments(first: 100) {
            edges {
              node {
                author {
                  login
                }
              }
            }
          }
        }
      }
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
}' --jq '
  .data.repository.discussions.edges[].node.comments.edges[].node.author.login
' | sort | uniq -c | sort -nr > calcs/discussion_counts.txt
awk '{print $2, $1 * 0.5}' calcs/discussion_counts.txt > calcs/discussion_weighted.txt



# Combine the counts
cat calcs/pr_weighted.txt calcs/issue_weighted.txt calcs/commit_weighted.txt calcs/comment_weighted.txt calcs/discussion_weighted.txt | \
awk '{arr[$1]+=$2} END {for (i in arr) print i, arr[i]}' | sort -k2 -nr > calcs/combined_scores.txt

# Filter out bots and users with less than 5 contribution points
awk '!/pre-commit-ci\[bot\]/ && !/allcontributors\[bot\]/ && !/sentry-io\[bot\]/ && $2 >= 5' calcs/combined_scores.txt > calcs/filtered_scores.txt

# Calculate totals
total_score=$(awk '{sum+=$2} END {print sum}' calcs/filtered_scores.txt)

# Filter out contributions less than 1% of the total
awk -v total="$total_score" '$2 >= total * 0.01' calcs/filtered_scores.txt > calcs/significant_scores.txt

# Recalculate totals after filtering
final_total_score=$(awk '{sum+=$2} END {print sum}' calcs/significant_scores.txt)

# Recalculate percentages
awk -v total="$final_total_score" '{printf "%s %.2f\n", $1, ($2/total)*100}' calcs/significant_scores.txt > calcs/final_percentages.txt



# View final percentages with date range
echo ""
echo "Result ($START_DATE to $END_DATE):"
echo ""
cat calcs/final_percentages.txt
echo ""
