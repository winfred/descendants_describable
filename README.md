# descendants_describable.gem

This gem provides a shorthand DSL for including re-usable sets of mixin modules across a large set of STI models.
If you find yourself with a folder of subclasses full of boilerplate and shared functionality, this gem will let you replace
those files with one or a few small files that read more descriptively, like so:

``` ruby

MySuperClass.describe_descendants_with(MySuperClassMixins) do
  type :some_type
  type :another_subtype do
    email_addressable
  end

  type :some_domain_event do
    email_addressable
    payment_validatable
  end
end
```

## Why?

My [blog post](http://winfred.nadeau.io/2014/03/22/taming-the-activities-table/) describes the evolution of this gem at (Hired)[hired.com] pretty well.

TL;DR imagine the example in the [usage section](#usage) with a marketplace's domain described therein.

## Installation

Add this line to your application's Gemfile:

    gem 'descendants_describable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install descendants_describable

## Usage

Here's the real-world example that gave life to this gem:

```ruby

  # config/initializers/activities.rb

  Activity.describe_descendants_with(Activity::Descriptors) do
    type :completed_survey do
      user_required
    end

    type :bid_on_developer do
      approved_employers_only
      target_required
    end

    type :auction_membership_confirmed do
      approved_developers_only
      actor_unique_to_auction
      target_required
    end
    # ... others omitted for brevity ...
end

```

Given this example, one is describing the descendants of an Activity class (that also live on the activities table with a type column for STI), the following is happening.


1. Each "type" declaration instantiates a new subclass by that name camelized.
2. Each method called inside the block provided to a "type" declaration will include into that new subclass a module by that method name camelized in the provided *descriptor namespace*.

So the above is basically shorthand for this:

```ruby

# in models/completed_survey.rb
class CompletedSurvey < Activity
  include Activity::Descriptors::UserRequired
end

# in models/bid_on_developer.rb
class BidOnDeveloper < Activity
  include Activity::Descriptors::ApprovedEmployersOnly
  include Activity::Descriptors::TargetRequired
end

# in models/auction_membership_confirmed.rb
class AuctionMembershipConfirmed < Activity
  include Activity::Descriptors::ApprovedEmployersOnly
  include Activity::Descriptors::ActorUniqueToAuction
  include Activity::Descriptors::TargetRequired
end

```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
