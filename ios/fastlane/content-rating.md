# Content rating

Content rating update is a part of
the [Deliver](https://docs.fastlane.tools/actions/deliver/) action.

[`content-rating.json`](content-rating.json) values:

- `NONE`
- `FREQUENT_OR_INTENSE`
- `INFREQUENT_OR_MILD`

For kids apps add `kidsAgeBand` with:

- `FIVE_AND_UNDER`
- `SIX_TO_EIGHT`
- `NINE_TO_ELEVEN`
- `null`

The last `content-rating.json` version has been taken
from https://github.com/fastlane/fastlane/blob/master/deliver/assets/example_rating_config.json
