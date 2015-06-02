=begin
This module gives special workarounds for some issues.

Problems are bypassed by monkey-patching.

As soon as a problem is resolved, patch should be removed.

**** Known issues ****

1. gem/twitter
Location : override/gem/twitter/connection.rb
Maintain : until below issue is fixed
Reference: https://github.com/sferik/twitter/pull/669

Gem 'twitter' does not handle streaming timeout. By applying this,
reading timeout works and Rbitter can handle timeouts.

2. gem/rubysl-socket
Location : override/gem/rubysl-socket/socket.rb
Maintain : until ip_address_list is implemented
Reference: https://github.com/rubysl/rubysl-socket/pull/9

With ipv6 environment, Resolv#use_ipv6? (in rubysl-resolv gem) checks 
Socket.ip_address_list. This is not implemented at all with rubysl-socket-2.0.1.
NoMethodError exception is raised instead of NotImplementedError.

By applying this, Socket.ip_address_list is implemented and the method throws
NotImplementedError exception.

=end

def gem_twitter_patcher
  require 'rbitter/override/gem/twitter/connection'
end

if Twitter::Version.const_defined?(:MAJOR)
  b5_version = Twitter::Version::MAJOR * 10000
  + Twitter::Version::MINOR * 100 + Twitter::Version::PATCH
  gem_twitter_patcher if b5_version <= 51400
else
  b6_version = Twitter::Version.to_a
  if b6_version[0] <= 6 and b6_version[1] <= 0 and b6_version[2] <= 0
    gem_twitter_patcher
  end
end

require 'rbitter/override/gem/rubysl-socket/socket' if RUBY_ENGINE == 'rbx'
