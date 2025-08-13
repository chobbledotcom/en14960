# frozen_string_literal: true
# typed: strict

require "sorbet-runtime"

module EN14960
  extend T::Sig
  
  VERSION = T.let("0.3.0", String)
end
