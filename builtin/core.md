---
title: Language Core
prev: "/builtin.html"
next: "/builtin/types.html"
---

# Language Core

This section describes language core objects.



## Kernel

The Kernel module is included by class Object, so its methods are
available in every Ruby object.

The Kernel instance methods are documented in class Object while the
module methods are documented here. These methods are called without a
receiver and thus can be called in functional form:


```ruby
sprintf "%.1f", 1.234 #=> "1.2"
```

<a href='https://ruby-doc.org/core-2.5.0/Kernel.html' class='ruby-doc
remote' target='_blank'>Kernel Reference</a>



> See also [Appendix A](../appendix-a.md) for a brief list of Kernel
> methods.



## BasicObject

BasicObject is the parent class of all classes in Ruby. It's an explicit
blank class.

BasicObject can be used for creating object hierarchies independent of
Ruby's object hierarchy, proxy objects like the Delegator class, or
other uses where namespace pollution from Ruby's methods and classes
must be avoided.

To avoid polluting BasicObject for other users an appropriately named
subclass of BasicObject should be created instead of directly modifying
BasicObject:


```ruby
class MyObjectSystem < BasicObject
end
```

BasicObject does not include Kernel (for methods like `puts`) and
BasicObject is outside of the namespace of the standard library so
common classes will not be found without using a full class path.

A variety of strategies can be used to provide useful portions of the
standard library to subclasses of BasicObject. A subclass could `include
Kernel` to obtain `puts`, `exit`, etc. A custom Kernel-like module could
be created and included or delegation can be used via
`#method_missing`: 

```ruby
class MyObjectSystem < BasicObject
  DELEGATE = [:puts, :p]

  def method_missing(name, *args, &block)
    super unless DELEGATE.include? name
    ::Kernel.send(name, *args, &block)
  end

  def respond_to_missing?(name, include_private = false)
    DELEGATE.include?(name) or super
  end
end
```

Access to classes and modules from the Ruby standard library can be
obtained in a BasicObject subclass by referencing the desired constant
from the root like `::File` or `::Enumerator`. Like `#method_missing`,
`#const_missing` can be used to delegate constant lookup to `Object`: 

```ruby
class MyObjectSystem < BasicObject
  def self.const_missing(name)
    ::Object.const_get(name)
  end
end
```

<a href='https://ruby-doc.org/core-2.5.0/BasicObject.html'
class='ruby-doc remote' target='_blank'>BasicObject Reference</a>



## Object

Object is the default root of all Ruby objects. Object inherits from
BasicObject which allows creating alternate object hierarchies. Methods
on Object are available to all classes unless explicitly overridden.

Object mixes in the Kernel module, making the built-in kernel functions
globally accessible. Although the instance methods of Object are defined
by the Kernel module, we have chosen to document them here for clarity.

When referencing constants in classes inheriting from Object you do not
need to use the full namespace. For example, referencing `File` inside
`YourClass` will find the top-level File class.

In the descriptions of Object's methods, the parameter *symbol* refers
to a symbol, which is either a quoted string or a Symbol (such as
`:name`).

<a href='https://ruby-doc.org/core-2.5.0/Object.html' class='ruby-doc
remote' target='_blank'>Object Reference</a>



## Module

A `Module` is a collection of methods and constants. The methods in a
module may be instance methods or module methods. Instance methods
appear as methods in a class when the module is included, module methods
do not. Conversely, module methods may be called without creating an
encapsulating object, while instance methods may not. (See
`Module#module_function`.)

In the descriptions that follow, the parameter *sym* refers to a symbol,
which is either a quoted string or a `Symbol` (such as `:name`).


```ruby
module Mod
  include Math
  CONST = 1
  def meth
    #  ...
  end
end
Mod.class              #=> Module
Mod.constants          #=> [:CONST, :PI, :E]
Mod.instance_methods   #=> [:meth]
```

<a href='https://ruby-doc.org/core-2.5.0/Module.html' class='ruby-doc
remote' target='_blank'>Module Reference</a>



## Class

Classes in Ruby are first-class objects—each is an instance of class
`Class`.

Typically, you create a new class by using:


```ruby
class Name
 # some code describing the class behavior
end
```

When a new class is created, an object of type Class is initialized and
assigned to a global constant (`Name` in this case).

When `Name.new` is called to create a new object, the `new` method in
`Class` is run by default. This can be demonstrated by overriding `new`
in `Class`: 

```ruby
class Class
  alias old_new new
  def new(*args)
    print "Creating a new ", self.name, "\n"
    old_new(*args)
  end
end

class Name
end

n = Name.new
```

*produces:*


```ruby
Creating a new Name
```

Classes, modules, and objects are interrelated. In the diagram that
follows, the vertical arrows represent inheritance, and the parentheses
metaclasses. All metaclasses are instances of the class `Class`.


```
                         +---------+             +-...
                         |         |             |
         BasicObject-----|-->(BasicObject)-------|-...
             ^           |         ^             |
             |           |         |             |
          Object---------|----->(Object)---------|-...
             ^           |         ^             |
             |           |         |             |
             +-------+   |         +--------+    |
             |       |   |         |        |    |
             |    Module-|---------|--->(Module)-|-...
             |       ^   |         |        ^    |
             |       |   |         |        |    |
             |     Class-|---------|---->(Class)-|-...
             |       ^   |         |        ^    |
             |       +---+         |        +----+
             |                     |
obj--->OtherClass---------->(OtherClass)-----------...
```

