# fetch_new_tags

Action to fetch new kernel upstream tags.

Goes to the [GitHub linux mirror](https://github.com/torvalds/linux) and fetches a list of tags newer than ours, and bumps if appropriate.

Also prunes old tags, such that we don't have more than 3 tags at any one time.

Outputs our refreshed list of tags at the end.
