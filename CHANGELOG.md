# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Full Sorbet type signatures for all public APIs
- Runtime type checking with sorbet-runtime
- Strongly typed CalculatorResponse using T::Struct
- Type safety documentation in README
- Test file demonstrating type-safe usage

### Changed
- CalculatorResponse now extends T::Struct instead of using Data.define
- All modules and classes now include Sorbet type annotations
- Improved type safety for method parameters and return values

## [0.1.0] - 2025-01-28

### Added
- Initial release of EN14960 gem
- Anchor calculator for wind load calculations per EN 14960:2019 Annex A
- Slide calculator for runout distances and wall height requirements
- User capacity calculator based on age-appropriate space allocation
- Material validator for rope, fabric, thread, and netting specifications
- Comprehensive constants from EN 14960:2019 standard
- Full test suite with RSpec
- Detailed documentation and usage examples

### Features
- Framework-agnostic implementation (no Rails dependency)
- Clean public API with intuitive method names
- Detailed calculation breakdowns for transparency
- Support for all height categories defined in EN 14960:2019
- Configurable parameters for various scenarios