<a href='https://ruby-doc.org/core-2.5.0/Class.html' class='ruby-doc
remote' target='_blank'>Class Reference</a>



## Method

Method objects are created by `Object#method`, and are associated with a
particular object (not just with a class). They may be used to invoke
the method within the object, and as a block associated with an
iterator. They may also be unbound from one object (creating an
`UnboundMethod`) and bound to another.


```ruby
class Thing
  def square(n)
    n*n
  end
end
thing = Thing.new
meth  = thing.method(:square)

meth.call(9)                 #=> 81
[ 1, 2, 3 ].collect(&meth)   #=> [1, 4, 9]
```

<a href='https://ruby-doc.org/core-2.5.0/Method.html' class='ruby-doc
remote' target='_blank'>Method Reference</a>



### UnboundMethod

Ruby supports two forms of objectified methods. Class `Method` is used
to represent methods that are associated with a particular object: these
method objects are bound to that object. Bound method objects for an
object can be created using `Object#method`.

Ruby also supports unbound methods; methods objects that are not
associated with a particular object. These can be created either by
calling `Module#instance_method` or by calling `unbind` on a bound
method object. The result of both of these is an `UnboundMethod` object.

Unbound methods can only be called after they are bound to an object.
That object must be a kind\_of? the method's original class.


```ruby
class Square
  def area
    @side * @side
  end
  def initialize(side)
    @side = side
  end
end

area_un = Square.instance_method(:area)

s = Square.new(12)
area = area_un.bind(s)
area.call   #=> 144
```

Unbound methods are a reference to the method at the time it was
objectified: subsequent changes to the underlying class will not affect
the unbound method.


```ruby
class Test
  def test
    :original
  end
end
um = Test.instance_method(:test)
class Test
  def test
    :modified
  end
end
t = Test.new
t.test            #=> :modified
um.bind(t).call   #=> :original
```

<a href='https://ruby-doc.org/core-2.5.0/UnboundMethod.html'
class='ruby-doc remote' target='_blank'>UnboundMethod Reference</a>



## Proc

`Proc` objects are blocks of code that have been bound to a set of local
variables. Once bound, the code may be called in different contexts and
still access those variables.


```ruby
def gen_times(factor)
  return Proc.new {|n| n*factor }
end

times3 = gen_times(3)
times5 = gen_times(5)

times3.call(12)               #=> 36
times5.call(5)                #=> 25
times3.call(times5.call(4))   #=> 60
```

<a href='https://ruby-doc.org/core-2.5.0/Proc.html' class='ruby-doc
remote' target='_blank'>Proc Reference</a>



## Fiber

Fibers are primitives for implementing light weight cooperative
concurrency in Ruby. Basically they are a means of creating code blocks
that can be paused and resumed, much like threads. The main difference
is that they are never preempted and that the scheduling must be done by
the programmer and not the VM.

As opposed to other stackless light weight concurrency models, each
fiber comes with a stack. This enables the fiber to be paused from
deeply nested function calls within the fiber block. See the ruby(1)
manpage to configure the size of the fiber stack(s).

When a fiber is created it will not run automatically. Rather it must be
explicitly asked to run using the `Fiber#resume` method. The code
running inside the fiber can give up control by calling `Fiber.yield` in
which case it yields control back to caller (the caller of the
`Fiber#resume`).

Upon yielding or termination the Fiber returns the value of the last
executed expression

For instance:


```ruby
fiber = Fiber.new do
  Fiber.yield 1
  2
end

puts fiber.resume
puts fiber.resume
puts fiber.resume
```

*produces*


```
1
2
FiberError: dead fiber called
```

The `Fiber#resume` method accepts an arbitrary number of parameters, if
it is the first call to `resume` then they will be passed as block
arguments. Otherwise they will be the return value of the call to
`Fiber.yield`

Example:


```ruby
fiber = Fiber.new do |first|
  second = Fiber.yield first + 2
end

puts fiber.resume 10
puts fiber.resume 14
puts fiber.resume 18
```

*produces*


```
12
14
FiberError: dead fiber called
```

<a href='https://ruby-doc.org/core-2.5.0/Fiber.html' class='ruby-doc
remote' target='_blank'>Fiber Reference</a>



## Binding

Objects of class `Binding` encapsulate the execution context at some
particular place in the code and retain this context for future use. The
variables, methods, value of `self`, and possibly an iterator block that
can be accessed in this context are all retained. Binding objects can be
created using `Kernel#binding`, and are made available to the callback
of `Kernel#set_trace_func`.

These binding objects can be passed as the second argument of the
`Kernel#eval` method, establishing an environment for the evaluation.


```ruby
class Demo
  def initialize(n)
    @secret = n
  end
  def get_binding
    binding
  end
end

k1 = Demo.new(99)
b1 = k1.get_binding
k2 = Demo.new(-3)
b2 = k2.get_binding

eval("@secret", b1)   #=> 99
eval("@secret", b2)   #=> -3
eval("@secret")       #=> nil
```

Binding objects have no class-specific methods.

<a href='https://ruby-doc.org/core-2.5.0/Binding.html' class='ruby-doc
remote' target='_blank'>Binding Reference</a>
