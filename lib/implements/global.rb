# encoding: utf-8
require 'implements'

# Add functionality to Class, which enables us to use
# `Implements::Implementation`'s ::implements method
# without having to pre-extend the class.
class Class
  def implements(*args, &block)
    return super if defined?(super)

    extend(Implements::Implementation)
    send(__method__, *args, &block)
  end
  private :implements
end
