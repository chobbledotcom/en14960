# EN14960

A Ruby gem providing calculators and validators for BS EN 14960:2019 - the British/European safety standard for inflatable play equipment.

## Features

- **Anchor Calculations**: Calculate required ground anchors based on dimensions and wind loads
- **Slide Safety**: Calculate runout distances and wall height requirements
- **User Capacity**: Calculate safe user capacity based on play area and user heights
- **Material Validation**: Validate material specifications against EN 14960 requirements

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'en14960'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install en14960

## Usage

### Anchor Calculations

Calculate required anchors for inflatable play equipment:

```ruby
result = EN14960.calculate_anchors(length: 5, width: 4, height: 3)
puts result.value  # => 8
puts result.breakdown
# => [
#   ["Front/back area", "4m (W) × 3m (H) = 12m²"],
#   ["Sides area", "5m (L) × 3m (H) = 15m²"],
#   ["Front & back anchor counts", "((12.0 × 114.0 * 1.5) ÷ 1600.0 = 2"],
#   ["Left & right anchor counts", "((15.0 × 114.0 * 1.5) ÷ 1600.0 = 2"],
#   ["Required anchors", "(2 + 2) × 2 = 8"]
# ]
```

### Slide Runout Calculations

Calculate minimum runout distance for slides:

```ruby
# Basic runout calculation
result = EN14960.calculate_slide_runout(2.5)
puts result.value  # => 1.25 (meters)

# With stop wall
result = EN14960.calculate_slide_runout(2.5, has_stop_wall: true)
puts result.value  # => 1.75 (meters)
```

### Wall Height Requirements

Calculate containing wall requirements for different platform heights:

```ruby
result = EN14960.calculate_wall_height(2.0, 1.5)
puts result.value  # => 1.5 (meters)
puts result.breakdown
# => [
#   ["Height range", "0.6m - 3.0m"],
#   ["Calculation", "1.5m (user height)"]
# ]
```

### User Capacity Calculations

Calculate safe user capacity based on play area:

```ruby
result = EN14960.calculate_user_capacity(10, 8)
puts result.value
# => {
#   users_1000mm: 80,  # 1.0m tall users
#   users_1200mm: 60,  # 1.2m tall users
#   users_1500mm: 48,  # 1.5m tall users
#   users_1800mm: 40   # 1.8m tall users
# }

# With maximum user height restriction
result = EN14960.calculate_user_capacity(10, 8, 1.5, 0)
puts result.value[:users_1800mm]  # => 0 (not allowed)

# With obstacles/negative play space
result = EN14960.calculate_user_capacity(10, 8, nil, 15)
# Reduces usable area by 15m²
```

### Material Validation

Validate materials against EN 14960 requirements:

```ruby
# Rope diameter validation
EN14960.valid_rope_diameter?(20)  # => true (within 18-45mm range)
EN14960.valid_rope_diameter?(10)  # => false (too thin)

# Access material standards
standards = EN14960.material_standards
puts standards[:fabric][:min_tensile_strength]  # => 1850 (Newtons)
puts standards[:rope][:min_diameter]  # => 18 (mm)
```

### Direct Module Access

You can also use the calculator modules directly:

```ruby
# Using AnchorCalculator directly
result = EN14960::Calculators::AnchorCalculator.calculate(
  length: 10, 
  width: 8, 
  height: 4
)

# Using MaterialValidator directly
EN14960::Validators::MaterialValidator.valid_fabric_tensile_strength?(2000)
# => true
```

## Constants

The gem provides access to all EN 14960:2019 constants:

```ruby
# Height categories
EN14960.height_categories
# => {
#   1000 => {label: "1.0m (Young children)", max_users: :calculate_by_area},
#   1200 => {label: "1.2m (Children)", max_users: :calculate_by_area},
#   1500 => {label: "1.5m (Adolescents)", max_users: :calculate_by_area},
#   1800 => {label: "1.8m (Adults)", max_users: :calculate_by_area}
# }

# Access all constants
EN14960::Constants::SLIDE_HEIGHT_THRESHOLDS
EN14960::Constants::MATERIAL_STANDARDS
EN14960::Constants::ANCHOR_CALCULATION_CONSTANTS
```

## EN 14960:2019 Compliance

This gem implements calculations based on BS EN 14960:2019, including:

- **Section 4.2.9**: Containment requirements (wall heights)
- **Section 4.2.11**: Slide runout requirements
- **Section 4.3**: Number of users calculations
- **Annex A**: Wind load and anchor calculations
- **Material specifications**: Fabric, thread, rope, and netting requirements

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Releasing

This gem uses GitHub Actions for automated releases to RubyGems.

To release a new version:

1. Update the version number in `lib/en14960/version.rb`
2. Commit the change: `git commit -am "Bump version to x.y.z"`
3. Create a tag: `git tag -a vx.y.z -m "Release version x.y.z"`
4. Push the tag: `git push origin vx.y.z`

The GitHub Action will automatically:
- Build the gem
- Publish it to RubyGems
- Create a GitHub release with the gem file attached

**Note**: You need to set up RubyGems authentication in your GitHub repository settings. Add a repository secret named `GEM_HOST_API_KEY` with your RubyGems API key.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chobbledotcom/en14960.

## License

The gem is available as open source under the terms of the [GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.html).

## References

- BS EN 14960:2019 - Inflatable play equipment - Safety requirements and test methods
- EN 71-3 - Safety of toys - Migration of certain elements